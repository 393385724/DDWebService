//
//  WSMultipartFormData.h
//  HMHealth
//
//  Created by lilingang on 16/11/29.
//  Copyright © 2016年 HM iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface WSMultipartFormData : NSObject<AFMultipartFormData>

@property (readonly) NSData *data;

@end
