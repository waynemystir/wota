//
//  EanRateInfo.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/26/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EanRoomGroup.h"
#import "EanChargeableRateInfo.h"

@interface EanRateInfo : NSObject

@property (nonatomic) BOOL priceBreakdown;
@property (nonatomic) BOOL promo;
@property (nonatomic) BOOL rateChange;
@property (nonatomic, strong) EanRoomGroup *roomGroup;
@property (nonatomic, strong) EanChargeableRateInfo *chargeableRateInfo;
//@property (nonatomic) float chargeableRate;
//@property (nonatomic, strong) NSString *currencyCode;
//@property (nonatomic, strong) NSNumber *nightlyRateToPresent;
@property (nonatomic, strong) NSString *cancellationPolicy;
@property (nonatomic, strong) NSDictionary *cancelPolicyInfoList;
@property (nonatomic) BOOL nonRefundable;
@property (nonatomic) NSString *nonRefundableString;
@property (nonatomic) NSUInteger currentAllotment;
@property (nonatomic) BOOL guaranteeRequired;
@property (nonatomic) BOOL depositRequired;
@property (nonatomic, strong) NSNumber *taxRate;

+ (EanRateInfo *)rateInfoFromDict:(NSDictionary *)dict;

@end
