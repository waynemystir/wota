//
//  EanRoomRateDetails.h
//  ota-ios
//
//  Created by WAYNE SMALL on 5/25/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EanRateInfo.h"

@interface EanRoomRateDetails : NSObject

@property (nonatomic, strong) NSString *roomTypeCode;
@property (nonatomic, strong) NSString *rateCode;
@property (nonatomic) NSUInteger maxRoomOccupancy;
@property (nonatomic) NSUInteger quotedRoomOccupancy;
@property (nonatomic) NSUInteger minGuestAge;
@property (nonatomic, strong) NSString *roomDescription;
@property (nonatomic) BOOL propertyAvailable;
@property (nonatomic) BOOL propertyRestricted;
@property (nonatomic, strong) NSString *expediaPropertyId;
@property (nonatomic, strong) NSDictionary *rateInfos;
@property (nonatomic, strong) EanRateInfo *rateInfo;

+ (EanRoomRateDetails *)roomRateDetailsFromDict:(NSDictionary *)dict;

@end
