//
//  WSMultipartFormData.m
//  HMHealth
//
//  Created by lilingang on 16/11/29.
//  Copyright © 2016年 HM iOS. All rights reserved.
//

#import "WSMultipartFormData.h"

@interface WSMultipartFormData ()

@property (nonatomic, strong, readwrite) NSData *data;

@end

@implementation WSMultipartFormData

- (BOOL)appendPartWithFileURL:(NSURL *)fileURL
                         name:(NSString *)name
                        error:(NSError * __autoreleasing *)error{
    NSParameterAssert(fileURL);
    return [self appendPartWithFileURL:fileURL name:name fileName:@"" mimeType:@"" error:error];
}

- (BOOL)appendPartWithFileURL:(NSURL *)fileURL
                         name:(NSString *)name
                     fileName:(NSString *)fileName
                     mimeType:(NSString *)mimeType
                        error:(NSError * __autoreleasing *)error{
    NSParameterAssert(fileURL);
    self.data = [NSData dataWithContentsOfURL:fileURL];
    return YES;
}

- (void)appendPartWithInputStream:(NSInputStream *)inputStream
                             name:(NSString *)name
                         fileName:(NSString *)fileName
                           length:(int64_t)length
                         mimeType:(NSString *)mimeType{
    NSParameterAssert(name);
    NSParameterAssert(fileName);
    NSParameterAssert(mimeType);
    NSMutableData *tmpData = [NSMutableData data];
    uint8_t buf[length];
    NSInteger len = [inputStream read:buf maxLength:(NSInteger)length];
    [tmpData appendBytes:(const void *)buf length:(NSInteger)length];
    if (len == 0) {
        NSLog(@"NSInputStream end");
    } else if (len == -1){
        NSLog(@"NSInputStream error");
    }
    self.data = [tmpData copy];
}

- (void)appendPartWithFileData:(NSData *)data
                          name:(NSString *)name
                      fileName:(NSString *)fileName
                      mimeType:(NSString *)mimeType{
    NSParameterAssert(data);
    self.data = data;
}

- (void)appendPartWithFormData:(NSData *)data
                          name:(NSString *)name{
    NSParameterAssert(data);
    self.data = data;
}

- (void)appendPartWithHeaders:(NSDictionary *)headers
                         body:(NSData *)body{
    NSParameterAssert(body);
    self.data = body;
}

- (void)throttleBandwidthWithPacketSize:(NSUInteger)numberOfBytes
                                  delay:(NSTimeInterval)delay{
    NSLog(@"HTTP Body 不需要实现该协议,只是为了消除警告!!!");
}

@end
