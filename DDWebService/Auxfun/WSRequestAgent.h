//
//  WSRequestAgent.h
//  FitRunning
//
//  Created by lilingang on 16/11/2.
//  Copyright © 2016年 LiLingang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSURLSessionTask;
@class WSRequestTask;

/**
 *  @brief 已发起请求的管理持有类 singleton
 */
@interface WSRequestAgent : NSObject

/**
 *  @brief 唯一初始化对象
 *
 *  @return WSRequestAgent
 */
+ (WSRequestAgent *)sharedInstance;

/**
 *  @brief 返回所有正在发送的请求唯一标识
 *
 *  @return NSArray
 */
- (NSArray *)allRequestIds;

/**
 *  @brief 根据指定策略是否允许发起请求
 *
 *  @param requestModel 请求的配置信息
 *
 *  @return YES : 允许 : 不允许
 */
- (BOOL)shouldLoadRequestModel:(WSRequestTask *)requestModel;

/**
 *  @brief 持有当前的请求并返回唯一标识
 *
 *  @param dataTask 当前请求 
 *  @param requestModel 请求的配置信息
 *
 */
- (void)addDataTask:(NSURLSessionTask *)dataTask requestModel:(WSRequestTask *)requestModel;

/**
 *  @brief 根据指定的requestID返回对应的dataTask
 *
 *  @param requestId 请求的唯一标识
 *
 *  @return NSURLSessionTask
 */
- (NSURLSessionTask *)dataTaskWithRequestId:(NSString *)requestId;

/**
 *  @brief 根据指定的requestID返回对应的WSRequestTask
 *
 *  @param requestId 请求的唯一标识
 *
 *  @return WSRequestTask
 */
- (WSRequestTask *)requestModelWithRequestId:(NSString *)requestId;

/**
 *  @brief 从当前的分发队列中移除当前的请求
 *
 *  @param requestId 请求的唯一标识
 *  @param success   是否请求成功
 */
- (void)removeRequestId:(NSString *)requestId success:(BOOL)success;

@end
