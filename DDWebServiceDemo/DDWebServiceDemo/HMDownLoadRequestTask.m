//
//  HMDownLoadRequestTask.m
//  DDWebServiceDemo
//
//  Created by 李林刚 on 2017/6/22.
//  Copyright © 2017年 huami. All rights reserved.
//

#import "HMDownLoadRequestTask.h"

@implementation HMDownLoadRequestTask

- (NSURL *)baseUrl {
    return [NSURL URLWithString:@"https://cdn.awsbj0.fds.api.mi-img.com/huami-amazfit-production/1472024042_AG465BSaZMy7_2d29e68806c56e9c8433decaa23e19ab.mp3?GalaxyAccessKeyId=5471745289726&Expires=316832024042000&Signature=r4mPBb8apvVrc213wbIP8HdvtWI="];
}

@end
