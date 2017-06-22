//
//  HMTrainingPopularTopicsRequestTask.m
//  DDWebServiceDemo
//
//  Created by 李林刚 on 2017/6/22.
//  Copyright © 2017年 huami. All rights reserved.
//

#import "HMTrainingPopularTopicsRequestTask.h"

@implementation HMTrainingPopularTopicsRequestTask

- (NSString *)apiName{
    return @"/popularTopics";
}

- (WSHTTPMethod)requestMethod{
    return WSHTTPMethodGET;
}

- (NSError *)cumstomResposeRawObjectValidator {
    
    return nil;
}

@end
