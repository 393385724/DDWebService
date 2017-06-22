//
//  HMBaseRequestTask.m
//  DDWebServiceDemo
//
//  Created by 李林刚 on 2017/6/22.
//  Copyright © 2017年 huami. All rights reserved.
//

#import "HMBaseRequestTask.h"
#import "NSString+WebService.h"

@interface HMBaseRequestTask ()

@property (nonatomic, copy, readwrite) NSString *userId;

@property (nonatomic, copy, readwrite) NSString *apptoken;

@property (nonatomic, copy, readwrite) NSString *appname;

@end


@implementation HMBaseRequestTask

- (instancetype)init {
    self = [super init];
    if (self) {
        self.apptoken = @"TQVBQEZyQktGXip6SltGMl4qMl56RAQABAAAAAGsbS27QGZR16A1tNqtNtaSisLz2EvoXyxAnfuRskT1fphHmlv2DBYr5BTaQ6SFKjlRB-2-nBdLsehaicqVokL3ghxjvygv1rXOfJZDtvnq1uBLU-RtMd8Pg4YthadwNqUjWXbQmZIjmMvoTQIzvbUgUyrMWMMiKAjMj_yUDDXBGF4a1xpsDfjsLXzNyJSK38HSyvsplbA4k-TvIfgKHXf0";
        self.userId = @"1000000011";
        self.appname = @"com.huami.shushan";
    }
    return self;
}

- (NSURL *)baseUrl {
    return [NSURL URLWithString:@"https://api.amazfit.com/"];
}

- (NSTimeInterval)timeoutInterval {
    return 10;
}

- (WSRequestContentType)requestSerializerType {
    return WSRequestContentTypeJson;
}

- (void)configureHeaderField{
    [super configureHeaderField];
    [self.headerDictionary setObject:self.apptoken forKey:@"apptoken"];
    [self.headerDictionary setValue:self.appname forKey:@"appname"];
    [self.headerDictionary setValue:[self apiVersion] forKey:@"v"];
    [self.headerDictionary setValue:[NSString wsAppShortVersion] forKey:@"cv"];
    [self.headerDictionary setValue:@"AppStore" forKey:@"channel"];
}


@end
