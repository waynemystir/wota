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
    hotel.order = [[object objectForKey:@"@order"] integerValue];
    hotel.hotelId = [object objectForKey:@"hotelId"];
    hotel.hotelName = [object objectForKey:@"name"];
    hotel.address1 = [object objectForKey:@"address1"];
    hotel.city = [object objectForKey:@"city"];
    hotel.stateProvinceCode = [object objectForKey:@"stateProvinceCode"];
    hotel.postalCode = [object objectForKey:@"postalCode"];
    hotel.countryCode = [object objectForKey:@"countryCode"];
    hotel.airportCode = [object objectForKey:@"airportCode"];
    hotel.supplierType = [object objectForKey:@"supplierType"];
    hotel.propertyCategory = [object objectForKey:@"propertyCategory"];
    hotel.hotelRating = [object objectForKey:@"hotelRating"];
    hotel.confidenceRating = [object objectForKey:@"confidenceRating"];
    hotel.amenityMask = [object objectForKey:@"amenityMask"];
    hotel.tripAdvisorRating = [object objectForKey:@"tripAdvisorRating"];
    hotel.locationDescription = [object objectForKey:@"locationDescription"];
    hotel.shortDescription = [object objectForKey:@"shortDescription"];
    hotel.highRate = [object objectForKey:@"highRate"];
    hotel.lowRate = [object objectForKey:@"lowRate"];
    hotel.rateCurrencyCode = [object objectForKey:@"rateCurrencyCode"];
    hotel.latitude = [[object objectForKey:@"latitude"] doubleValue];
    hotel.longitude = [[object objectForKey:@"longitude"] doubleValue];
    hotel.proximityDistance = [object objectForKey:@"proximityDistance"];
    hotel.proximityUnit = [object objectForKey:@"proximityUnit"];
    hotel.hotelInDestination = [object objectForKey:@"hotelInDestination"];
    hotel.thumbNailUrl = [object objectForKey:@"thumbNailUrl"];
    hotel.deepLink = [object objectForKey:@"deepLink"];
    hotel.roomRateDetailsList = [object objectForKey:@"RoomRateDetailsList"];
    
    return hotel;
}

@end
