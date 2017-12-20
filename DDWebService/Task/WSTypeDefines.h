//
//  WSTypeDefines.h
//  UDan
//
//  Created by lilingang on 8/12/16.
//  Copyright © 2016 LiLingang. All rights reserved.
//

#ifndef WSTypeDefines_h
#define WSTypeDefines_h

typedef NSString WSHTTPHeaderKey;

static WSHTTPHeaderKey * const WSHTTPHeaderKey_AcceptLanguage = @"Accept-Language";
static WSHTTPHeaderKey * const WSHTTPHeaderKey_UserAgent = @"User-Agent";

/**
 HTTP请求方式

 - WSHTTPMethodGET:    GET请求
 - WSHTTPMethodPOST:   POST请求
 - WSHTTPMethodPUT:    PUT请求
 - WSHTTPMethodDELETE: DELETE请求
 - WSHTTPMethodPATCH:  PATCH请求
 - WSHTTPMethodHEAD :  HEAD请求
 */
typedef NS_ENUM(NSUInteger, WSHTTPMethod) {
    WSHTTPMethodGET,
    WSHTTPMethodPOST,
    WSHTTPMethodPUT,
    WSHTTPMethodDELETE,
    WSHTTPMethodPATCH,
    WSHTTPMethodHEAD
};

/**
 请求体中Json最外层数据结构的类型
 
 - WSHTTPBodyJsonTypeDictionary: 字典结构
 - WSHTTPBodyJsonTypeArray:      数组结构
 */
typedef NS_ENUM(NSUInteger, WSHTTPBodyJsonType) {
    WSHTTPBodyJsonTypeDictionary,
    WSHTTPBodyJsonTypeArray,
};

/**
 上传数据方式
 
 - WSUploadDataMethodMultipart: Multipart形式上传
 - WSUploadDataMethodHTTPBody:  HTTP Body形式上传
 */
typedef NS_ENUM(NSUInteger, WSUploadDataMethod) {
    WSUploadDataMethodMultipart,
    WSUploadDataMethodHTTPBody,
};


/**
 请求支持的类型(Content-Type)

 - WSHTTPReqeustFormatBinary:   application/x-www-form-urlencoded
 - WSRequestContentTypeJson:    application/json
 - WSRequestContentTypeXPlist:  application/x-plist
 */
typedef NS_ENUM(NSUInteger, WSRequestContentType) {
    WSRequestContentTypeURLEncoded,
    WSRequestContentTypeJson,
    WSRequestContentTypeXPlist,
};

/**
 请求返回的数据类型(MIMEType)
 
 - WSResponseMIMETypeJson:          application/json、text/json、text/javascript
 - WSResponseMIMETypeXML:           application/xml、text/xml
 - WSResponseMIMETypePlist:         application/x-plist
 - WSResponseMIMETypeImage:         image/tiff、image/jpeg、image/gif、image/png、image/ico、image/x-icon、image/bmp、image/x-bmp、image/x-xbitmap、image/x-win-bitmap
 */
typedef NS_ENUM(NSUInteger, WSResponseMIMEType) {
    WSResponseMIMETypeJson,
    WSResponseMIMETypeXML,
    WSResponseMIMETypePlist,
    WSResponseMIMETypeImage,
};

#endif /* WSTypeDefines_h */
