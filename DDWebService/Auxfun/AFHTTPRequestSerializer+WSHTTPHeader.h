//
//  AFHTTPRequestSerializer+WSHTTPHeader.h
//  DDWebServiceDemo
//
//  Created by 李林刚 on 2017/12/20.
//  Copyright © 2017年 huami. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface AFHTTPRequestSerializer (WSHTTPHeader)

@property (class, nonatomic, strong) NSArray *wsIgnoreHeaderKeys;

@end
