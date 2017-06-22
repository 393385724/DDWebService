//
//  AppDelegate.m
//  DDWebServiceDemo
//
//  Created by 李林刚 on 2017/4/25.
//  Copyright © 2017年 huami. All rights reserved.
//

#import "AppDelegate.h"
#import "WSNetworkConfig.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [WSNetworkConfig sharedInstance].shouldDetailLog = YES;
    return YES;
}
@end
