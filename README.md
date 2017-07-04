# DDWebService 基于集约型封装的离散型框架

## 1、网络层现有架构模式：离散型、集约型
#### (1)离散型介绍：
离散型API调用是这样的，一个API对应于一个RequestTask，然后这个RequestTask只需要提供参数就能起飞，API名字、着陆方式都已经集成入RequestTask中,离散型API调用方式：
> @property (nonatomic, strong) HMBaseRequestTask *requestTask; 
> // getter 
> - (HMBaseRequestTask *)requestTask {   
>    if (_requestTask == nil)  {   
>        _requestTask = [[HMBaseRequestTask alloc] init];              
>        _requestTask = self;   
>    }   
>    return _requestTask;  
> }  
> // 使用的时候就这么写：  
> [requestTask load];  
>
#### (2)集约型介绍：
API调用其实就是所有API的调用只有一个类，然后这个类接收API名字，API参数，以及回调着陆点（可以是target-action，或者block，或者delegate等各种模式的着陆点）作为参数。然后执行类似startRequest
这样的方法，它就会去根据这些参数起飞去调用API了，然后获得API数据之后再根据指定的着陆点去着陆。集约型API调用方式：
> [APIRequest startRequestWithApiName:@"itemList.v1" params:params success:@selector(success:) fail:@selector(fail:) target:self];
#### (3)集约型与离散型对比
集约型API调用和离散型API调用这两者实现方案不是互斥的，单看下层，大家都是集约型。因为发起一个API请求之后，除去业务相关的部分（比如参数和API名字等），剩下的都是要统一处理的：加密，URL拼接，API请求的起飞和着陆。
然而对于整个网络层来说，尤其是业务方使用的那部分，我倾向于提供离散型的API调用方式，并不建议在业务层的代码直接使用集约型的API调用方式。原因如下：

原因1：离散型的API使用可以让使用者更多时间去关心业务，而不必关心API是怎么实现的。因为离散型API会把url、请求的method、必要的参数封装在ReuqestTask中，对外只需要暴露业务相关参数即可，使用者只需要关心业务。而集约型API设计还需要使用方知道请求的API、请求方式

原因2：便于针对某个API请求来进行AOP。

原因3：离散型的API，更易于管理请求的发起和取消等操作，一个ReuqestTask封装一个API，使用相关的Task取消即可

原因4：离散型的API调用方式能够最大程度地给业务方提供灵活性。比如根据不同的api是否使用缓存、翻页机制、参数校验，在离散型的requestTask里面实现就会非常轻松。

综上，关于集约型的API调用和离散型的API调用，我倾向于这样：对外提供一个BaseReuqestTask来给业务方做派生，在Client里面采用集约化的手段组装请求，放飞请求，然而业务方调用API的时候，则是以离散的API调用方式来调用。

## 2、案例
#### （1）GET请求，(其他请求类似，只不过更改配置参数)
创建一个请求 eg HMGetRequestTask
</code></p>
 @implementation HMGetRequestTask
 
 #pragma mark - Common config
 
 - (NSURL *)baseUrl {
 
         return [NSURL URLWithString:@"http://www.baidu.com"];
         
 }
 
 - (NSString *)apiName {
 
     return @"user.json";
     
 }
 
 - (NSString *)apiVersion {
 
     return @"0.0";
 
 }
 
 - (WSHTTPMethod)requestMethod {
     return WSHTTPMethodGET;
 }
 
 - (WSRequestContentType)requestSerializerType {
>    return WSRequestContentTypeJson;
 }
 
 - (WSHTTPBodyJsonType)bodyJsonType {
     return WSHTTPBodyJsonTypeDictionary;
 }
 
 - (WSResponseMIMEType)responseSerializerType {
     return WSResponseMIMETypeJson;
 }

 #pragma mark -  Parameter
 
 - (NSError *)validLocalHeaderField{
     return nil;
 }

 - (void)configureHeaderField{
 }

 - (NSError *)validLocalParameterField{
     return nil;
 }

 - (void)configureParameterField{
 
 }

 #pragma mark - response validator

 - (NSError *)cumstomResposeRawObjectValidator {
     处理解析返回的数据
     return nil;
 }

 #pragma mark - 错误处理

 - (void)handleError:(NSError *)error {
  
  错误处理
  
  }

</code></p>

使用的时候仅需引入HMGetRequestTask.h创建一个请求，发起等待回收即可
<p><code>
 HMGetRequestTask *task = [[HMGetRequestTask alloc] init];  
 
 [task loadWithComplateHandle:^(WSRequestTask *request, BOOL isLocalResult, NSError *error) { 
 
 回调结束处理  

}];
</code></p>
