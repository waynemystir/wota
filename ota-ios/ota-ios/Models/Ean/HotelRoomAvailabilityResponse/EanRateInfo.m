//
//  EanRateInfo.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/26/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanRateInfo.h"
#import "EanCancelPolicyInfo.h"
#import "EanHotelFee.h"

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
    
    ri.hotelFees = [dict objectForKey:@"HotelFees"];
    
    id idHotelFee = [ri.hotelFees objectForKey:@"HotelFee"];
    NSMutableArray *ma = [NSMutableArray array];
    if (nil == idHotelFee) {
        ri.sumOfHotelFees = @(0);
    } else if ([idHotelFee isKindOfClass:[NSDictionary class]]) {
        EanHotelFee *hf = [EanHotelFee hotelFeeFromDict:idHotelFee];
        [ma addObject:hf];
        ri.sumOfHotelFees = @([hf.amount doubleValue]);
    } else if ([idHotelFee isKindOfClass:[NSArray class]]) {
        for (int j = 0; j < [idHotelFee count]; j++) {
            EanHotelFee *hf = [EanHotelFee hotelFeeFromDict:idHotelFee[j]];
            [ma addObject:hf];
            ri.sumOfHotelFees = @([ri.sumOfHotelFees doubleValue] + [hf.amount doubleValue]);
        }
    }
    ri.hotelFeesArray = [NSArray arrayWithArray:ma];
    
    ri.rateType = [dict objectForKey:@"rateType"];
    ri.currentAllotment = [[dict objectForKey:@"currentAllotment"] integerValue];
    ri.guaranteeRequired = [[dict objectForKey:@"guaranteeRequired"] boolValue];
    ri.depositRequired = [[dict objectForKey:@"depositRequired"] boolValue];
    ri.taxRate = [dict objectForKey:@"taxRate"];
    
    return ri;
}

- (NSNumber *)totalPlusHotelFees {
    return @([self.chargeableRateInfo.total doubleValue] + [self.sumOfHotelFees doubleValue]);
}

@end
