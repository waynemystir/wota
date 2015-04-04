//
//  EanHotelInformationResponse.h
//  ota-ios
//
//  Created by WAYNE SMALL on 3/26/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EanHotelInformationResponse : NSObject

@property (nonatomic, strong) NSString *hotelId;
@property (nonatomic, strong) NSString *customerSessionId;
@property (nonatomic, strong) NSDictionary *hotelSummary;
@property (nonatomic, strong) NSDictionary *hotelDetails;
@property (nonatomic, strong) NSDictionary *suppliers;
@property (nonatomic, strong) NSDictionary *roomTypesDict;
@property (nonatomic, strong) NSDictionary *propertyAmenitiesDict;
@property (nonatomic, strong) NSDictionary *hotelImagesDict;

+ (EanHotelInformationResponse *)hotelInfoFromData:(NSData *)data;
+ (EanHotelInformationResponse *)hotelInfoFromObject:(id)object;

@end
