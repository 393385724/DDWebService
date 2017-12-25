//
//  WSNetworkTool.m
//  DDWebServiceDemo
//
//  Created by 李林刚 on 2017/6/21.
//  Copyright © 2017年 huami. All rights reserved.
//

#import "WSNetworkTool.h"
#import "NSString+WebService.h"
#include <netdb.h>
#include <ifaddrs.h>
#include <arpa/inet.h>

static NSString * const WSNetworkResumeDownloadDataTempCacheFolder = @"WSResumeTemp";


@implementation WSNetworkTool

+ (BOOL)validateJsonObject:(id)jsonObject withValidJsonModel:(id)validJsonModel {
    if ([jsonObject isKindOfClass:[NSDictionary class]] &&
        [validJsonModel isKindOfClass:[NSDictionary class]]) {
        NSDictionary * dict = jsonObject;
        NSDictionary * validator = validJsonModel;
        BOOL result = YES;
        NSEnumerator * enumerator = [validator keyEnumerator];
        NSString * key;
        while ((key = [enumerator nextObject]) != nil) {
            id value = dict[key];
            id format = validator[key];
            if ([value isKindOfClass:[NSDictionary class]]
                || [value isKindOfClass:[NSArray class]]) {
                result = [self validateJsonObject:value withValidJsonModel:format];
                if (!result) {
                    break;
                }
            } else {
                if ([value isKindOfClass:format] == NO &&
                    [value isKindOfClass:[NSNull class]] == NO) {
                    result = NO;
                    break;
                }
            }
        }
        return result;
    } else if ([jsonObject isKindOfClass:[NSArray class]] &&
               [validJsonModel isKindOfClass:[NSArray class]]) {
        NSArray * validatorArray = (NSArray *)validJsonModel;
        if (validatorArray.count > 0) {
            NSArray * array = jsonObject;
            NSDictionary * validator = validJsonModel[0];
            for (id item in array) {
                BOOL result = [self validateJsonObject:item withValidJsonModel:validator];
                if (!result) {
                    return NO;
                }
            }
        }
        return YES;
    } else if ([jsonObject isKindOfClass:validJsonModel]) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString *)resumeDownloadDataTempCacheFolder {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    static NSString *cacheFolder;
    if (!cacheFolder) {
        NSString *cacheDir = NSTemporaryDirectory();
        cacheFolder = [cacheDir stringByAppendingPathComponent:WSNetworkResumeDownloadDataTempCacheFolder];
    }
    NSError *error = nil;
    if(![fileManager createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:&error]) {
        cacheFolder = nil;
    }
    return cacheFolder;
}


+ (NSURL *)resumeDownloadDataTempPathForDownloadPath:(NSString *)downloadPath {
    NSString *tempPath = nil;
    NSString *md5URLString = [downloadPath wsMD5String];
    tempPath = [[self resumeDownloadDataTempCacheFolder] stringByAppendingPathComponent:md5URLString];
    return [NSURL fileURLWithPath:tempPath];
}

+ (NSString *)validDownloadPathWithDownloadPath:(NSString *)downloadPath downloadURL:(NSURL *)downLoadURL{
    BOOL isDirectory;
    if(![[NSFileManager defaultManager] fileExistsAtPath:downloadPath isDirectory:&isDirectory]) {
        isDirectory = NO;
    }
    NSString *downloadTargetPath;
    //确定本地的存储路径始终是一个文件而不是文件夹
    if (isDirectory) {
        NSString *fileName = [downLoadURL lastPathComponent];
        downloadTargetPath = [NSString pathWithComponents:@[downloadPath, fileName]];
    } else {
        downloadTargetPath = downloadPath;
    }
    return downloadTargetPath;
}

+ (BOOL)canResumeDwonloadDataWithDownloadPath:(NSString *)downloadPath {
    // AFN use `moveItemAtURL` to move downloaded file to target path,
    // this method aborts the move attempt if a file already exist at the path.
    // So we remove the exist file before we start the download task.
    // https://github.com/AFNetworking/AFNetworking/issues/3775
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:downloadPath error:nil];
    }
    
    BOOL resumeDataFileExists = [[NSFileManager defaultManager] fileExistsAtPath:[WSNetworkTool resumeDownloadDataTempPathForDownloadPath:downloadPath].path];
    NSData *data = [NSData dataWithContentsOfURL:[WSNetworkTool resumeDownloadDataTempPathForDownloadPath:downloadPath]];
    BOOL resumeDataIsValid = [WSNetworkTool validateResumeData:data];
    
    BOOL canBeResumed = resumeDataFileExists && resumeDataIsValid;
    return canBeResumed;
}

+ (NSDictionary *)dictionaryWithQueryString:(NSString *)queryString {
    NSArray *queryPairArray = [queryString componentsSeparatedByString:@"&"];
    NSMutableDictionary *responseDict = [[NSMutableDictionary alloc] initWithCapacity:[queryPairArray count]];
    @autoreleasepool{
        for (NSString *queryPairString in queryPairArray) {
            NSArray *keyValueArray = [queryPairString componentsSeparatedByString:@"="];
            if ([keyValueArray count] == 2) {
                [responseDict setObject:[keyValueArray lastObject] forKey:[keyValueArray firstObject]];
            }
        }
    }
    return responseDict;
}

+ (NSString *)ipAddressWithHostName:(const NSString *)hostName {
    if (!hostName || [hostName isKindOfClass:[NSNull class]]) {
        //没有域名，返回nil
        return nil;
    }
    const char* szname = [hostName UTF8String];
    struct hostent* phot ;
    @try{
        phot = gethostbyname(szname);
    }
    @catch (NSException * e){
        return nil;
    }
    struct in_addr ip_addr;
    memcpy(&ip_addr,phot->h_addr_list[0],4);
    //h_addr_list[0]里4个字节,每个字节8位，此处为一个数组，一个域名对应多个ip地址或者本地时一个机器有多个网卡
    char ip[20] = {0};
    inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));
    NSString *strIPAddress = [NSString stringWithUTF8String:ip];
    return strIPAddress;
}

#pragma mark - Private Methods

+ (BOOL)validateResumeData:(NSData *)data {
    // From http://stackoverflow.com/a/22137510/3562486
    if (!data || [data length] < 1) return NO;
    
    NSError *error;
    NSDictionary *resumeDictionary = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:&error];
    if (!resumeDictionary || error) return NO;
    
    // Before iOS 9 & Mac OS X 10.11
#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED < 90000)\
|| (defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED < 101100)
    NSString *localFilePath = [resumeDictionary objectForKey:@"NSURLSessionResumeInfoLocalPath"];
    if ([localFilePath length] < 1) return NO;
    return [[NSFileManager defaultManager] fileExistsAtPath:localFilePath];
#endif
    // After iOS 9 we can not actually detects if the cache file exists. This plist file has a somehow
    // complicated structue. Besides, the plist structure is different between iOS 9 and iOS 10.
    // We can only assume that the plist being successfully parsed means the resume data is valid.
    return YES;
}

@end
