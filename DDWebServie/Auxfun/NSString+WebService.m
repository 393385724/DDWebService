//
//  NSString+WebService.m
//  UDan
//
//  Created by lilingang on 16/9/29.
//  Copyright © 2016年 LiLingang. All rights reserved.
//

#import "NSString+WebService.h"
#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIKit.h>

@implementation NSString (WebService)

- (NSString *)wsMD5String{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
}

- (NSString *)wsBase64EncodedString{
    NSData *data = [NSData dataWithBytes:[self UTF8String] length:[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    NSUInteger length = [data length];
    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    
    uint8_t *input = (uint8_t *)[data bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];
    
    for (NSUInteger i = 0; i < length; i += 3) {
        NSUInteger value = 0;
        for (NSUInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        
        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
    }
    return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
}

- (NSString *)wsTrimSpecialCode{
    NSString *string = [self stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    return string;
}

+ (NSString *)wsCallid{
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *timeStampStr = [NSString stringWithFormat:@"%.0f",timestamp];
    return timeStampStr;
}

+ (NSString *)wsSystemTimeZone{
    NSString *timeZone = [[NSTimeZone systemTimeZone] name];
    return timeZone;
}

+ (NSString *)wsCountryCode{
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    if (!countryCode) {
        NSArray *languages = [NSLocale preferredLanguages];
        NSString *currentLanguage = [languages objectAtIndex:0];
        if ([currentLanguage hasPrefix:@"zh-Hans"]) {
            countryCode = @"CN";
        } else {
            countryCode = @"US";
        }
    }
    return countryCode;
}

+ (NSString *)wsSystemLanguage{
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    if ([currentLanguage hasPrefix:@"zh-Hans"]){
        return @"zh_CN";
    } else if ([currentLanguage hasPrefix:@"zh-Hant"]){
        return @"zh_TW";
    } else if ([currentLanguage hasPrefix:@"zh-Hant-HK"]){
        return @"zh_HK";
    } else if ([currentLanguage isEqualToString:@"ko"]){
        return @"ko_KR";
    } else {
        return @"en_US";
    }
    return currentLanguage;
}

+ (NSString *)wsDeviceType{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return @"ios_phone";
    } else {
        return @"ios_pad";
    }
}

+ (NSString *)wsAppShortVersion{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return version;
}

+ (BOOL)wsDeviceisLocalChina {
    
    if ([[NSString wsCountryCode] isEqualToString:@"CN"]) {
        return YES;
    }
    return NO;
}

+ (BOOL)wsDeviceisSimplifiedChinese {
    
    if ([[NSString wsSystemLanguage] isEqualToString:@"zh_CN"]) {
        
        return YES;
    }
    return NO;
}

@end
