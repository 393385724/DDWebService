//
//  NSString+WebService.h
//  UDan
//
//  Created by lilingang on 16/9/29.
//  Copyright © 2016年 LiLingang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (WebService)

/**
 字符串MD5加密

 @return NSString
 */
- (NSString *)wsMD5String;


/**
 字符串Base64加密

 @return NSString
 */
- (NSString *)wsBase64EncodedString;

/**
 去掉特殊符号(\n \t \r)

 @return NSString
 */
- (NSString *)wsTrimSpecialCode;

/**
 返回当前请求的时间戳,浮点数字符串，毫秒

 @return NSString
 */
+ (NSString *)wsCallid;

/**
 返回系统时区,标准格式

 @return NSString
 */
+ (NSString *)wsSystemTimeZone;

/**
 返回国家编码，eg CN ...

 @return NSString
 */
+ (NSString *)wsCountryCode;

/**
 返回系统语言, eg zh\zh_TW\zh_HK ...

 @return NSString
 */
+ (NSString *)wsSystemLanguage;

/**
 返回设备类型，eg ios_phone or ios_pad
 
 @return NSString
 */
+ (NSString *)wsDeviceType;

/**
 返回app版本号

 @return NSString
 */
+ (NSString *)wsAppShortVersion;

/**
 返回是否是简体中文
 
 @return BOOL
 */
+ (BOOL)wsDeviceisSimplifiedChinese;
/**
 返回是否是中国
 
 @return BOOL
 */
+ (BOOL)wsDeviceisLocalChina;

@end
