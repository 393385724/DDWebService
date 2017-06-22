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
 封装了具体的网络实现，包含请求的拼装，序列化以及response的解析
 */
@interface WSNetWorkClient : NSObject
/**
 唯一初始化方法
 
 @return 返回WSNetWorkClient对象
 */
+ (WSNetWorkClient *)sharedInstance;

/**
 增加一个请求到session并发起请求
 
 @param requestModel WSRequestTask对象
 */
- (void)addWithRequestModel:(WSRequestTask *)requestModel;

/**
 取消一个之前已经添加的网络请求
 
 @param requestModel WSRequestTask对象
 */
- (void)cancelWithRequestModel:(WSRequestTask *)requestModel;

/**
 取消所有当前已发送的请求
 */
- (void)cancelAllRequests;



- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end
