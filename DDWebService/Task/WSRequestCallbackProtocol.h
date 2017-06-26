//
//  WSRequestCallbackProtocol.h
//  UDan
//
//  Created by lilingang on 8/12/16.
//  Copyright © 2016 LiLingang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WSRequestTask;
@protocol AFMultipartFormData;

/**
 上传数据需要使用的block，遵循AFMultipartFormData协议
 
 @param formData AFMultipartFormData协议
 */
typedef void (^WSConstructingBlock)(id<AFMultipartFormData> formData);

/**
 下载进度回调

 @param progress NSProgress
 */
typedef void (^WSProgressHandle)(NSProgress *progress);

/**
 请求回调block
 
 @param request WSRequestTask子类
 @param isLocalResult 是否加载的本地数据(遗留没什么用)
 @param error 错误信息
 */
typedef void (^WSCompleteHandle)(WSRequestTask *request, BOOL isLocalResult, NSError *error);

/**
 回调协议
 */
@protocol WSRequestCallbackProtocol <NSObject>

/**
 请求成功的回调
 
 @param request WSRequestTask子类
 @param isLocalResult 是否加载的本地数据(遗留没什么用)
 */
- (void)requestDidFinished:(WSRequestTask *)request localResult:(BOOL)isLocalResult;

/**
 请求失败的回调
 
 @param request WSRequestTask子类
 @param error 失败信息，eg. 参数错误，服务器错误,...
 */
- (void)requestDidFailed:(WSRequestTask *)request error:(NSError *)error;

@end
