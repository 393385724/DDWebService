//
//  WSRequestCache.m
//  UDan
//
//  Created by lilingang on 16/9/28.
//  Copyright © 2016年 LiLingang. All rights reserved.
//

#import "WSRequestCache.h"
#import "NSString+WebService.h"

static NSString * const WSCache_CacheFolder = @"WSCache";
static NSString * const WSCache_CacheFolder_API = @"WSAPI";
static NSString * const WSCache_CacheFolder_Resource = @"WSResource";


@interface WSRequestCache ()

@property (nonatomic, copy) NSString *wsCacheFolder;
@property (nonatomic, copy) NSString *wsAPIFolder;
@property (nonatomic, copy) NSString *wsResourceFolder;

@end

@implementation WSRequestCache

#pragma mark - Public Methods

+ (WSRequestCache *)shareInstance{
    static dispatch_once_t pred;
    static WSRequestCache *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)clearAllCacheCompleteHandler:(void(^)(NSError *error))handler {
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:self.wsCacheFolder error:&error];
    self.wsCacheFolder = nil;
    self.wsAPIFolder = nil;
    self.wsResourceFolder = nil;
    if (handler) {
        handler(error);
    }
}

- (BOOL)cacheDidExistWithUrl:(NSString *)url resource:(BOOL)resource {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self cachePathWithUrl:url resource:resource]];
}

- (void)saveInfo:(NSDictionary *)info headers:(NSDictionary *)headers forUrl:(NSString *)url {
    if (!url) {
        return;
    }
    if (info) {
        [info writeToFile:[self cachePathWithUrl:url resource:NO] atomically:YES];
    }
    if (headers) {
        [headers writeToFile:[self cacheHeaderPathWithUrl:url resource:NO] atomically:YES];
    }
}

- (NSDictionary *)resultForUrl:(NSString *)url {
    if (![self cacheDidExistWithUrl:url resource:NO]) {
        return nil;
    }
    NSString *cachePath = [self cachePathWithUrl:url resource:NO];
    NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:cachePath];
    if (info == nil) {
        [self removeCacheForUrl:url resource:NO];
        return nil;
    }
    return  info;
}

- (NSDictionary *)headersForUrl:(NSString *)url {
    NSString *headerPath = [self cacheHeaderPathWithUrl:url resource:NO];
    NSDictionary *headerInfo = [NSDictionary dictionaryWithContentsOfFile:headerPath];
    if (nil == headerInfo) {
        return nil;
    }
    return  headerInfo;
}

#pragma mark - Private Methods

- (NSString *)cachePathWithUrl:(NSString *)url resource:(BOOL)resource {
    NSString *fileName = [url wsMD5String];
    NSString *filePath = resource ? [self.wsResourceFolder stringByAppendingPathComponent:fileName] : [self.wsAPIFolder stringByAppendingPathComponent:fileName];
    return filePath;
}

- (NSString *)cacheHeaderPathWithUrl:(NSString *)url resource:(BOOL)resource {
    NSString *fileName = [[url wsMD5String] stringByAppendingPathExtension:@"headers"];
    NSString *filePath = resource ? [self.wsResourceFolder stringByAppendingPathComponent:fileName] : [self.wsAPIFolder stringByAppendingPathComponent:fileName];
    return filePath;
}

- (void)removeCacheForUrl:(NSString *)url resource:(BOOL)resource {
    [[NSFileManager defaultManager] removeItemAtPath:[self cachePathWithUrl:url resource:resource] error:NULL];
    [[NSFileManager defaultManager] removeItemAtPath:[self cacheHeaderPathWithUrl:url resource:resource] error:NULL];
}

#pragma mark - Getter And Setter

- (NSString *)wsCacheFolder{
    if (!_wsCacheFolder) {
        _wsCacheFolder = [[self cachesPath] stringByAppendingPathComponent:WSCache_CacheFolder];
        if (![[NSFileManager defaultManager] fileExistsAtPath:_wsCacheFolder]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:_wsCacheFolder withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return _wsCacheFolder;
}

- (NSString *)wsAPIFolder{
    if (!_wsAPIFolder) {
        _wsAPIFolder = [[self cachesPath] stringByAppendingPathComponent:WSCache_CacheFolder_API];
        if (![[NSFileManager defaultManager] fileExistsAtPath:_wsAPIFolder]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:_wsAPIFolder withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return _wsAPIFolder;
}

- (NSString *)wsResourceFolder{
    if (!_wsResourceFolder) {
        _wsResourceFolder = [[self cachesPath] stringByAppendingPathComponent:WSCache_CacheFolder_Resource];
        if (![[NSFileManager defaultManager] fileExistsAtPath:_wsResourceFolder]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:_wsResourceFolder withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return _wsResourceFolder;
}

- (NSString *)cachesPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths objectAtIndex:0];
    return cachesDir;
}

@end
