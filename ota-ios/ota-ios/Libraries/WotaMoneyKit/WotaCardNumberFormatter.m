//
//  WotaCardNumberFormatter.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/20/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "WotaCardNumberFormatter.h"
#import "WotaMoneyUtils.h"

@interface WotaCardNumberFormatter ()

@property (nonatomic, strong) NSSet                 *cardPatterns;
@property (nonatomic, strong) NSRegularExpression   *nonNumericRegularExpression;

@property (nonatomic, strong) NSString              *cachedPrefix;
@property (nonatomic, strong) WotaCardPatternInfo     *cardPatternInfo;

@end

@implementation WotaCardNumberFormatter

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"WotaMoneyKit.bundle/CardPatterns" ofType:@"plist"];
        NSArray *array = [NSArray arrayWithContentsOfFile:filePath];
        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:array.count];
        
        for (NSDictionary *dictionary in array) {
            
            WotaCardPatternInfo *pattern = [[WotaCardPatternInfo alloc] initWithDictionary:dictionary];
            if (pattern) {
                [mutableArray addObject:pattern];
            }
        }
        
        self.cardPatterns = [NSSet setWithArray:mutableArray];
        self.nonNumericRegularExpression = [WotaMoneyUtils nonNumericRegularExpression];
        self.groupSeparater = @" ";
    }
    return self;
}

- (NSString *)stringForObjectValue:(id)obj
{
    if (NO == [obj isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    NSString *numberString = [self.nonNumericRegularExpression stringByReplacingMatchesInString:obj
                                                                                        options:0
                                                                                          range:NSMakeRange(0, [obj length])
                                                                                   withTemplate:@""];
    
    WotaCardPatternInfo *patternInfo = [self cardPatternInfoWithNumberString:numberString];
    
    if (patternInfo) {
        return [patternInfo groupedStringWithString:numberString groupSeparater:self.groupSeparater maskingCharacter:self.maskingCharacter maskingGroupIndexSet:self.maskingGroupIndexSet];
    } else {
        return numberString;
    }
}

- (BOOL)getObjectValue:(out __autoreleasing id *)obj forString:(NSString *)string errorDescription:(out NSString *__autoreleasing *)error
{
    if (obj) {
        *obj = [self.nonNumericRegularExpression stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, string.length) withTemplate:@""];
    }
    
    return YES;
}

- (NSString *)formattedStringFromRawString:(NSString *)rawString
{
    return [self stringForObjectValue:rawString];
}

- (NSString *)rawStringFromFormattedString:(NSString *)string
{
    NSString *result = nil;
    NSString *errorDescription = nil;
    if ([self getObjectValue:&result forString:string errorDescription:&errorDescription]) {
        return result;
    } else {
        return nil;
    }
}

- (WotaCardPatternInfo *)cardPatternInfoWithNumberString:(NSString *)aNumberString
{
    if (self.cachedPrefix && [aNumberString hasPrefix:self.cachedPrefix] && self.cardPatternInfo) {
        return self.cardPatternInfo;
    }
    
    for (WotaCardPatternInfo *patternInfo in self.cardPatterns) {
        
        if ([patternInfo patternMatchesWithNumberString:aNumberString]) {
            
            self.cardPatternInfo = patternInfo;
            self.cachedPrefix = aNumberString;
            
            return patternInfo;
        }
    }
    
    self.cachedPrefix = nil;
    self.cardPatternInfo = nil;
    
    return nil;
}

@end
