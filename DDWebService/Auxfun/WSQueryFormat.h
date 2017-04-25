//
//  WSQueryFormat.h
//  HMHealth
//
//  Created by 李林刚 on 2016/12/6.
//  Copyright © 2016年 HM iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 自定义query生成器
 */
@interface WSQueryFormat : NSObject

/**
 自定义query的拼装

 @param parameters 参数
 @return 拼装之后的query
 */
+ (NSString *)queryStringFromParameters:(NSDictionary *)parameters;

@end
