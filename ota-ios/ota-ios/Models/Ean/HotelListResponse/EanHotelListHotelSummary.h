//
//  EanHotelListHotelSummary.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/5/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EanHotelListHotelSummary : NSObject

@property (nonatomic, strong) NSString *hotelId;
@property (nonatomic, strong) NSString *hotelName;
@property (nonatomic, strong) NSNumber *highRate;
@property (nonatomic, strong) NSNumber *tripAdvisorRating;
@property (nonatomic, strong) NSString *thumbNailUrl;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic, strong) NSString *shortDescription;

+ (EanHotelListHotelSummary *)hotelFromObject:(id)object;

@end
