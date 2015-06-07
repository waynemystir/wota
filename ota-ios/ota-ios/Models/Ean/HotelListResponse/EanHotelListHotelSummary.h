//
//  EanHotelListHotelSummary.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/5/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EanRoomRateDetails.h"

@interface EanHotelListHotelSummary : NSObject

@property (nonatomic) NSUInteger order;
@property (nonatomic, strong) NSNumber *hotelId;
@property (nonatomic, strong) NSString *hotelName;
@property (nonatomic, strong, readonly) NSString *hotelNameFormatted;
@property (nonatomic, strong) NSString *address1;
@property (nonatomic, strong, readonly) NSString *address1Formatted;
@property (nonatomic, strong) NSString *address2;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *stateProvinceCode;
@property (nonatomic, strong) NSString *postalCode;
@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) NSString *airportCode;
@property (nonatomic, strong) NSString *supplierType;
@property (nonatomic) id propertyCategory;
@property (nonatomic, strong) NSNumber *hotelRating;
@property (nonatomic, strong) NSNumber *confidenceRating;
@property (nonatomic) id amenityMask;
@property (nonatomic, strong) NSNumber *tripAdvisorRating;
@property (nonatomic, strong) NSNumber *tripAdvisorReviewCount;
@property (nonatomic, strong) NSString *tripAdvisorRatingUrl;
@property (nonatomic, strong) NSString *locationDescription;
@property (nonatomic, strong) NSString *shortDescription;
@property (nonatomic, strong) NSNumber *highRate;
@property (nonatomic, strong) NSNumber *lowRate;
@property (nonatomic, strong) NSString *rateCurrencyCode;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic, strong) NSNumber *proximityDistance;
@property (nonatomic, strong) NSString *proximityUnit;
@property (nonatomic) BOOL hotelInDestination;
@property (nonatomic, strong) NSString *thumbNailUrl;
@property (nonatomic, strong, readonly) NSString *thumbNailUrlEnhanced;
@property (nonatomic, strong) NSString *deepLink;
@property (nonatomic, strong) NSDictionary *roomRateDetailsList;
@property (nonatomic, strong) NSArray *roomRateDetailsArray;
@property (nonatomic, strong) EanRoomRateDetails *roomRateDetails;

+ (EanHotelListHotelSummary *)hotelFromObject:(id)object;

@end
