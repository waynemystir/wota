//
//  EanHotelRoomReservationResponse.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/7/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EanAbstractResponse.h"

@interface EanHotelRoomReservationResponse : EanAbstractResponse

@property (nonatomic, strong) NSString *customerSessionId;
@property (nonatomic) NSInteger itineraryId;
@property (nonatomic) BOOL processedWithConfirmation;
@property (nonatomic, strong) NSArray *confirmationNumbers;
@property (nonatomic, strong) NSDictionary *rateInfo;
@property (nonatomic, strong) NSString *supplierType;
@property (nonatomic, strong) NSString *reservationStatusCode;
@property (nonatomic) BOOL existingItinerary;
@property (nonatomic) NSInteger numberOfRoomsBooked;
@property (nonatomic, strong) NSDictionary *roomGroup;
@property (nonatomic, strong) NSString *drivingDirections;
@property (nonatomic, strong) NSString *checkInInstructions;
@property (nonatomic, strong) NSDate *arrivalDate;
@property (nonatomic, strong) NSDate *departureDate;
@property (nonatomic, strong) NSString *hotelName;
@property (nonatomic, strong) NSString *hotelAddress;
@property (nonatomic, strong) NSString *hotelCity;
@property (nonatomic, strong) NSString *hotelPostalCode;
@property (nonatomic, strong) NSString *hotelCountryCode;
@property (nonatomic, strong) NSString *roomDescription;
@property (nonatomic, strong) NSString *cancellationPolicy;
@property (nonatomic, strong) NSDictionary *cancelPolicyInfoList;
@property (nonatomic) BOOL nonRefundable;
@property (nonatomic) NSInteger rateOccupancyPerRoom;
@property (nonatomic, strong) NSString *errorText;
@property (nonatomic, strong) EanWsError *eanWsError;
@property (nonatomic) BOOL isResponseEmpty;

@end
