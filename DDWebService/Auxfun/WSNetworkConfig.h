//
//  WSNetworkConfig.h
//  HMHealth
//
//  Created by 李林刚 on 2017/4/10.
//  Copyright © 2017年 HM iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFSecurityPolicy;

typedef NSString * (^WSQueryStringSerializationBlock)(NSURLRequest *request, id parameters, NSError *__autoreleasing *error);

/**
 对全局网络请
 */
@interface WSNetworkConfig : NSObject

/**
 全局统一的域名,默认nil
 */
@property (nonatomic, copy) NSString *baseUrl;

/**
 安全策略
 */
@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;

/**
 自定义QueryString序列化规则,默认WSQueryFormat
 */
@property (nonatomic, copy) WSQueryStringSerializationBlock queryStringSerializationBlock;

/**
 全局统一的网络请求配置，不配置使用默认
 */
@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;

/**
 显示详细的请求log，默认NO
 */
@property (nonatomic, assign) BOOL shouldDetailLog;

/**
 显示致命的错误log，默认YES
 */
@property (nonatomic, assign) BOOL shouldDeadlinessLog;

/**
 唯一初始化方法
 
 @return WSNetworkConfig
 */
+ (WSNetworkConfig *)sharedInstance;



- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end
