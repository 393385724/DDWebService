//
//  NSError+WebServie.m
//  HMRequestDemo
//
//  Created by lilingang on 15/7/23.
//  Copyright (c) 2015年 lilingang. All rights reserved.
//

#import "NSError+WebServie.h"
#import <objc/runtime.h>

static const void *WSErrorIsCustomNameKey = &WSErrorIsCustomNameKey;

static const void *WSErrorPromptNameKey = &WSErrorPromptNameKey;

@implementation NSError (WebServie)

+ (nonnull NSError *)wsErrorWithDomain:(nullable NSErrorDomain)domain
                                  code:(NSInteger)code
                                prompt:(nonnull NSString *)prompt
                              userInfo:(nullable NSDictionary *)userInfo{
    NSError *error = [NSError errorWithDomain:domain code:code userInfo:userInfo];
    error.isCustom = YES;
    error.prompt = prompt;
    return error;
}

+ (nonnull NSError *)wsLocalHeaderErrorKey:(nonnull NSString *)key{
    NSString *prompt = [NSString stringWithFormat:@"[%@] required header or invalid header",key];
    return [self wsErrorWithDomain:@"wsLocalHeaderError" code:NSURLErrorBadURL prompt:prompt userInfo:@{NSLocalizedDescriptionKey:prompt}];
}

+ (nonnull NSError *)wsLocalParamErrorKey:(nonnull NSString *)key{
    NSString *prompt = [NSString stringWithFormat:@"[%@] required parameter or invalid parameter",key];
    return [self wsErrorWithDomain:@"wsLocalParamError" code:NSURLErrorBadURL prompt:prompt userInfo:@{NSLocalizedDescriptionKey:prompt}];
}

+ (nonnull NSError *)wsTooManyTimeError {
    NSString *prompt = @"request in limit time";
    return [self wsErrorWithDomain:@"com.huami.request.time" code:NSURLErrorCancelled prompt:prompt userInfo:@{NSLocalizedDescriptionKey:prompt}];
}


+ (nonnull NSError *)wsResponseFormatError {
    NSString *prompt = @"response format error (null or not json format)";
    return [self wsErrorWithDomain:@"com.huami.response.validation" code:NSURLErrorBadServerResponse prompt:prompt userInfo:@{NSLocalizedDescriptionKey:prompt}];
}

#pragma mark - Private Methods


- (NSString *)debugDescription{
    NSLog(@"domain:%@ prompt:%@",self.domain,self.prompt);
    return [super debugDescription];
}

#pragma mark - Getter and Setter

- (BOOL)isCustom{
    return [objc_getAssociatedObject(self, WSErrorIsCustomNameKey) boolValue];
}

- (void)setIsCustom:(BOOL)isCustom{
    objc_setAssociatedObject(self, WSErrorIsCustomNameKey, @(isCustom), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)prompt {
    return objc_getAssociatedObject(self, WSErrorPromptNameKey);
}

- (void)setPrompt:(NSString *)prompt{
    objc_setAssociatedObject(self, WSErrorPromptNameKey, prompt, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
