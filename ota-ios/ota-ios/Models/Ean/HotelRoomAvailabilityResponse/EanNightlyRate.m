//
//  EanNightlyRate.m
//  ota-ios
//
//  Created by WAYNE SMALL on 5/1/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanNightlyRate.h"

@implementation EanNightlyRate

+ (EanNightlyRate *)nightRateFromDict:(NSDictionary *)dict {
    if (nil == dict) {
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanNightlyRate *nr = [[EanNightlyRate alloc] init];
    nr.promo = [[dict objectForKey:@"@promo"] boolValue];
    nr.rate = [NSNumber numberWithDouble:[[dict objectForKey:@"@rate"] doubleValue]];
    nr.baseRate = [NSNumber numberWithDouble:[[dict objectForKey:@"@baseRate"] doubleValue]];
    return nr;
}

@end
