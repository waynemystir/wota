//
//  EanCancelPolicyInfo.m
//  ota-ios
//
//  Created by WAYNE SMALL on 5/2/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanCancelPolicyInfo.h"

@implementation EanCancelPolicyInfo

+ (EanCancelPolicyInfo *)cancelPolicyFromDict:(NSDictionary *)dict {
    if (nil == dict) {
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanCancelPolicyInfo *cp = [[EanCancelPolicyInfo alloc] init];
    cp.versionId = [[dict objectForKey:@"versionId"] integerValue];
    cp.cancelTime = [dict objectForKey:@"cancelTime"];
    cp.startWindowHours = [[dict objectForKey:@"startWindowHours"] integerValue];
    cp.nightCount = [[dict objectForKey:@"nightCount"] integerValue];
    cp.percent = [dict objectForKey:@"percent"];
    cp.amount = [dict objectForKey:@"amount"];
    cp.currencyCode = [dict objectForKey:@"currencyCode"];
    cp.timeZoneDescription = [dict objectForKey:@"timeZoneDescription"];
    return cp;
}

@end
