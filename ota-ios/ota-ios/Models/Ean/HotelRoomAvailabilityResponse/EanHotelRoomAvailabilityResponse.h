//
//  EanHotelRoomAvailabilityResponse.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/4/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EanHotelRoomAvailabilityResponse : NSObject

@property (nonatomic) NSUInteger size;
@property (nonatomic, strong) NSString *customerSessionId;
@property (nonatomic, strong) NSString *hotelId;
@property (nonatomic, strong) id arrivalDate;
@property (nonatomic, strong) id departureDate;
@property (nonatomic, strong) NSString *hotelName;
@property (nonatomic, strong) NSString *hotelAddress;
@property (nonatomic, strong) NSString *hotelCity;
@property (nonatomic, strong) NSString *hotelStateProvince;
@property (nonatomic, strong) NSString *hotelCountry;
@property (nonatomic) NSUInteger numberOfRoomsRequested;
@property (nonatomic, strong) NSString *checkInInstructions;
@property (nonatomic, strong) NSNumber *tripAdvisorRating;
@property (nonatomic, strong) NSString *rateKey;
@property (nonatomic, strong) NSArray *hotelRoomArray;

+ (EanHotelRoomAvailabilityResponse *)roomsAvailableResponseFromData:(NSData *)data;

@end
