//
//  WSNetWorkClient.m
//  FitRunning
//
//  Created by lilingang on 16/11/2.
//  Copyright © 2016年 LiLingang. All rights reserved.
//

#import "WSNetWorkClient.h"
#import <AFNetworking/AFNetworking.h>

#import "WSRequestTask.h"
#import "WSRequestAgent.h"
#import "WSMultipartFormData.h"
#import "WSQueryFormat.h"
#import "WSNetworkConfig.h"

@interface WSNetWorkClient ()

/**@brief 整个app应该只持有一个sessionManager*/
@property (nonatomic, strong) AFURLSessionManager *sessionManger;

/**@brief 请求的持有类*/
@property (nonatomic, strong) WSRequestAgent *requestAgent;

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

#pragma mark - Publick Methods
- (void)loadWithRequestModel:(WSRequestTask *)requestModel{
    NSMutableURLRequest *urlRequest = [self urlRequetWithRequestModel:requestModel error:nil];
    if ([WSNetworkConfig sharedInstance].shouldDetailLog) {
        NSLog(@"\n%@ %@ %@ \nHEAD:%@\nParameter:%@\n",NSStringFromClass([requestModel class]),urlRequest.HTTPMethod,requestModel.requestUrlString,urlRequest.allHTTPHeaderFields,requestModel.parameter);
    }
    
    if (![self.requestAgent shouldLoadRequestModel:requestModel]) {
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:429 userInfo:@{NSLocalizedDescriptionKey:@"Too Many Requests"}];
        NSHTTPURLResponse *urlResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:requestModel.requestUrlString] statusCode:error.code HTTPVersion:nil headerFields:urlRequest.allHTTPHeaderFields];
        [self afDidFinishedWithURLResponse:nil responseObject:urlResponse requestModel:requestModel error:error];
        return;
    }
    
    NSURLSessionTask *dataTask = nil;
    __weak __typeof(&*self)weakSelf = self;
    if ([requestModel requestDataMethod] == WSRequestDataMethodDownload){
        dataTask = [self.sessionManger downloadTaskWithRequest:urlRequest progress:^(NSProgress * _Nonnull downloadProgress) {
            if (requestModel.progressHandle) {
                requestModel.progressHandle(requestModel,downloadProgress);
            }
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [requestModel downLoadDestinationPath];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            __strong __typeof(&*weakSelf)strongSelf = weakSelf;
            [strongSelf afDidFinishedWithURLResponse:(NSHTTPURLResponse *)response responseObject:@{} requestModel:requestModel error:error];
        }];
    } else {
        dataTask = [self.sessionManger dataTaskWithRequest:urlRequest completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            __strong __typeof(&*weakSelf)strongSelf = weakSelf;
            [strongSelf afDidFinishedWithURLResponse:(NSHTTPURLResponse *)response responseObject:responseObject requestModel:requestModel error:error];
        }];
    }
    //是否允许Hook重定向方法
    if (requestModel.shouldHookRedirection) {
        [self.sessionManger setTaskWillPerformHTTPRedirectionBlock:^NSURLRequest * _Nonnull(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLResponse * _Nonnull response, NSURLRequest * _Nonnull request) {
            return nil;
        }];
    } else {
        [self.sessionManger setTaskWillPerformHTTPRedirectionBlock:nil];
    }
    [dataTask resume];
    [self.requestAgent addDataTask:dataTask requestModel:requestModel];
}

- (BOOL)isLoadingWithRequestId:(NSString *)requestId{
    NSURLSessionTask *dataTask = [self.requestAgent dataTaskWithRequestId:requestId];
    return dataTask && (dataTask.state == NSURLSessionTaskStateRunning || dataTask.state == NSURLSessionTaskStateSuspended);
}

- (void)cancelWithRequestId:(NSString *)requestId{
    NSURLSessionTask *dataTask = [self.requestAgent dataTaskWithRequestId:requestId];
    if (dataTask) {
        [dataTask cancel];
    }
}

- (void)cancelAllRequest{
    NSArray *allReqeustIds = [self.requestAgent allRequestIds];
    for (NSString *requestId in allReqeustIds) {
        [self cancelWithRequestId:requestId];
    }
}

#pragma mark - Private Methods

- (NSMutableURLRequest *)urlRequetWithRequestModel:(WSRequestTask *)requestModel error:(NSError **)error{
    //根据不同服务器请求创建不同的RequestSerializer
    WSHTTPReqeustFormat reqeustFormat = [requestModel requestFormat];
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    
    //自定义Queury解析方法
    [requestSerializer setQueryStringSerializationWithBlock:^NSString * _Nonnull(NSURLRequest * _Nonnull request, id  _Nonnull parameters, NSError * _Nullable __autoreleasing * _Nullable error) {
        return [WSQueryFormat queryStringFromParameters:parameters];
    }];
    if (reqeustFormat == WSHTTPReqeustFormatPlist) {
        requestSerializer = [AFPropertyListRequestSerializer serializer];
    } else if (reqeustFormat == WSHTTPReqeustFormatJson){
        requestSerializer = [AFJSONRequestSerializer serializer];
    }
    //单独自定义超时时间
    if ([requestModel timeoutInterval] != -1) {
        [requestSerializer setTimeoutInterval:[requestModel timeoutInterval]];
    }
    //自定义的Header
    for (NSString *keyString in requestModel.headerDictionary.allKeys) {
        NSString *valueString = requestModel.headerDictionary[keyString];
        [requestSerializer setValue:valueString forHTTPHeaderField:keyString];
    }
    //配置request
    NSMutableURLRequest *urlRequest = nil;
    NSString *methodString = [self reqeustMethod:[requestModel requestMethod]];
    if ([requestModel requestDataMethod] == WSRequestDataMethodMultipart){
        //mutipart形式上传数据
        urlRequest = [requestSerializer multipartFormRequestWithMethod:methodString URLString:requestModel.requestUrlString parameters:requestModel.parameter constructingBodyWithBlock:requestModel.constructingBodyBlock error:error];
    } else if ([requestModel requestDataMethod] == WSRequestDataMethodBodyData){
        //http Body形式上传数据
        WSMultipartFormData *formData = [[WSMultipartFormData alloc] init];
        void(^dataBlock)(id<AFMultipartFormData>)  = [requestModel constructingBodyBlock];
        if (dataBlock) {
            dataBlock(formData);
        } else {
            NSAssert(NO,@"HTTP Body 形式上传数据必须实现constructingBodyBlock");
        }
        urlRequest = [requestSerializer requestWithMethod:methodString URLString:requestModel.requestUrlString parameters:requestModel.parameter error:error];
        [urlRequest setHTTPBody:formData.data];
        [urlRequest setValue:@"" forHTTPHeaderField:@"Content-Type"];
    } else {
        //正常请求
        urlRequest = [requestSerializer requestWithMethod:methodString URLString:requestModel.requestUrlString parameters:requestModel.parameter error:error];
    }
    return urlRequest;
}

- (NSString *)reqeustMethod:(WSHTTPMethod)httpMethod{
    if (httpMethod == WSHTTPMethodGET) {
        return @"GET";
    } else if (httpMethod == WSHTTPMethodPOST){
        return @"POST";
    } else if (httpMethod == WSHTTPMethodPUT){
        return @"PUT";
    } else if (httpMethod == WSHTTPMethodDELETE){
        return @"DELETE";
    } else if (httpMethod == WSHTTPMethodPATCH){
        return @"PATCH";
    } else {
        return @"GET";
    }
}

#pragma mark - AFNetworking CallBack

- (void)afDidFinishedWithURLResponse:(NSHTTPURLResponse *)urlResponse
                      responseObject:(id)responseObject
                        requestModel:(WSRequestTask *)requestModel
                               error:(NSError *)error{
    if (error) {
        if ([WSNetworkConfig sharedInstance].shouldDetailLog || [WSNetworkConfig sharedInstance].shouldDeadlinessLog) {
            NSLog(@"\n%@ %@ %@ \nHTTPURLResponse:%@\nObject:%@\nError:%@",NSStringFromClass([requestModel class]),[self reqeustMethod:requestModel.requestMethod],requestModel.requestUrlString,urlResponse,responseObject,error);
        }
        [self.requestAgent removeRequestId:requestModel.taskIdentifier success:NO];
        [requestModel requestDidFailWithURLResponse:urlResponse responseObject:[responseObject mutableCopy] error:error];
    } else {
        if ([WSNetworkConfig sharedInstance].shouldDetailLog) {
            NSLog(@"\n%@ %@ %@ \nHTTPURLResponse:%@\nObject:%@\n",NSStringFromClass([requestModel class]),[self reqeustMethod:requestModel.requestMethod],requestModel.requestUrlString,urlResponse,responseObject);
        }
        [self.requestAgent removeRequestId:requestModel.requestUrlString success:YES];
        [requestModel requestDidSuccessWithURLResponse:urlResponse responseObject:[responseObject mutableCopy]];
    }
}

#pragma mark - Getter and Setter

- (AFURLSessionManager *)sessionManger{
    if (!_sessionManger) {
        NSURLSessionConfiguration *sessionConfiguration = [WSNetworkConfig sharedInstance].sessionConfiguration;
        _sessionManger = [[AFURLSessionManager alloc] initWithSessionConfiguration:sessionConfiguration];
        _sessionManger.operationQueue.maxConcurrentOperationCount = 5;
        AFJSONResponseSerializer *jsonResponseSerializer = _sessionManger.responseSerializer;
        jsonResponseSerializer.readingOptions = NSJSONReadingAllowFragments;
    }
    return _sessionManger;
}

- (WSRequestAgent *)requestAgent{
    if (!_requestAgent) {
        _requestAgent = [[WSRequestAgent alloc] init];
    }
    return _requestAgent;
}

@end
