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
        self.shouldHookRedirection = NO;
    }
    return self;
}

#pragma mark - Request and Response Information

- (NSHTTPURLResponse *)httpURLResponse {
    return (NSHTTPURLResponse *)self.requestTask.response;
}

- (NSInteger)responseStatusCode {
    return self.httpURLResponse.statusCode;
}

- (NSDictionary *)responseHeaders {
    return self.httpURLResponse.allHeaderFields;
}

#pragma mark - Common config

- (NSURL *)baseUrl {
    return nil;
}

- (NSString *)apiName {
    return @"";
}

- (NSString *)apiVersion {
    return @"0.0";
}

- (WSHTTPMethod)requestMethod {
    return WSHTTPMethodGET;
}

- (WSUploadDataMethod)uploadDataMethod {
    return WSUploadDataMethodMultipart;
}

- (WSConstructingBlock)constructingBodyBlock {
    return nil;
}

- (WSRequestContentType)requestSerializerType {
    return WSRequestContentTypeJson;
}

- (WSHTTPBodyJsonType)bodyJsonType {
    return WSHTTPBodyJsonTypeDictionary;
}

- (WSResponseMIMEType)responseSerializerType {
    return WSResponseMIMETypeJson;
}

#pragma mark -  Parameter

- (NSError *)validLocalHeaderField{
    return nil;
}

- (void)configureHeaderField{
    self.headerDictionary = [[NSMutableDictionary alloc] init];
}

- (NSError *)validLocalParameterField{
    return nil;
}

- (void)configureParameterField{
    if ([self bodyJsonType] == WSHTTPBodyJsonTypeDictionary) {
        self.parameter = [[NSMutableDictionary alloc] init];
    } else {
        self.parameter = [[NSMutableArray alloc] init];
    }
}

#pragma mark - 策略
- (NSTimeInterval)timeoutInterval{
    return 60;
}

- (BOOL)allowsCellularAccess {
    return YES;
}

#pragma mark - load

- (void)loadWithComplateHandle:(WSCompleteHandle)complateHandle{
    self.completeHandle = complateHandle;
    [self load];
}

- (void)load{
    [self loadLocal:NO];
}

- (void)cancel{
    [[WSNetWorkClient sharedInstance] cancelWithRequestModel:self];
}

- (void)loadLocal:(BOOL)localData{
    self.resultItem = nil;
    self.resultItems = nil;
    [[WSNetWorkClient sharedInstance] addWithRequestModel:self];
}

#pragma mark - response validator

- (BOOL)statusCodeValidator {
    if (self.shouldHookRedirection) {
        return self.responseStatusCode >= 200 && self.responseStatusCode < 400;
    } else {
        return self.responseStatusCode >= 200 && self.responseStatusCode < 300;
    }
}

- (id)jsonModelValidator {
    return nil;
}

- (NSError *)cumstomResposeRawObjectValidator {
    return nil;
}

#pragma mark - CallBack

- (void)clearCompletionBlock {
    self.delegate = nil;
    self.completeHandle = nil;
    self.progressHandle = nil;
}

#pragma mark - Getter and setter

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

- (BOOL)isCancelled {
    return self.requestTask.state == NSURLSessionTaskStateCanceling;
}

- (BOOL)isExecuting {
    return self.requestTask.state == NSURLSessionTaskStateRunning;
}
@end