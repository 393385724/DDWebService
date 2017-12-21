//
//  WSRequestTask.m
//  FitRunning
//
//  Created by lilingang on 16/11/2.
//  Copyright © 2016年 LiLingang. All rights reserved.
//

#import "WSRequestTask.h"
#import "WSNetWorkClient.h"
#import "WSNetworkTool.h"

@interface WSRequestTask ()

@property (nonatomic, copy, readwrite) NSString *requestUrlString;

@property (nonatomic, strong, readwrite) NSMutableDictionary *headerDictionary;

@property (nonatomic, strong, readwrite) id parameter;

@property (nonatomic, copy, readwrite) WSCompleteHandle completeHandle;

@property (nonatomic, copy, readwrite) WSProgressHandle progressHandle;

@property (nonatomic, strong) NSDate *lastSuccessReqeustDate;

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

- (NSString *)ipAddress {
    return [WSNetworkTool ipAddressWithHostName:self.httpURLResponse.URL.host];
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

- (NSString *)reqeustMethodString {
    WSHTTPMethod httpMethod = [self requestMethod];
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
    } else if (httpMethod == WSHTTPMethodHEAD) {
        return @"HEAD";
    } else {
        return @"GET";
    }
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

- (NSTimeInterval)requestInterval {
    return 0;
}

- (BOOL)allowsCellularAccess {
    return YES;
}

- (void)resetRequestTTL {
    if ([self requestInterval] > 0) {
        self.lastSuccessReqeustDate = [NSDate date];
    }
}

- (BOOL)shouldForbidRequestWhithInTimeLimit {
    if ([self requestInterval] > 0 && self.lastSuccessReqeustDate) {
        NSTimeInterval interal = [[NSDate date] timeIntervalSinceDate:self.lastSuccessReqeustDate];
        if (fabs(interal) < [self requestInterval]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - load

- (void)loadWithComplateHandle:(WSCompleteHandle)complateHandle{
    [self loadWithProgress:nil complateHandle:complateHandle];
}

- (void)loadWithProgress:(WSProgressHandle)progressHandle
          complateHandle:(WSCompleteHandle)complateHandle {
    self.completeHandle = complateHandle;
    self.progressHandle = progressHandle;
    [self load];
}

- (void)load{
    self.resultItem = nil;
    self.resultItems = nil;
    [[WSNetWorkClient sharedInstance] addWithRequestModel:self];
}

- (void)cancel{
    [[WSNetWorkClient sharedInstance] cancelWithRequestModel:self];
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

- (void)requestCompleteProcessor {
    
}

- (void)clearCompletionBlockRequestSuccess:(BOOL)success {
    if (success) {
        [self resetRequestTTL];
    }
    self.completeHandle = nil;
    self.progressHandle = nil;
}

#pragma mark - 错误处理

- (void)handleError:(NSError *)error {
    
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
