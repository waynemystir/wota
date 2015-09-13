//
//  EanItinerary.h
//  ota-ios
//
//  Created by WAYNE SMALL on 9/12/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EanHotelConfirmation.h"

@interface EanItinerary : NSObject

@property (nonatomic) NSInteger itineraryId;
@property (nonatomic) NSInteger affiliateId;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSDate *itineraryStartDate;
@property (nonatomic, strong) NSDate *itineraryEndDate;
@property (nonatomic, strong) EanHotelConfirmation *hotelConfirmation;

+ (EanItinerary *)itineraryFromDict:(NSDictionary *)dict;

@end
