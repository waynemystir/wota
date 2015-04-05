//
//  EanHotelListHotelSummary.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/5/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanHotelListHotelSummary.h"

@implementation EanHotelListHotelSummary

+ (EanHotelListHotelSummary *)hotelFromObject:(id)object {
    if (object == nil) {
        return nil;
    }
    
    EanHotelListHotelSummary *hotel = [[EanHotelListHotelSummary alloc] init];
    
    //*******************
    // TODO: handle cases where the following values are not empty or wrong data type
    //*******************
    hotel.hotelId = [object objectForKey:@"hotelId"];
    hotel.hotelName = [object objectForKey:@"name"];
    hotel.highRate = [object objectForKey:@"highRate"];
    hotel.tripAdvisorRating = [object objectForKey:@"tripAdvisorRating"];
    hotel.thumbNailUrl = [object objectForKey:@"thumbNailUrl"];
    hotel.latitude = [[object objectForKey:@"latitude"] doubleValue];
    hotel.longitude = [[object objectForKey:@"longitude"] doubleValue];
    hotel.shortDescription = [object objectForKey:@"shortDescription"];
    return hotel;
}

@end
