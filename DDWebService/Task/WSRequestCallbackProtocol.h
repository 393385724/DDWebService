//
//  WSRequestCallbackProtocol.h
//  UDan
//
//  Created by lilingang on 8/12/16.
//  Copyright © 2016 LiLingang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WSRequestTask;


/**
 上传下载进度展示

 @param request  WSRequestTask
 @param progress NSProgress
 */
typedef void (^WSProgressHandle)(WSRequestTask *request, NSProgress *progress);


/**
 *  @brief 请求回调的block
 *
 *  @param request  WSRequestTask子类
 *  @param isLocalResult 是不是加载的本地数据
 *  @param error    请求失败的错误信息，eg. 参数错误，服务器错误,...
 */
typedef void (^WSCompleteHandle)(WSRequestTask *request, BOOL isLocalResult, NSError *error);


/**
 *  @brief 回调协议
 */
@protocol WSRequestCallbackProtocol <NSObject>

/**
 *  @brief 请求成功的回调
 *
 *  @param request  WSRequestTask子类
 *  @param isLocalResult 是不是加载的本地数据
 */
- (void)requestDidFinished:(WSRequestTask *)request localResult:(BOOL)isLocalResult;

/**
 *  @brief 请求失败的回调
 *
 *  @param request WSRequestTask子类
 *  @param isLocalResult 是不是加载的本地数据
 *  @param error   请求失败的错误信息，eg. 参数错误，服务器错误,...
 */
- (void)requestDidFailed:(WSRequestTask *)request localResult:(BOOL)isLocalResult error:(NSError *)error;

@end
