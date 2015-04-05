//
//  EanHotelInformationSummary.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/4/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EanHotelInformationSummary : NSObject

@property (nonatomic, strong) id order;
@property (nonatomic, strong) NSString *hotelId;
@property (nonatomic, strong) NSString *hotelName;
@property (nonatomic, strong) NSString *address1;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) NSString *propertyCategory;
@property (nonatomic, strong) NSString *hotelRating;
@property (nonatomic, strong) NSNumber *tripAdvisorRating;
@property (nonatomic, strong) NSString *locationDescription;
@property (nonatomic, strong) NSNumber *highRate;
@property (nonatomic, strong) NSNumber *lowRate;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

+ (EanHotelInformationSummary *)hotelSummaryFromDictionary:(NSDictionary *)dict;

@end
