//
//  EanHotelRoomAvailabilityResponse.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/4/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EanAbstractResponse.h"

@interface EanHotelRoomAvailabilityResponse : EanAbstractResponse

@property (nonatomic) NSUInteger size;
@property (nonatomic, strong) NSString *customerSessionId;
@property (nonatomic, strong) NSString *hotelId;
@property (nonatomic, strong) NSString *arrivalDateString;
@property (nonatomic, strong) NSString *departureDateString;
@property (nonatomic, strong) NSDate *arrivalDate;
@property (nonatomic, strong) NSDate *departureDate;
@property (nonatomic, strong) NSString *hotelName;
@property (nonatomic, strong) NSString *hotelAddress;
@property (nonatomic, strong) NSString *hotelCity;
@property (nonatomic, strong) NSString *hotelStateProvince;
@property (nonatomic, strong) NSString *hotelCountry;
@property (nonatomic) NSUInteger numberOfRoomsRequested;
@property (nonatomic, strong) NSString *checkInInstructions;
@property (nonatomic, strong) NSNumber *tripAdvisorRating;
@property (nonatomic) NSUInteger tripAdvisorReviewCount;
@property (nonatomic, strong) NSString *tripAdvisorRatingUrl;
@property (nonatomic, strong) NSArray *hotelRoomArray;

@end
