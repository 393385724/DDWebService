//
//  WSRequestAgent.m
//  FitRunning
//
//  Created by lilingang on 16/11/2.
//  Copyright © 2016年 LiLingang. All rights reserved.
//

#import "WSRequestAgent.h"
#import "WSRequestTask.h"

@interface WSRequestAgent ()

/**
 *  @brief 对request持有的池子
 */
@property (nonatomic, strong) NSMutableDictionary *requestPool;

/**
 *  @brief sessionTask池子
 */
@property (nonatomic, strong) NSMutableDictionary *taskPool;

/**
 *  @brief 存储一个request上次发起的时间
 */
@property (nonatomic, strong) NSMutableDictionary *lastUpdateDatePool;

@end

@implementation WSRequestAgent

+ (WSRequestAgent *)sharedInstance {
    static WSRequestAgent *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSArray *)allRequestIds{
    return [self.requestPool allKeys];
}

- (BOOL)shouldLoadRequestModel:(WSRequestTask *)requestModel{
    if (!requestModel) {
        return NO;
    }
    if (requestModel.shouldLoadLocalOnly) {
        return YES;
    }
    NSString *requestId = requestModel.taskIdentifier;
    NSDate *lastUpdate = [self.lastUpdateDatePool objectForKey:requestId];
    if (!lastUpdate) {
        if ([requestModel requestTTL] > 0) {
            [self.lastUpdateDatePool setObject:[NSDate date] forKey:requestId];
        }
        return YES;
    }
    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:lastUpdate];
    if (seconds > [requestModel requestTTL]) {
        [self.lastUpdateDatePool setObject:[NSDate date] forKey:requestId];
        return YES;
    }
    return NO;
}

- (void)addDataTask:(NSURLSessionTask *)dataTask requestModel:(WSRequestTask *)requestModel{
    if (!dataTask || !requestModel) {
        return;
    }
    NSString *requestId = requestModel.taskIdentifier;
    [self.taskPool setObject:dataTask forKey:requestId];
    [self.requestPool setObject:requestModel forKey:requestId];
}

- (NSURLSessionTask *)dataTaskWithRequestId:(NSString *)requestId{
    if (![requestId length] || !requestId) {
        return nil;
    }
    return [self.taskPool objectForKey:requestId];
}

- (WSRequestTask *)requestModelWithRequestId:(NSString *)requestId{
    if (![requestId length] || !requestId) {
        return nil;
    }
    return [self.requestPool objectForKey:requestId];
}

- (void)removeRequestId:(NSString *)requestId success:(BOOL)success{
    if (![requestId length] || !requestId) {
        return;
    }
    [self.taskPool removeObjectForKey:requestId];
    [self.requestPool removeObjectForKey:requestId];
    WSRequestTask *requestModel = [self requestModelWithRequestId:requestId];
    if (!success && [requestModel requestTTL] > 0) {
        [self.lastUpdateDatePool removeObjectForKey:requestId];
    }
}

#pragma mark - Getter and Setter

- (NSMutableDictionary *)requestPool{
    if (!_requestPool) {
        _requestPool = [[NSMutableDictionary alloc] init];
    }
    return _requestPool;
}

- (NSMutableDictionary *)taskPool{
    if (!_taskPool) {
        _taskPool = [[NSMutableDictionary alloc] init];
    }
    return _taskPool;
}

- (NSMutableDictionary *)lastUpdateDatePool{
    if (!_lastUpdateDatePool) {
        _lastUpdateDatePool = [[NSMutableDictionary alloc] init];
    }
    return _lastUpdateDatePool;
}

@end
