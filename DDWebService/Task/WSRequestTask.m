//
//  WSRequestTask.m
//  FitRunning
//
//  Created by lilingang on 16/11/2.
//  Copyright © 2016年 LiLingang. All rights reserved.
//

#import "WSRequestTask.h"
#import "WSNetWorkClient.h"

@interface WSRequestTask ()

/**@brief 完整的请求URL*/
@property (nonatomic, copy, readwrite) NSString *requestUrlString;

/**@brief 自定义的HEADER*/
@property (nonatomic, strong, readwrite) NSMutableDictionary *headerDictionary;

/**@brief 自定义的parameter*/
@property (nonatomic, strong, readwrite) id parameter;

@property (nonatomic, assign, readwrite, getter=isLoading) BOOL loading;

/**@brief 实现请求的回调*/
@property (nonatomic, copy) WSCompleteHandle completeHandle;

/**
 NSHTTPURLResponse
 */
@property (nonatomic, strong, readwrite) NSHTTPURLResponse *httpURLResponse;

@end

@implementation WSRequestTask

- (instancetype)init{
    self = [super init];
    if (self) {
        self.loading = NO;
    }
    return self;
}

#pragma mark - request config

- (NSURL *)baseUrl{
    NSAssert(NO, @"subclass must implement @selector(baseUrl)");
    return nil;
}

- (NSString *)apiName{
    return @"";
}

- (WSHTTPReqeustFormat)requestFormat{
    return WSHTTPReqeustFormatJson;
}

- (WSHTTPMethod)requestMethod{
    NSAssert(NO, @"subclass must implement @selector(requestMethod)");
    return WSHTTPMethodGET;
}

- (WSRequestDataMethod)requestDataMethod{
    return WSRequestDataMethodNone;
}

- (NSString *)apiVersion{
    return @"0.0";
}

- (NSError *)validLocalHeaderField{
    return nil;
}

- (void)configureHeaderField{
    self.headerDictionary = [[NSMutableDictionary alloc] init];
}

- (NSError *)validLocalParameterField{
    return nil;
}

- (HMHTTPBodyJsonType)bodyJsonType{
    return HMHTTPBodyJsonTypeDictionary;
}

- (void)configureParameterField{
    if ([self bodyJsonType] == HMHTTPBodyJsonTypeDictionary) {
        self.parameter = [[NSMutableDictionary alloc] init];
    } else {
        self.parameter = [[NSMutableArray alloc] init];
    }
}

- (WSConstructingBlock)constructingBodyBlock{
    return nil;
}

- (NSURL *)downLoadDestinationPath{
    NSAssert(NO, @"subclass must implement @selector(downLoadDestinationPath) and requestDataMethod must return WSRequestDataMethodDownload ");
    return nil;
}

#pragma mark - 策略
- (NSTimeInterval)timeoutInterval{
    return -1;
}

- (NSTimeInterval)requestTTL{
    return 0;
}

- (BOOL)shouldAllowCache{
    return NO;
}

#pragma mark - load

- (void)loadLocalWithComplateHandle:(WSCompleteHandle)complateHandle{
    if ([self requestDataMethod] == WSRequestDataMethodNone && [self requestMethod] == WSHTTPMethodGET) {
        self.completeHandle = complateHandle;
        [self loadLocal:YES];
    } else {
        [self loadLocalWithComplateHandle:complateHandle];
    }
}

- (void)loadWithComplateHandle:(WSCompleteHandle)complateHandle{
    self.completeHandle = complateHandle;
    [self load];
}

- (void)load{
    [self loadLocal:NO];
}

- (void)cancel{
    [[WSNetWorkClient sharedInstance] cancelWithRequestId:self.taskIdentifier];
}

- (void)loadLocal:(BOOL)localData{
    self.shouldLoadLocalOnly = localData;
    if (self.isLoading) {
        NSLog(@"%@ is flying outside︿(￣︶￣)︿",[[self class] description]);
        return;
    }
    //local check
    NSError *error = [self validLocalHeaderField];
    if (error) {
        [self requestDidFailWithURLResponse:nil responseObject:nil error:error];
        return;
    }
    error = [self validLocalParameterField];
    if (error) {
        [self requestDidFailWithURLResponse:nil responseObject:nil error:error];
        return;
    }
    [self configureHeaderField];
    [self configureParameterField];
    self.loading = YES;
    self.resultItem = nil;
    self.resultItems = nil;
    [[WSNetWorkClient sharedInstance] loadWithRequestModel:self];
}

#pragma mark - Web Servcie Response

- (void)requestDidSuccessWithURLResponse:(NSHTTPURLResponse *)urlResponse responseObject:(id)responseObject{
    if ([responseObject isKindOfClass:[NSNull class]]) {
        NSError *error = [NSError wsResponseFormatError];
        [self requestDidFailWithURLResponse:urlResponse responseObject:responseObject error:error];
        return;
    }
    self.httpURLResponse = urlResponse;
    self.loading = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestDidFinished:localResult:)]) {
        [self.delegate requestDidFinished:self localResult:self.shouldLoadLocalOnly];
    } else if (self.completeHandle){
        self.completeHandle(self,self.shouldLoadLocalOnly,nil);
        self.completeHandle = nil;
    }
}

- (void)requestDidFailWithURLResponse:(NSHTTPURLResponse *)urlResponse responseObject:(id)responseObject error:(NSError *)error{
    self.httpURLResponse = urlResponse;
    self.loading = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestDidFailed:localResult:error:)]) {
        [self.delegate requestDidFailed:self localResult:self.shouldLoadLocalOnly error:error];
    } else if (self.completeHandle){
        self.completeHandle(self,self.shouldLoadLocalOnly,error);
        self.completeHandle = nil;
    }
}

#pragma mark - Getter and setter

- (NSString *)taskIdentifier{
    return self.requestUrlString;
}

- (NSString *)requestUrlString{
    if (!_requestUrlString) {
        if ([[self apiName] length]) {
            _requestUrlString = [[NSURL URLWithString:[self apiName] relativeToURL:[self baseUrl]] absoluteString];
        } else {
            _requestUrlString = [[self baseUrl] absoluteString];
        }
    }
    return _requestUrlString;
}

@end
