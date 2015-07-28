//
//  EanHotelDetails.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/4/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EanHotelDetails : NSObject

@property (nonatomic) NSUInteger numberOfRooms;
@property (nonatomic) NSUInteger numberOfFloors;
@property (nonatomic, strong) id checkInTime;
@property (nonatomic, strong) id checkOutTime;
@property (nonatomic, strong) NSString *propertyInformation;
@property (nonatomic, strong, readonly) NSString *propertyInformationFormatted;
@property (nonatomic, strong) NSString *areaInformation;
@property (nonatomic, strong) NSString *propertyDescription;
@property (nonatomic, strong) NSString *hotelPolicy;
@property (nonatomic, strong) NSString *roomInformation;
@property (nonatomic, strong) NSString *drivingDirections;
@property (nonatomic, strong) NSString *checkInInstructions;
@property (nonatomic, strong, readonly) NSString *checkInInstructionsFormatted;
@property (nonatomic, strong) NSString *knowBeforeYouGoDescription;
@property (nonatomic, strong) NSString *roomFeesDescription;
@property (nonatomic, strong, readonly) NSString *roomFeesDescriptionFormmatted;
@property (nonatomic, strong) NSString *locationDescription;
@property (nonatomic, strong) NSString *diningDescription;
@property (nonatomic, strong) NSString *amenitiesDescription;
@property (nonatomic, strong) NSString *businessAmenitiesDescription;
@property (nonatomic, strong) NSString *roomDetailDescription;

+ (EanHotelDetails *)hotelDetailsFromDictionary:(NSDictionary *)dict;

@end
