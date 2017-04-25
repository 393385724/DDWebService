//
//  WSNetWorkClient.h
//  FitRunning
//
//  Created by lilingang on 16/11/2.
//  Copyright © 2016年 LiLingang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WSRequestTask;

/**
 *  @brief 该类对三方或者系统的网络请求做封装，对外不会暴漏请求的具体细节
 */
@interface WSNetWorkClient : NSObject

/**
 *  @brief 唯一初始化方法
 *
 *  @return 返回WSNetWorkClient对象
 */
+ (WSNetWorkClient *)sharedInstance;

/**
 *  @brief 发起一个网络请求
 *
 *  @param requestModel 请求的配置信息
 */
- (void)loadWithRequestModel:(WSRequestTask *)requestModel;

/**
 *  @brief 判断指定的reqeust是否正在发起请求
 *
 *  @param requestId request的唯一标识
 *
 *  @return YES ？正在发起请求：没有发起国请求或者请求完毕了
 */
- (BOOL)isLoadingWithRequestId:(NSString *)requestId;

/**
 *  @brief 取消指定的网络请求
 *
 *  @param requestId 已经发送网络请求的唯一标识
 */
- (void)cancelWithRequestId:(NSString *)requestId;

/**
 *  @brief 取消所有正在发送的网络请求
 */
- (void)cancelAllRequest;

@end
