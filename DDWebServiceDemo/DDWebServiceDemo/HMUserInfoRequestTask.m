//
//  HMUserInfoRequestTask.m
//  DDWebServiceDemo
//
//  Created by 李林刚 on 2017/6/22.
//  Copyright © 2017年 huami. All rights reserved.
//

#import "HMUserInfoRequestTask.h"

@implementation HMUserInfoRequestTask

- (NSString *)apiName{
    return [NSString stringWithFormat:@"/users/%@",self.userId];
}

- (WSHTTPMethod)requestMethod{
    return WSHTTPMethodGET;
}

- (id)jsonModelValidator {
    return @{
        @"healthInfo": @{
        },
        };
}

- (NSError *)cumstomResposeRawObjectValidator {
    
    return nil;
}

@end
