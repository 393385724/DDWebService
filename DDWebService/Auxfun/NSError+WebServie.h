//
//  NSError+WebServie.h
//  HMRequestDemo
//
//  Created by lilingang on 15/7/23.
//  Copyright (c) 2015年 lilingang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (WebServie)

@property (nonatomic, assign) BOOL isCustom;

@property (nonnull, nonatomic, copy) NSString *prompt;

+ (nonnull NSError *)wsErrorWithDomain:(nullable NSErrorDomain)domain
                          code:(NSInteger)code
                        prompt:(nonnull NSString *)prompt
                      userInfo:(nullable NSDictionary *)userInfo;

+ (nonnull NSError *)wsLocalHeaderErrorKey:(nonnull NSString *)key;

+ (nonnull NSError *)wsLocalParamErrorKey:(nonnull NSString *)key;

+ (nonnull NSError *)wsTooManyTimeError;

+ (nonnull NSError *)wsResponseFormatError;

@end
