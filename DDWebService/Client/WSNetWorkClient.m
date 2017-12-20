//
//  WSNetWorkClient.m
//  FitRunning
//
//  Created by lilingang on 16/11/2.
//  Copyright © 2016年 LiLingang. All rights reserved.
//

#import "WSNetWorkClient.h"
#import <AFNetworking/AFNetworking.h>
#import <pthread/pthread.h>

#import "WSRequestTask.h"
#import "WSRequestAgent.h"
#import "WSMultipartFormData.h"
#import "WSNetworkConfig.h"
#import "WSNetworkTool.h"
#import "AFHTTPRequestSerializer+WSHTTPHeader.h"

@interface WSNetWorkClient ()
/**
 全局服务统一配置
 */
@property (nonatomic, strong) WSNetworkConfig *networkConfig;
/**
 整个app应该只持有一个sessionManager
 */
@property (nonatomic, strong) AFHTTPSessionManager *sessionManger;
/**
 请求持有类
 */
@property (nonatomic, strong) WSRequestAgent *requestAgent;
/**
 允许支持的HttpCode
 */
@property (nonatomic, strong) NSIndexSet *allStatusCodes;
@end

@implementation WSNetWorkClient

+ (WSNetWorkClient *)sharedInstance {
    static WSNetWorkClient *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _networkConfig = [WSNetworkConfig sharedInstance];
        dispatch_queue_t processingQueue = dispatch_queue_create("com.huami.networkagent.processing", DISPATCH_QUEUE_CONCURRENT);
        _allStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(100, 500)];
        
        _sessionManger = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:_networkConfig.sessionConfiguration];
        _sessionManger.securityPolicy = _networkConfig.securityPolicy;
        _sessionManger.completionQueue = processingQueue;
        
        _requestAgent = [[WSRequestAgent alloc] init];
    }
    return self;
}

#pragma mark - Publick Methods

- (void)addWithRequestModel:(WSRequestTask *)requestModel{
    NSParameterAssert(requestModel != nil);
    //时效校验
    if ([requestModel shouldForbidRequestWhithInTimeLimit]) {
        NSError *error = [NSError wsTooManyTimeError];
        [self requestDidFailedWithRequestModel:requestModel error:error];
        return;
    }
    //校验Header
    NSError *error = [requestModel validLocalHeaderField];
    if (error) {
        [self requestDidFailedWithRequestModel:requestModel error:error];
        return;
    }
    [requestModel configureHeaderField];
    //校验paramter
    error = [requestModel validLocalParameterField];
    if (error) {
        [self requestDidFailedWithRequestModel:requestModel error:error];
        return;
    }
    [requestModel configureParameterField];
    //生成请求task
    NSError *requestSerializationError = nil;
    requestModel.requestTask = [self sessionTaskForRequestModel:requestModel error:&requestSerializationError];
    
    [self.sessionManger setTaskWillPerformHTTPRedirectionBlock:^NSURLRequest * _Nonnull(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLResponse * _Nonnull response, NSURLRequest * _Nonnull request) {
        //是否允许Hook重定向方法
        if (task.taskIdentifier == requestModel.requestTask.taskIdentifier && requestModel.shouldHookRedirection) {
            return nil;
        } else {
            return request;
        }
    }];
    self.sessionManger.responseSerializer = [self responseSerializerWithRequestModel:requestModel];
    NSAssert(requestModel.requestTask != nil, @"requestTask should not be nil");
    [self.requestAgent addRequestModel:requestModel];
    [requestModel.requestTask resume];
}

- (void)cancelWithRequestModel:(WSRequestTask *)requestModel {
    NSParameterAssert(requestModel != nil);
    [requestModel.requestTask cancel];
    [self.requestAgent removeRequestModel:requestModel];
}

- (void)cancelAllRequests {
    NSArray <WSRequestTask *> *requestModles = [self.requestAgent allRequestModles];
    for (WSRequestTask *requestModel in requestModles) {
        [self cancelWithRequestModel:requestModel];
    }
}

#pragma mark - Private Methods

- (AFHTTPRequestSerializer *)requestSerializerWithRequestModel:(WSRequestTask *)requestModel {
    WSRequestContentType contentType = [requestModel requestSerializerType];
    AFHTTPRequestSerializer *requestSerializer = nil;
    if (contentType == WSRequestContentTypeURLEncoded) {
        AFHTTPRequestSerializer.wsIgnoreHeaderKeys = requestModel.ignoreHeaderKeys;
        requestSerializer = [AFHTTPRequestSerializer serializer];
    } else if (contentType == WSRequestContentTypeJson) {
        AFJSONRequestSerializer.wsIgnoreHeaderKeys = requestModel.ignoreHeaderKeys;
        requestSerializer = [AFJSONRequestSerializer serializer];
    } else if (contentType == WSRequestContentTypeXPlist) {
        AFPropertyListRequestSerializer.wsIgnoreHeaderKeys = requestModel.ignoreHeaderKeys;
        requestSerializer = [AFPropertyListRequestSerializer serializer];
    }
    
    requestSerializer.timeoutInterval = [requestModel timeoutInterval];
    requestSerializer.allowsCellularAccess = [requestModel allowsCellularAccess];
    
    //自定义Queury解析方法
    __weak __typeof(&*self)weakSelf = self;
    [requestSerializer setQueryStringSerializationWithBlock:^NSString * _Nonnull(NSURLRequest * _Nonnull request, id  _Nonnull parameters, NSError * _Nullable __autoreleasing * _Nullable error) {
        return weakSelf.networkConfig.queryStringSerializationBlock(request,parameters,error);
    }];
    
    //自定义Header
    NSDictionary<NSString *, NSString *> *headerFieldValueDictionary = requestModel.headerDictionary;
    if (headerFieldValueDictionary != nil) {
        for (NSString *httpHeaderField in headerFieldValueDictionary.allKeys) {
            NSString *value = headerFieldValueDictionary[httpHeaderField];
            [requestSerializer setValue:value forHTTPHeaderField:httpHeaderField];
        }
    }
    return requestSerializer;
}

- (AFHTTPResponseSerializer *)responseSerializerWithRequestModel:(WSRequestTask *)requestModel {
    WSResponseMIMEType mimeType = [requestModel responseSerializerType];
    AFHTTPResponseSerializer *responseSerializer = nil;
    if (mimeType == WSResponseMIMETypeJson) {
        AFJSONResponseSerializer *jsonResponseSerializer = [AFJSONResponseSerializer serializer];
        jsonResponseSerializer.readingOptions = NSJSONReadingAllowFragments;
        jsonResponseSerializer.removesKeysWithNullValues = YES;
        responseSerializer = jsonResponseSerializer;
    } else if (mimeType == WSResponseMIMETypeXML) {
        responseSerializer = [AFXMLParserResponseSerializer serializer];
    } else if (mimeType == WSResponseMIMETypePlist) {
        responseSerializer = [AFPropertyListResponseSerializer serializer];
    } else if (mimeType == WSResponseMIMETypeImage) {
        responseSerializer = [AFImageResponseSerializer serializer];
    }
    responseSerializer.acceptableStatusCodes = self.allStatusCodes;
    return responseSerializer;
}

#pragma mark - SessionTask

- (NSMutableURLRequest *)requestWithHTTPMethod:(NSString *)method
                             requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                     URLString:(NSString *)URLString
                                    parameters:(id)parameters
                                         error:(NSError * _Nullable __autoreleasing *)error {
    return [self requestWithHTTPMethod:method requestSerializer:requestSerializer URLString:URLString parameters:parameters constructingBodyWithBlock:nil error:error];
}

- (NSMutableURLRequest *)requestWithHTTPMethod:(NSString *)method
                             requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                     URLString:(NSString *)URLString
                                    parameters:(id)parameters
                     constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))block
                                         error:(NSError * _Nullable __autoreleasing *)error {
    NSMutableURLRequest *request = nil;
    if (block) {
        request = [requestSerializer multipartFormRequestWithMethod:method URLString:URLString parameters:parameters constructingBodyWithBlock:block error:error];
    } else {
        request = [requestSerializer requestWithMethod:method URLString:URLString parameters:parameters error:error];
    }
    return request;
}

- (NSURLSessionTask *)sessionTaskForRequestModel:(WSRequestTask *)requestModel error:(NSError * _Nullable __autoreleasing *)error {
    WSHTTPMethod method = [requestModel requestMethod];
    NSString *methodString = [requestModel reqeustMethodString];
    NSString *requestUrlString = requestModel.requestUrlString;
    id parameter = requestModel.parameter;
    WSConstructingBlock constructingBlock = [requestModel constructingBodyBlock];
    AFHTTPRequestSerializer *requestSerializer = [self requestSerializerWithRequestModel:requestModel];
    
    NSMutableURLRequest *mutableRequest = nil;
    
    BOOL uploadData = ![requestModel constructingBodyBlock] && [requestModel uploadDataMethod] == WSUploadDataMethodMultipart;
    BOOL correctUploadMethod = method != WSHTTPMethodGET && method != WSHTTPMethodHEAD;
    if (uploadData && correctUploadMethod) {
        mutableRequest = [self requestWithHTTPMethod:methodString requestSerializer:requestSerializer URLString:requestUrlString parameters:parameter constructingBodyWithBlock:constructingBlock error:error];
    } else {
        mutableRequest = [self requestWithHTTPMethod:methodString requestSerializer:requestSerializer URLString:requestUrlString parameters:parameter error:error];
    }
    
    if ([requestModel uploadDataMethod] == WSUploadDataMethodHTTPBody) {
        WSMultipartFormData *formData = [[WSMultipartFormData alloc] init];
        void(^dataBlock)(id<AFMultipartFormData>)  = [requestModel constructingBodyBlock];
        if (dataBlock) {
            dataBlock(formData);
        } else {
            NSAssert(NO,@"HTTP Body 形式上传数据必须实现constructingBodyBlock");
        }
        [mutableRequest setValue:@"" forHTTPHeaderField:@"Content-Type"];
        [mutableRequest setHTTPBody:formData.data];
    }
    
    if ([WSNetworkConfig sharedInstance].shouldDetailLog) {
        NSLog(@"\n%@ [%@] %@ \nheader:%@\nparameter:%@\n",NSStringFromClass([requestModel class]),methodString,requestUrlString,mutableRequest.allHTTPHeaderFields,parameter);
    }
    __block NSURLSessionTask *dataTask = nil;
    
    if (requestModel.downloadPath) {
        NSString *targetDownloadPath = [WSNetworkTool validDownloadPathWithDownloadPath:requestModel.downloadPath downloadURL:mutableRequest.URL];
        BOOL canBeResumed = [WSNetworkTool canResumeDwonloadDataWithDownloadPath:targetDownloadPath];
        BOOL resumeSucceeded = NO;
        //尝试恢复下载，当然可能会存在crash，这时候我们重新下载
        if (canBeResumed) {
            @try {
                NSData *data = [NSData dataWithContentsOfURL:[WSNetworkTool resumeDownloadDataTempPathForDownloadPath:targetDownloadPath]];
                dataTask = [self.sessionManger downloadTaskWithResumeData:data progress:requestModel.progressHandle destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                    return [NSURL fileURLWithPath:targetDownloadPath isDirectory:NO];
                } completionHandler:
                                ^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                    [self handleRequestResult:dataTask responseObject:filePath error:error];
                                }];
                resumeSucceeded = YES;
            } @catch (NSException *exception) {
                NSLog(@"Resume download failed, reason = %@", exception.reason);
                resumeSucceeded = NO;
            }
        }
        if (!resumeSucceeded) {
            dataTask = [self.sessionManger downloadTaskWithRequest:mutableRequest progress:requestModel.progressHandle destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                return [NSURL fileURLWithPath:targetDownloadPath isDirectory:NO];
            } completionHandler:
                            ^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                [self handleRequestResult:dataTask responseObject:filePath error:error];
                            }];
        }
    } else {
        dataTask = [self.sessionManger dataTaskWithRequest:mutableRequest
                                         completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *_error) {
                                             [self handleRequestResult:dataTask responseObject:responseObject error:_error];
                                         }];
    }
    return dataTask;
}

#pragma mark - AFNetworking CallBack

- (void)handleRequestResult:(NSURLSessionTask *)task responseObject:(id)responseObject error:(NSError *)error {
    WSRequestTask *requestModel = [self.requestAgent requestModelWithTaskIdentifier:[@(task.taskIdentifier) stringValue]];
    if (!requestModel) {
        return;
    }
    requestModel.responseRawObject = responseObject;
    NSError *responseError = error;
    //1、校验是否是正确的statusCode（通常200-300之间是正常的Code）
    if (![requestModel statusCodeValidator] && requestModel.httpURLResponse && !error) {
        responseError = [NSError errorWithDomain:@"com.huami.statuscode.validation" code:requestModel.responseStatusCode userInfo:@{NSLocalizedDescriptionKey:@"Invalid status code"}];
    }
    //2、如果允许重定向(statusCode为3XX的为重定向)，可能的话需要hook住
    if (requestModel.shouldHookRedirection && requestModel.responseStatusCode >= 300 && requestModel.responseStatusCode < 400) {
        NSString *locationString = requestModel.httpURLResponse.allHeaderFields[@"Location"];
        NSString *queryString = [NSURL URLWithString:locationString].query;
        requestModel.responseRawObject = [WSNetworkTool dictionaryWithQueryString:queryString];
    }
    
    //3、校验responseObject不能为NSNull class
    if (!responseError && [requestModel.responseRawObject isKindOfClass:[NSNull class]]) {
        responseError = [NSError wsResponseFormatError];
    }
    //4、如果是json结构，选择进行强校验
    if (!responseError && [requestModel responseSerializerType] == WSResponseMIMETypeJson && [requestModel jsonModelValidator]) {
        //对json结构进行强校验
       BOOL validJson = [WSNetworkTool validateJsonObject:requestModel.responseRawObject withValidJsonModel:[requestModel jsonModelValidator]];
        if (!validJson) {
            responseError = [NSError wsResponseFormatError];
        }
    }
    //5、自定义校验
    if (!responseError) {
        responseError = [requestModel cumstomResposeRawObjectValidator];
    }
    //分发处理
    if (!responseError) {
        if ([WSNetworkConfig sharedInstance].shouldDetailLog) {
            NSLog(@"\n%@ %@ %@ \nHTTPURLResponse:%@\nObject:%@\n",NSStringFromClass([requestModel class]),[requestModel reqeustMethodString],requestModel.requestUrlString,requestModel.httpURLResponse,requestModel.responseRawObject);
        }
        [self requestDidSucceedWithRequestModel:requestModel];
    } else {
        if ([WSNetworkConfig sharedInstance].shouldDetailLog || [WSNetworkConfig sharedInstance].shouldDeadlinessLog) {
            NSLog(@"\n%@ %@ %@ \nHTTPURLResponse:%@\nObject:%@\nError:%@",NSStringFromClass([requestModel class]),[requestModel reqeustMethodString],requestModel.requestUrlString,requestModel.httpURLResponse,requestModel.responseRawObject,responseError);
        }
        [self requestDidFailedWithRequestModel:requestModel error:responseError];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.requestAgent removeRequestModel:requestModel];
        [requestModel clearCompletionBlockRequestSuccess:!error];
    });
}

- (void)requestDidSucceedWithRequestModel:(WSRequestTask *)requestModel {
    [requestModel requestCompleteProcessor];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (requestModel.delegate && [requestModel.delegate respondsToSelector:@selector(requestDidFinished:localResult:)]) {
            [requestModel.delegate requestDidFinished:requestModel localResult:NO];
        }
        if (requestModel.completeHandle) {
            requestModel.completeHandle(requestModel, NO, nil);
        }
    });
}

- (void)requestDidFailedWithRequestModel:(WSRequestTask *)requestModel error:(NSError *)error{
    //如果存在的话，缓存断点恢复的数据
    NSData *resumeDownloadData = error.userInfo[NSURLSessionDownloadTaskResumeData];
    if (resumeDownloadData) {
        [resumeDownloadData writeToURL:[WSNetworkTool resumeDownloadDataTempPathForDownloadPath:requestModel.downloadPath] atomically:YES];
    }
    //下载失败,移除制定路径
    if ([requestModel.responseRawObject isKindOfClass:[NSURL class]]) {
        NSURL *url = requestModel.responseRawObject;
        if (url.isFileURL && [[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
            [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [requestModel handleError:error];
        if (requestModel.delegate && [requestModel.delegate respondsToSelector:@selector(requestDidFailed:error:)]) {
            [requestModel.delegate requestDidFailed:requestModel error:error];
        }
        if (requestModel.completeHandle) {
            requestModel.completeHandle(requestModel, NO, error);
        }
    });
}

@end
