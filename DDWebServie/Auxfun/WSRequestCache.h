//
//  WSRequestCache.h
//  UDan
//
//  Created by lilingang on 16/9/28.
//  Copyright © 2016年 LiLingang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 请求缓存管理类,单例
 */
@interface WSRequestCache : NSObject

/**
 创建一个请求缓存管理单例

 @return WSRequestCache 实例
 */
+ (WSRequestCache *)shareInstance;

/**
 清理所有请求缓存

 @param handler 回调
 */
- (void)clearAllCacheCompleteHandler:(void(^)(NSError *error))handler;


/**
 判断指定的URL是否存在缓存

 @param url      请求的URL
 @param resource 是否是资源文件

 @return YES ? 存在 ： 不存在
 */
- (BOOL)cacheDidExistWithUrl:(NSString *)url resource:(BOOL)resource;


/**
 保存API请求结果

 @param info    API返回的数据
 @param headers API Header信息
 @param url     请求的URL
 */
- (void)saveInfo:(NSDictionary *)info headers:(NSDictionary *)headers forUrl:(NSString *)url;


/**
 获取本地存在的请求数据信息,没有则返回nil

 @param url 请求的URL

 @return NSDictionary
 */
- (NSDictionary *)resultForUrl:(NSString *)url;


/**
 获取本地缓存的Header信息,没有则返回nil

 @param url 请求的URL

 @return NSDictionary
 */
- (NSDictionary *)headersForUrl:(NSString *)url;

@end
