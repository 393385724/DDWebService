//
//  WSTypeDefines.h
//  UDan
//
//  Created by lilingang on 8/12/16.
//  Copyright © 2016 LiLingang. All rights reserved.
//

#ifndef WSTypeDefines_h
#define WSTypeDefines_h


/**
 HTTP请求方式

 - WSHTTPMethodGET:    GET请求
 - WSHTTPMethodPOST:   POST请求
 - WSHTTPMethodPUT:    PUT请求
 - WSHTTPMethodDELETE: DELETE请求
 - WSHTTPMethodPATCH:  PATCH请求
 */
typedef NS_ENUM(NSUInteger, WSHTTPMethod) {
    WSHTTPMethodGET,
    WSHTTPMethodPOST,
    WSHTTPMethodPUT,
    WSHTTPMethodDELETE,
    WSHTTPMethodPATCH
};

/**
 Data数据请求形式

 - WSRequestDataMethodNone:      没有Data数据
 - WSRequestDataMethodMultipart: Multipart形式上传
 - WSRequestDataMethodBodyData:  HTTP Body形式上传
 - WSRequestDataMethodDownload:  下载数据
 */
typedef NS_ENUM(NSUInteger, WSRequestDataMethod) {
    WSRequestDataMethodNone,
    WSRequestDataMethodMultipart,
    WSRequestDataMethodBodyData,
    WSRequestDataMethodDownload,
};


/**
 请求格式

 - WSHTTPReqeustFormatBinary: 二进制
 - WSHTTPReqeustFormatJson:   JsonModel
 - WSHTTPReqeustFormatPlist:  Plist
 */
typedef NS_ENUM(NSUInteger, WSHTTPReqeustFormat) {
    WSHTTPReqeustFormatBinary,
    WSHTTPReqeustFormatJson, //默认GET/HEAD/DELETE参数都放在Query，其他请求方式参数放在body
    WSHTTPReqeustFormatPlist,
};


/**
 HTTP Body中json结构

 - HMHTTPBodyJsonTypeDictionary: 字典结构
 - HMHTTPBodyJsonTypeArray:      数组结构
 */
typedef NS_ENUM(NSUInteger, HMHTTPBodyJsonType) {
    HMHTTPBodyJsonTypeDictionary,
    HMHTTPBodyJsonTypeArray,
};

#endif /* WSTypeDefines_h */
