//
//  EanHotelDetails.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/4/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EanHotelDetails : NSObject

@property (nonatomic) NSUInteger numberOfRooms;
@property (nonatomic) NSUInteger numberOfFloors;
@property (nonatomic, strong) id checkInTime;
@property (nonatomic, strong) id checkOutTime;
@property (nonatomic, strong) NSString *propertyInformation;
@property (nonatomic, strong) NSString *areaInformation;
@property (nonatomic, strong) NSString *propertyDescription;
@property (nonatomic, strong) NSString *hotelPolicy;
@property (nonatomic, strong) NSString *roomInformation;
@property (nonatomic, strong) NSString *drivingDirections;
@property (nonatomic, strong) NSString *checkInInstructions;

+ (EanHotelDetails *)hotelDetailsFromObject:(id)object;
+ (EanHotelDetails *)hotelDetailsFromDictionary:(NSDictionary *)dict;

@end
