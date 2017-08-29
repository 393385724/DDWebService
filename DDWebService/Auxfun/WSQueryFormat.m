//
//  WSQueryFormat.m
//  HMHealth
//
//  Created by 李林刚 on 2016/12/6.
//  Copyright © 2016年 HM iOS. All rights reserved.
//

/**
 @see more AFURLRequestSerialization
 */

#import "WSQueryFormat.h"
#import <AFNetworking/AFURLRequestSerialization.h>

@interface HMQueryStringPair : NSObject

@property (readwrite, nonatomic, strong) id field;
@property (readwrite, nonatomic, strong) id value;

- (instancetype)initWithField:(id)field value:(id)value;

@end

@implementation HMQueryStringPair

- (instancetype)initWithField:(id)field value:(id)value {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.field = field;
    self.value = value;
    return self;
}

- (NSString *)URLEncodedStringValue {
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return AFPercentEscapedStringFromString([self.field description]);
    } else {
        return [NSString stringWithFormat:@"%@=%@", AFPercentEscapedStringFromString([self.field description]), AFPercentEscapedStringFromString([self.value description])];
    }
}

@end

@implementation WSQueryFormat

+ (NSString *)queryStringFromParameters:(NSDictionary *)parameters{
    NSMutableArray *mutablePairs = [NSMutableArray array];
    NSArray <HMQueryStringPair *> *queryStringPairs = [self queryStringPairsWithKey:nil value:parameters];
    for (HMQueryStringPair *pair in queryStringPairs) {
        [mutablePairs addObject:[pair URLEncodedStringValue]];
    }
    return [mutablePairs componentsJoinedByString:@"&"];
}

#pragma mark -  Private Methods

+ (NSArray *)queryStringPairsWithKey:(NSString *)key value:(id)value{
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(compare:)];
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = value;
        // Sort dictionary keys to ensure consistent ordering in query string, which is important when deserializing potentially ambiguous sequences, such as an array of dictionaries
        for (id nestedKey in [dictionary.allKeys sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            id nestedValue = dictionary[nestedKey];
            if (nestedValue) {
                [mutableQueryStringComponents addObjectsFromArray:[self queryStringPairsWithKey:(key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey) value:nestedValue]];
            }
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        for (id nestedValue in array) {
            //去掉key后面的[]
            [mutableQueryStringComponents addObjectsFromArray:[self queryStringPairsWithKey:[NSString stringWithFormat:@"%@", key] value:nestedValue]];
        }
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = value;
        for (id obj in [set sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            [mutableQueryStringComponents addObjectsFromArray:[self queryStringPairsWithKey:key value:obj]];
        }
    } else {
        [mutableQueryStringComponents addObject:[[HMQueryStringPair alloc] initWithField:key value:value]];
    }
    return mutableQueryStringComponents;
}
@end
