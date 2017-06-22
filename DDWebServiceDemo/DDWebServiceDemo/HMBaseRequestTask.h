//
//  HMBaseRequestTask.h
//  DDWebServiceDemo
//
//  Created by 李林刚 on 2017/6/22.
//  Copyright © 2017年 huami. All rights reserved.
//

#import "WSRequestTask.h"

@interface HMBaseRequestTask : WSRequestTask

@property (nonatomic, copy, readonly) NSString *userId;

@property (nonatomic, copy, readonly) NSString *apptoken;

@property (nonatomic, copy, readonly) NSString *appname;

@end
