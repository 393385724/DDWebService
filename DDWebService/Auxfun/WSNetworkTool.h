//
//  WSNetworkTool.h
//  DDWebServiceDemo
//
//  Created by 李林刚 on 2017/6/21.
//  Copyright © 2017年 huami. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSNetworkTool : NSObject

/**
 根据指定的模型校验当前数据结构是否有效
 
 @param jsonObject 真实Json数据
 @param validJsonModel 合法Json模型
 @return YES ？ 有效 ： 无效
 */
+ (BOOL)validateJsonObject:(id)jsonObject withValidJsonModel:(id)validJsonModel;


/**
 用于存储断点恢复的文件夹
 
 @return NSString
 */
+ (NSString *)resumeDownloadDataTempCacheFolder;
    

/**
 用于存储断点回复的数据
 
 @param downloadPath 实际下载数据的地址
 @return 临时缓存路径
 */
+ (NSURL *)resumeDownloadDataTempPathForDownloadPath:(NSString *)downloadPath;


/**
 处理为合法的下载路径，保证下载的路径始终是一个文件路径
 
 @param downloadPath 下载路径
 @param downLoadURL 下载URL
 @return 合法路径
 */
+ (NSString *)validDownloadPathWithDownloadPath:(NSString *)downloadPath downloadURL:(NSURL *)downLoadURL;

/**
 根据制定的下载路径，判断是否允许断点下载
 
 @param downloadPath 下载路径
 @return YES ？ 允许 ： 不允许
 */
+ (BOOL)canResumeDwonloadDataWithDownloadPath:(NSString *)downloadPath;

/**
 将Query字符串转为字典
 
 @param queryString NSString
 @return NSDictionary
 */
+ (NSDictionary *)dictionaryWithQueryString:(NSString *)queryString;

/**
 通过hostName解析出IP地址

 @param hostName 需要解析的host
 @return 解析成功返回IP，失败则为nil
 */
+ (NSString *)ipAddressWithHostName:(const NSString *)hostName;

@end
