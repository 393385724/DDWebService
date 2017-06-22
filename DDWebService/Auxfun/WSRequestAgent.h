//
//  WSRequestAgent.h
//  FitRunning
//
//  Created by lilingang on 16/11/2.
//  Copyright © 2016年 LiLingang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WSRequestTask;

/**
 *  @brief 已发起请求的管理持有类 singleton
 */
@interface WSRequestAgent : NSObject

/**
 返回正在正在请求的Models
 
 @return NSArray
 */
- (NSArray <WSRequestTask *>*)allRequestModles;

/**
 持有当前请求
 
 @param requestModel WSRequestTask
 */
- (void)addRequestModel:(WSRequestTask *)requestModel;
    
/**
 *  @brief 根据指定的taskIdentifier返回对应的WSRequestTask
 *
 *  @param taskIdentifier 请求的唯一标识
 *
 *  @return WSRequestTask
 */
- (WSRequestTask *)requestModelWithTaskIdentifier:(NSString *)taskIdentifier;

/**
 当前分发队列中移除请求
 
 @param requestModel WSRequestTask
 */
- (void)removeRequestModel:(WSRequestTask *)requestModel;

@end
