//
//  EanHotelRoomResponse.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/4/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EanAvailabilityRoomType.h"
#import "EanBedType.h"
#import "EanRateInfo.h"
#import "EanRoomImage.h"

@interface EanAvailabilityHotelRoomResponse : NSObject

@property (nonatomic, strong) NSString *rateCode;
@property (nonatomic, strong) NSString *rateDescription;
@property (nonatomic, strong) EanAvailabilityRoomType *roomType;
@property (nonatomic) id roomTypeCode;
@property (nonatomic, strong) NSString *roomTypeDescription;
@property (nonatomic, strong) NSString *supplierType;
@property (nonatomic, strong) NSString *propertyId;
@property (nonatomic, strong) NSDictionary *bedTypes;
@property (nonatomic, strong) NSArray *bedTypesArray;
@property (nonatomic, strong) EanBedType *selectedBedType;
@property (nonatomic, strong) NSString *smokingPreferences;
@property (nonatomic, strong) NSArray *smokingPreferencesArray;
@property (nonatomic, strong) NSString *selectedSmokingPreference;
@property (nonatomic) NSInteger rateOccupancyPerRoom;
@property (nonatomic) NSInteger quotedOccupancy;
@property (nonatomic) NSInteger minGuestAge;
@property (nonatomic, strong) NSDictionary *rateInfos;
@property (nonatomic, strong) EanRateInfo *rateInfo;
@property (nonatomic, strong) NSString *deepLink;
@property (nonatomic, strong) NSDictionary *roomImages;
@property (nonatomic, strong) EanRoomImage *roomImage;

+ (EanAvailabilityHotelRoomResponse *)roomFromDict:(NSDictionary *)dict;

@end
