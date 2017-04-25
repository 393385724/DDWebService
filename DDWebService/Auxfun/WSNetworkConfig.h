//
//  WSNetworkConfig.h
//  HMHealth
//
//  Created by 李林刚 on 2017/4/10.
//  Copyright © 2017年 HM iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSNetworkConfig : NSObject

/**
 显示详细的请求log，默认NO
 */
@property (nonatomic, assign) BOOL shouldDetailLog;

/**
 显示致命的错误log，默认YES
 */
@property (nonatomic, assign) BOOL shouldDeadlinessLog;

/**
 全局统一的网络请求配置，不配置使用默认
 */
@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;

+ (WSNetworkConfig *)sharedInstance;

@end
