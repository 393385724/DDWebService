//
//  WSNetworkMonitor.m
//  UDan
//
//  Created by lilingang on 16/10/30.
//  Copyright © 2016年 LiLingang. All rights reserved.
//

#import "WSNetworkMonitor.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>

NSString * const WSNetworkingReachabilityDidChangeNotification = @"com.alamofire.networking.reachability.change";
NSString * const WSNetworkingReachabilityNotificationStatusItem = @"AFNetworkingReachabilityNotificationStatusItem";

@implementation WSNetworkMonitor

+ (void)startMonitor{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        //当网络状态发生变化时会调用这个block
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WiFi");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"手机网络");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"没有网络");
                break;
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知网络");
                break;
            default:
                break;
        }
    }];
    [manager startMonitoring];
}

+ (void)stopMonitor{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager stopMonitoring];
}

+ (BOOL)isReachable{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    return manager.reachable || manager.networkReachabilityStatus == AFNetworkReachabilityStatusUnknown;
}

+ (BOOL)isWIFI{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    return [manager isReachableViaWiFi];
}

+ (BOOL)isWWAN{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    return [manager isReachableViaWWAN];
}

@end
