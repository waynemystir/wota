//
//  EanChargeableRateInfo.h
//  ota-ios
//
//  Created by WAYNE SMALL on 5/1/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EanChargeableRateInfo : NSObject

@property (nonatomic, strong) NSNumber *averageBaseRate;
@property (nonatomic, strong) NSNumber *averageRate;
@property (nonatomic, strong) NSNumber *commissionableUsdTotal;
@property (nonatomic, strong) NSString *currencyCode;
@property (nonatomic, strong) NSNumber *maxNightlyRate;
@property (nonatomic, strong) NSDecimalNumber *nightlyRateTotal;
@property (nonatomic, strong) NSDecimalNumber *surchargeTotal;
@property (nonatomic, strong) NSDecimalNumber *total;
@property (nonatomic) BOOL totalEqualsNightlyTotalPlusSurcharges;
@property (nonatomic, strong) NSDictionary *nightlyRatesPerRoom;
@property (nonatomic, strong) NSArray *nightlyRatesArray;
@property (nonatomic, strong) NSString *nightlyRateTypeDescription;
@property (nonatomic, strong) NSDictionary *surcharges;
@property (nonatomic, strong) NSArray *surchargesArray;
@property (nonatomic) double hotelOccupAndSalesTaxSum;
@property (nonatomic, strong) NSString *discountPercentString;

+ (EanChargeableRateInfo *)chargeableRateInfoFromDict:(NSDictionary *)dict;

@end
