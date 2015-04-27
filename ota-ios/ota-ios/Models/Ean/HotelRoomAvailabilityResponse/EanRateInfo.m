//
//  EanRateInfo.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/26/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanRateInfo.h"

@implementation EanRateInfo

+ (EanRateInfo *)rateInfoFromDict:(NSDictionary *)dict {
    if (nil == dict) {
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanRateInfo *ri = [[EanRateInfo alloc] init];
    ri.priceBreakdown = [[dict objectForKey:@"@priceBreakdown"] boolValue];
    ri.promo = [[dict objectForKey:@"@promo"] boolValue];
    ri.rateChange = [[dict objectForKey:@"@rateChange"] boolValue];
    ri.roomGroup = [EanRoomGroup roomGroupFromDict:[dict objectForKey:@"RoomGroup"]];
    ri.chargeableRateInfo = [dict objectForKey:@"ChargeableRateInfo"];
    ri.chargeableRate = [[ri.chargeableRateInfo objectForKey:@"@total"] floatValue];
    ri.currencyCode = [ri.chargeableRateInfo objectForKey:@"@currencyCode"];
    ri.nightlyRateToPresent = [NSNumber numberWithDouble:[[ri.chargeableRateInfo objectForKey:@"@averageRate"] doubleValue]];
    ri.cancellationPolicy = [dict objectForKey:@"cancellationPolicy"];
    ri.cancelPolicyInfoList = [dict objectForKey:@"CancelPolicyInfoList"];
    ri.nonRefundable = [[dict objectForKey:@"nonRefundable"] boolValue];
    ri.nonRefundableString = ri.nonRefundable ? @"Non-refundable" : @"Free Cancellation";
    ri.currentAllotment = [[dict objectForKey:@"currentAllotment"] integerValue];
    ri.guaranteeRequired = [[dict objectForKey:@"guaranteeRequired"] boolValue];
    ri.depositRequired = [[dict objectForKey:@"depositRequired"] boolValue];
    ri.taxRate = [dict objectForKey:@"taxRate"];
    
    
    return ri;
}

@end
