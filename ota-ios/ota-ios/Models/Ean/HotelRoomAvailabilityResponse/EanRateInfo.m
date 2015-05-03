//
//  EanRateInfo.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/26/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanRateInfo.h"
#import "EanCancelPolicyInfo.h"

NSString * const kNonrefundableString = @"This rate is non-refundable";
NSString * const kFreeCancellationString = @"Free Cancellation by Oct 20";

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
    ri.chargeableRateInfo = [EanChargeableRateInfo chargeableRateInfoFromDict:[dict objectForKey:@"ChargeableRateInfo"]];
    ri.cancellationPolicy = [dict objectForKey:@"cancellationPolicy"];
    ri.cancelPolicyInfoList = [dict objectForKey:@"CancelPolicyInfoList"];
    
    id idCancelPolicyArray = [ri.cancelPolicyInfoList objectForKey:@"CancelPolicyInfo"];
    if ([idCancelPolicyArray isKindOfClass:[NSArray class]]) {
        NSMutableArray *mutCancelPolicyInfoArray = [NSMutableArray array];
        for (int j = 0; j < [idCancelPolicyArray count]; j++) {
            EanCancelPolicyInfo *cpi = [EanCancelPolicyInfo cancelPolicyFromDict:idCancelPolicyArray[j]];
            [mutCancelPolicyInfoArray addObject:cpi];
        }
        ri.cancelPolicyInfoArray = [NSArray arrayWithArray:mutCancelPolicyInfoArray];
    }
    
    ri.nonRefundable = [[dict objectForKey:@"nonRefundable"] boolValue];
    ri.nonRefundableString = ri.nonRefundable ? @"Non-refundable" : @"Free Cancellation";
    
    if (ri.nonRefundable) {
        ri.nonRefundableLongString = kNonrefundableString;
    } else if ([ri.cancelPolicyInfoArray count] > 0) {
        NSString *s = [NSString stringWithFormat:@"%@ %@", kFreeCancellationString, ((EanCancelPolicyInfo *)ri.cancelPolicyInfoArray[0]).cancelTime];
        ri.nonRefundableLongString = s;
    }
    
    ri.currentAllotment = [[dict objectForKey:@"currentAllotment"] integerValue];
    ri.guaranteeRequired = [[dict objectForKey:@"guaranteeRequired"] boolValue];
    ri.depositRequired = [[dict objectForKey:@"depositRequired"] boolValue];
    ri.taxRate = [dict objectForKey:@"taxRate"];
    
    return ri;
}

@end
