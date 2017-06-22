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

#pragma mark - 回调相关属性
/**
 设置网络回调接收者 同时实现block和delegate,则block设置会失效
 */
@property (nonatomic, weak) id<WSRequestCallbackProtocol> delegate;
/**
 下载进度条，只有当downloadPath不为nil的时候设置才有效
 */
@property (nonatomic, copy) WSProgressHandle progressHandle;
/**
 WSCompleteHandle 同时实现block和delegate,则block设置会失效
 */
@property (nonatomic, copy, readonly) WSCompleteHandle completeHandle;

#pragma mark - 请求之前的配置属性
/**
 完整的请求URL
 */
@property (nonatomic, readonly) NSString *requestUrlString;
/**
 自定义的Header
 */
@property (nonatomic, readonly) NSMutableDictionary <NSString *, NSString *> *headerDictionary;
/**
 自定义的上行参数, NSMutableDictionary or NSMutableArray 由bodyJsonType决定类型
 */
@property (nonatomic, readonly) id parameter;
/**
 是否允许截获重定向, 默认NO
 */
@property (nonatomic, assign) BOOL shouldHookRedirection;
/**
 是否是取消的状态
 */
@property (nonatomic, readonly, getter=isCancelled) BOOL cancelled;
/**
 当前是否正在执行
 */
@property (nonatomic, readonly, getter=isExecuting) BOOL executing;
/**
 下载数据路径
 */
@property (nonatomic, copy) NSString *downloadPath;

#pragma mark - 返回结果相关属性

/**
 当前的请求task
 */
@property (nonatomic, strong) NSURLSessionTask *requestTask;
/**
 请求结束返回的HTTP响应结果
 */
@property (nonatomic, readonly) NSHTTPURLResponse *httpURLResponse;
/**
 未请求结束前，获取改值为nil
 */
@property (nonatomic, readonly) NSInteger responseStatusCode;
/**
 服务器请求返回的原始数据
 */
@property (nonatomic, strong) id responseRawObject;
/**
 成功解析response中的单个对象or对象字典
 */
@property (nonatomic, strong) id resultItem;
/**
 成功解析出来的多个对象,model数组
 */
@property (nonatomic, strong) NSArray *resultItems;

#pragma mark - Common config
/**
 URL的Host eg. http://www.baidu.com
 */
- (NSURL *)baseUrl;

/**
 URI eg. /user/info
 */
- (NSString *)apiName;

/**
 api 版本号
 */
- (NSString *)apiVersion;

/**
 请求方法 @see WSHTTPMethod  default WSHTTPMethodGET
 */
- (WSHTTPMethod)requestMethod;

/**
 上传数据方式,@see WSUploadDataMethod 默认WSUploadDataMethodMultipart
 */
- (WSUploadDataMethod)uploadDataMethod;

/**
 上传文件子类需要实现该方法,上传文件给形式需要实现uploadDataMethod
 @code
 void(^dataBlock)(id<AFMultipartFormData>)  = ^(id<AFMultipartFormData> formData){
 [formData appendPartWithFileData:UIImageJPEGRepresentation(_image,1.0) name:@"file" fileName:@"pic.jpg" mimeType:@"image/jpeg"];
 };
 return dataBlock;
 @endcode
 */
- (WSConstructingBlock)constructingBodyBlock;

/**
 请求序列化 @see WSRequestContentType default WSRequestContentTypeURLEncoded
 */
- (WSRequestContentType)requestSerializerType;

/**
 请求体重最外层Json结构 @see WSHTTPBodyJsonType 默认 WSHTTPBodyJsonTypeDictionary
 */
- (WSHTTPBodyJsonType)bodyJsonType;

/**
 请求结果序列化 @see WSResponseMIMEType default WSResponseMIMETypeJson
 */
- (WSResponseMIMEType)responseSerializerType;

#pragma mark - Parameter config

/**
 校验自定义HEAD参数，避免由于参数错误导致发请求
 */
- (NSError *)validLocalHeaderField NS_REQUIRES_SUPER;

/**
 在HTTP报头添加的自定义参数 @see headerDictionary
 */
- (void)configureHeaderField NS_REQUIRES_SUPER;

/**
 校验上行参数，避免由于参数错误导致发请求
 */
- (NSError *)validLocalParameterField NS_REQUIRES_SUPER;

/**
 在HTTP请求中的参数 @see parameter
 */
- (void)configureParameterField NS_REQUIRES_SUPER;

#pragma mark - 策略
/**
 请求超时时间,默认60s
 */
- (NSTimeInterval)timeoutInterval;

/**
 允许使用数据流量, 默认YES
 */
- (BOOL)allowsCellularAccess;

#pragma mark - load
/**
 发送网络请求
 */
- (void)load NS_REQUIRES_SUPER;
/**
 发送网络请求并实现请求回调
 */
- (void)loadWithComplateHandle:(WSCompleteHandle)complateHandle NS_REQUIRES_SUPER;
/**
 取消网络请求
 */
- (void)cancel NS_REQUIRES_SUPER;

#pragma mark - response校验器

/**
 用于校验responseStatusCode是否合法有效解析
 */
- (BOOL)statusCodeValidator;
/**
 定义Response模板，对json做类型强校验
 */
- (id)jsonModelValidator;
/**
 自定义对服务器返回的请求结果做校验
 */
- (NSError *)cumstomResposeRawObjectValidator NS_REQUIRES_SUPER;
/**
 清理block，避免循环引用,子类及外部不可调用
 */
- (void)clearCompletionBlock;

@end
