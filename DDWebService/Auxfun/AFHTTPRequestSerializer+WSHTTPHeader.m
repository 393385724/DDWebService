//
//  AFHTTPRequestSerializer+WSHTTPHeader.m
//  DDWebServiceDemo
//
//  Created by 李林刚 on 2017/12/20.
//  Copyright © 2017年 huami. All rights reserved.
//

#import "AFHTTPRequestSerializer+WSHTTPHeader.h"
#import <objc/runtime.h>

static const void *WSIgnoreHeaderKeysKey = &WSIgnoreHeaderKeysKey;

void WSHTTPSwizzleMethod(Class cls, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(cls,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(cls,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}


@implementation AFHTTPRequestSerializer (WSHTTPHeader)

+ (void)load {
    WSHTTPSwizzleMethod([self class], @selector(setValue:forHTTPHeaderField:), @selector(ws_setValue:forHTTPHeaderField:));
}

- (void)ws_setValue:(NSString *)value
forHTTPHeaderField:(NSString *)field {
    NSArray *ignoreHeaderKeys = [self class].wsIgnoreHeaderKeys;
    if (ignoreHeaderKeys && [ignoreHeaderKeys containsObject:field]) {
        return;
    }
    [self ws_setValue:value forHTTPHeaderField:field];
}

#pragma mark - Setter and Getter

+ (NSArray *)wsIgnoreHeaderKeys {
    return objc_getAssociatedObject([self class], WSIgnoreHeaderKeysKey);
}

+ (void)setWsIgnoreHeaderKeys:(NSArray *)wsIgnoreHeaderKeys {
    objc_setAssociatedObject([self class], WSIgnoreHeaderKeysKey, wsIgnoreHeaderKeys, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
