//
//  WSNetworkMonitor.h
//  UDan
//
//  Created by lilingang on 16/10/30.
//  Copyright © 2016年 LiLingang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**监听网络变化的通知*/
FOUNDATION_EXTERN NSString * const WSNetworkingReachabilityDidChangeNotification;
/**监听网络变化的通知中UserInfo中状态值的key*/
FOUNDATION_EXTERN NSString * const WSNetworkingReachabilityNotificationStatusItem;

/**
 网络监听类，用于全局网络监听管理
 */
@interface WSNetworkMonitor : NSObject

/**
 开启网络监测
 */
+ (void)startMonitor;

/**
 停止监测网络
 */
+ (void)stopMonitor;

/**
 判断当前网络是否可用

 @return YES ？是 ：否
 */
+ (BOOL)isReachable;

/**
 判断是否连接的WIFI

 @return YES ？是 ：否
 */
+ (BOOL)isWIFI;

/**
 判断是不是手机网络

 @return YES ？是 ：否
 */
+ (BOOL)isWWAN;

@end
