//
//  EanHotelRoomResponse.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/4/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EanBedType.h"

@interface EanAvailabilityHotelRoomResponse : NSObject

@property (nonatomic, strong) NSString *cancellationPolicy;
@property (nonatomic, strong) NSString *rateCode;
@property (nonatomic) id roomTypeCode;
@property (nonatomic, strong) NSString *rateDescription;
@property (nonatomic, strong) NSString *roomTypeDescription;
@property (nonatomic, strong) NSString *supplierType;
@property (nonatomic, strong) NSNumber *taxRate;
@property (nonatomic) BOOL rateChange;
@property (nonatomic) BOOL nonRefundable;
@property (nonatomic) NSString *nonRefundableString;
@property (nonatomic) BOOL guaranteeRequired;
@property (nonatomic) BOOL depositRequired;
@property (nonatomic) BOOL immediateChargeRequired;
@property (nonatomic) NSUInteger currentAllotment;
@property (nonatomic, strong) NSString *propertyId;
@property (nonatomic, strong) NSDictionary *bedTypes;
@property (nonatomic, strong) NSArray *bedTypesArray;
@property (nonatomic, strong) EanBedType *selectedBedType;
@property (nonatomic, strong) NSDictionary *cancelPolicyInfoList;
@property (nonatomic, strong) NSString *smokingPreferences;
@property (nonatomic, strong) NSArray *smokingPreferencesArray;
@property (nonatomic, strong) NSString *selectedSmokingPreference;
@property (nonatomic) NSInteger rateOccupancyPerRoom;
@property (nonatomic) NSInteger quotedOccupancy;
@property (nonatomic) NSInteger minGuestAge;
@property (nonatomic, strong) NSDictionary *rateInfo;
@property (nonatomic, strong) NSDictionary *chargeableRateInfo;
@property (nonatomic) float chargeableRate;
@property (nonatomic, strong) NSString *currencyCode;
@property (nonatomic, strong) NSString *deepLink;

@property (nonatomic, strong) NSNumber *nightlyRateToPresent;

+ (EanAvailabilityHotelRoomResponse *)roomFromDict:(NSDictionary *)dict;

@end
