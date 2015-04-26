//
//  EanHotelInformationResponse.h
//  ota-ios
//
//  Created by WAYNE SMALL on 3/26/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EanAbstractResponse.h"
#import "EanHotelInformationSummary.h"
#import "EanHotelDetails.h"

@interface EanHotelInformationResponse : EanAbstractResponse

@property (nonatomic, strong) NSString *hotelId;
@property (nonatomic, strong) NSString *customerSessionId;
@property (nonatomic, strong) EanHotelInformationSummary *hotelSummary;
@property (nonatomic, strong) EanHotelDetails *hotelDetails;
@property (nonatomic, strong) NSDictionary *suppliers;
@property (nonatomic, strong) NSDictionary *roomTypesDict;
@property (nonatomic) NSUInteger numberOfRoomTypes;
@property (nonatomic, strong) NSArray *roomTypesArray;
@property (nonatomic, strong) NSDictionary *propertyAmenitiesDict;
@property (nonatomic) NSUInteger numberOfPropertyAmenities;
@property (nonatomic, strong) NSArray *propertyAmenitiesArray;
@property (nonatomic, strong) NSDictionary *hotelImagesDict;
@property (nonatomic) NSUInteger numberOfHotelImages;
@property (nonatomic, strong) NSArray *hotelImagesArray;

@end
