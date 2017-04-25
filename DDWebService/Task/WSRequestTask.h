//
//  WSRequestTask.h
//  FitRunning
//
//  Created by lilingang on 16/11/2.
//  Copyright © 2016年 LiLingang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "NSError+WebServie.h"
#import "WSTypeDefines.h"
#import "WSRequestCallbackProtocol.h"

/**
 *  @brief 实现MultipartFormData
 *
 *  @param formData AFMultipartFormData协议
 */
typedef void (^WSConstructingBlock)(id<AFMultipartFormData> formData);


/**
 *  @brief api请求的基类描述
 *  @note 任何api都可以继承该基类并配置参数完成一次请求
 */
@interface WSRequestTask : NSObject

#pragma mark - CallBack Propertys

/**@brief 强烈建议这种形式！！！ 设置网络回调接收者 同时实现block和delegate,则block设置会失效*/
@property (nonatomic, weak) id<WSRequestCallbackProtocol> delegate;

/**@brief  WSProgressHandle 只有上传和下载data时候才是有效的*/
@property (nonatomic, copy) WSProgressHandle progressHandle;

/**@brief  WSCompleteHandle 同时实现block和delegate,则block设置会失效*/
@property (nonatomic, copy, readonly) WSCompleteHandle completeHandle;

/**@brief  是否允许截获重定向, 默认NO*/
@property (nonatomic, assign) BOOL shouldHookRedirection;

#pragma mark - Cache Propertys

/**@brief 请求的唯一标识，默认为完整的URL，子类可自定义*/
@property (nonatomic, copy, readonly) NSString *taskIdentifier;

/**@brief  HTTP请求的完整的URLString eg.baseUrl/apiName*/
@property (nonatomic, copy, readonly) NSString *requestUrlString;

/**@brief  是否是加载的本地数据 default NO*/
@property (nonatomic, assign) BOOL shouldLoadLocalOnly;

/**@brief  是否正在加载数据*/
@property (nonatomic, assign, readonly, getter=isLoading) BOOL loading;

/**@brief 自定义的HEADER*/
@property (nonatomic, strong, readonly) NSMutableDictionary *headerDictionary;

/**@brief 自定义的parameter(可变字典or数组),根据bodyJsonType确定类型*/
@property (nonatomic, strong, readonly) id parameter;


/** @brief  请求结束返回的HTTP响应结果*/
@property (nonatomic, strong, readonly) NSHTTPURLResponse *httpURLResponse;

/** @brief  请求结束返回的单个数据 eg 原始数据 or 已经解析的对象*/
@property (nonatomic, strong) id resultItem;

/** @brief  请求结束返回的一组数据 eg 解析成model数组*/
@property (nonatomic, strong) NSArray *resultItems;

#pragma mark - Common config
/**
 * @brief  URL的Host eg. http://www.baidu.com
 */
- (NSURL *)baseUrl;

/**@brief  api名字 eg. /user/info*/
- (NSString *)apiName;

/**@brief  HTTP请求格式, default Json*/
- (WSHTTPReqeustFormat)requestFormat;

/**@brief  HTTP请求方法, default GET*/
- (WSHTTPMethod)requestMethod;

/**@brief api版本号*/
- (NSString *)apiVersion;

/**@brief 校验上行参数，避免由于参数错误导致发请求*/
- (NSError *)validLocalHeaderField NS_REQUIRES_SUPER;

/**@brief 在HTTP报头添加的自定义参数*/
- (void)configureHeaderField NS_REQUIRES_SUPER;

/**@brief 校验上行参数，避免由于参数错误导致发请求*/
- (NSError *)validLocalParameterField NS_REQUIRES_SUPER;

/**@brief 在HTTP Body中上行参数Json Model结构(Dictionary or Array)，默认HMHTTPBodyJsonTypeDictionary*/
- (HMHTTPBodyJsonType)bodyJsonType;

/**@brief 在HTTP请求中的参数*/
- (void)configureParameterField NS_REQUIRES_SUPER;

#pragma mark - Data config

/**@brief  上传Data数据方式, default WSRequestDataMethodNone*/
- (WSRequestDataMethod)requestDataMethod;

/**@brief 上传文件子类需要实现该方法,上传文件给形式需要实现requestDataUploadMethod
 @code
 void(^dataBlock)(id<AFMultipartFormData>)  = ^(id<AFMultipartFormData> formData){
 [formData appendPartWithFileData:UIImageJPEGRepresentation(_image,1.0) name:@"file" fileName:@"pic.jpg" mimeType:@"image/jpeg"];
 };
 return dataBlock;
 @endcode
 @see [self requestDataMethod]
 */
- (WSConstructingBlock)constructingBodyBlock;

/** @brief 文件下载的最终路径*/
- (NSURL *)downLoadDestinationPath;

#pragma mark - 策略
/**
 * @brief  请求超时的时间，默认采用统一session时间
 */
- (NSTimeInterval)timeoutInterval;

/**
 * @brief  允许发送请求的最小时间间隔,默认0
 */
- (NSTimeInterval)requestTTL;

/**
 *  @brief 是否允许对请求做缓存，默认NO
 *
 *  @return YES ? 允许 ：不允许
 */
- (BOOL)shouldAllowCache;

#pragma mark - load

///**@brief 本地加载数据,纯get请求有效*/
//- (void)loadLocalWithComplateHandle:(WSCompleteHandle)complateHandle NS_REQUIRES_SUPER;

/**@brief 发送网络请求*/
- (void)load NS_REQUIRES_SUPER;

/**@brief 发送网络请求,并实现回调*/
- (void)loadWithComplateHandle:(WSCompleteHandle)complateHandle NS_REQUIRES_SUPER;

/**@brief 取消当前的请求*/
- (void)cancel NS_REQUIRES_SUPER;

#pragma mark - Web Servcie Response

/** Web Servcie Response 最后调用super*/
- (void)requestDidSuccessWithURLResponse:(NSHTTPURLResponse *)urlResponse responseObject:(id)responseObject NS_REQUIRES_SUPER;

- (void)requestDidFailWithURLResponse:(NSHTTPURLResponse *)urlResponse responseObject:(id)responseObject error:(NSError *)error NS_REQUIRES_SUPER;

@end
