//
//  ViewController.m
//  DDWebServiceDemo
//
//  Created by 李林刚 on 2017/4/25.
//  Copyright © 2017年 huami. All rights reserved.
//

#import "ViewController.h"

#import "HMUserInfoRequestTask.h"
#import "HMTrainingPopularTopicsRequestTask.h"
#import "HMDownLoadRequestTask.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self testDownLoad];
}

- (void)testUserInfo{
    HMUserInfoRequestTask *requestTask = [[HMUserInfoRequestTask alloc] init];
    [requestTask loadWithComplateHandle:^(WSRequestTask *request, BOOL isLocalResult, NSError *error) {
        
    }];
}

- (void)testTraining{
    HMTrainingPopularTopicsRequestTask *requestTask = [[HMTrainingPopularTopicsRequestTask alloc] init];
    [requestTask loadWithComplateHandle:^(WSRequestTask *request, BOOL isLocalResult, NSError *error) {
        
    }];
}

- (void)testDownLoad{
    HMDownLoadRequestTask *requestTask = [[HMDownLoadRequestTask alloc] init];
    requestTask.downloadPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"test.mp3"];
    [requestTask loadWithProgress:^(NSProgress *progress) {
        NSLog(@"total:%lld current:%lld",progress.totalUnitCount,progress.completedUnitCount);
    } complateHandle:^(WSRequestTask *request, BOOL isLocalResult, NSError *error) {
        
    }];
}

@end
