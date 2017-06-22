//
//  WSRequestAgent.m
//  FitRunning
//
//  Created by lilingang on 16/11/2.
//  Copyright © 2016年 LiLingang. All rights reserved.
//

#import "WSRequestAgent.h"
#import "WSRequestTask.h"
#include <pthread/pthread.h>

#define InitLock()      pthread_mutex_init(&_lock, NULL);
#define Lock()          pthread_mutex_lock(&_lock);
#define Unlock()        pthread_mutex_unlock(&_lock);

@interface WSRequestAgent ()

/**
 *  @brief 对request持有的池子
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, WSRequestTask *> *requestPool;

/**
 线程锁
 */
@property (nonatomic, assign) pthread_mutex_t lock;

@end

@implementation WSRequestAgent

- (instancetype)init {
    self = [super init];
    if (self) {
        _requestPool = [[NSMutableDictionary alloc] init];
        InitLock();
    }
    return self;
}

- (NSArray <WSRequestTask *>*)allRequestModles{
    Lock()
    NSArray <WSRequestTask *> *models = [self.requestPool allValues];
    Unlock()
    return models;
}

- (void)addRequestModel:(WSRequestTask *)requestModel{
    Lock()
    if (!requestModel) {
        return;
    }
    [self.requestPool setObject:requestModel forKey:[@(requestModel.requestTask.taskIdentifier) stringValue]];
    Unlock()
}

- (WSRequestTask *)requestModelWithTaskIdentifier:(NSString *)taskIdentifier {
    Lock()
    if (![taskIdentifier length] || !taskIdentifier) {
        return nil;
    }
    WSRequestTask *task = [self.requestPool objectForKey:taskIdentifier];
    Unlock();
    return task;
}

- (void)removeRequestModel:(WSRequestTask *)requestModel {
    Lock()
    if (!requestModel) {
        return;
    }
    [self.requestPool removeObjectForKey:[@(requestModel.requestTask.taskIdentifier) stringValue]];
    Unlock()
}

@end
