//
//  WSNetworkConfig.m
//  HMHealth
//
//  Created by 李林刚 on 2017/4/10.
//  Copyright © 2017年 HM iOS. All rights reserved.
//

#import "WSNetworkConfig.h"
#import <AFNetworking/AFNetworking.h>
#import "NSString+WebService.m"
#import "WSQueryFormat.h"

@implementation WSNetworkConfig

+ (WSNetworkConfig *)sharedInstance {
    static WSNetworkConfig *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.shouldDeadlinessLog = YES;
        _securityPolicy = [AFSecurityPolicy defaultPolicy];
        self.queryStringSerializationBlock = ^NSString *(NSURLRequest *request, id parameters, NSError *__autoreleasing *error) {
            return [WSQueryFormat queryStringFromParameters:parameters];
        };
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfiguration.HTTPMaximumConnectionsPerHost = 4;
        sessionConfiguration.timeoutIntervalForRequest = 30;
        sessionConfiguration.allowsCellularAccess = YES;
        //系统时间的秒值,同个应用的不同api请求的time值应该是递增的, 用于防replay攻击
        sessionConfiguration.HTTPAdditionalHeaders = @{@"callid":[NSString wsCallid],
                                                       //国家CN/US...
                                                       @"country":[NSString wsCountryCode],
                                                       //时区
                                                       @"timezone":[NSString wsSystemTimeZone],
                                                       //语言（中文繁体，中文香港等等）
                                                       @"lang":[NSString wsSystemLanguage],
                                                       //设备类型android_phone or ios_phone
                                                       @"appplatform":[NSString wsDeviceType],
                                                       //客户端版本号
                                                       @"cv":[NSString wsAppShortVersion],
                                                       };
        _sessionConfiguration = sessionConfiguration;
    }
    return self;
}

@end
