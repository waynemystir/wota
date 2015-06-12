//
//  EanHotelListHotelSummary.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/5/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanHotelListHotelSummary.h"
#import "NSString+HTML.h"

@implementation EanHotelListHotelSummary

+ (EanHotelListHotelSummary *)hotelFromDict:(NSDictionary *)dict {
    if (dict == nil) {
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanHotelListHotelSummary *hotel = [[EanHotelListHotelSummary alloc] init];
    
    //*******************
    // TODO: handle cases where the following values are not empty or wrong data type
    //*******************
    hotel.order = [[dict objectForKey:@"@order"] integerValue];
    hotel.hotelId = [dict objectForKey:@"hotelId"];
    hotel.hotelName = [dict objectForKey:@"name"];
    hotel.address1 = [dict objectForKey:@"address1"];
    hotel.address2 = [dict objectForKey:@"address2"];
    hotel.city = [dict objectForKey:@"city"];
    hotel.stateProvinceCode = [dict objectForKey:@"stateProvinceCode"];
    hotel.postalCode = [dict objectForKey:@"postalCode"];
    hotel.countryCode = [dict objectForKey:@"countryCode"];
    hotel.airportCode = [dict objectForKey:@"airportCode"];
    hotel.supplierType = [dict objectForKey:@"supplierType"];
    hotel.propertyCategory = [dict objectForKey:@"propertyCategory"];
    hotel.hotelRating = [dict objectForKey:@"hotelRating"];
    hotel.confidenceRating = [dict objectForKey:@"confidenceRating"];
    hotel.amenityMask = [dict objectForKey:@"amenityMask"];
    hotel.tripAdvisorRating = [dict objectForKey:@"tripAdvisorRating"];
    hotel.tripAdvisorReviewCount = [dict objectForKey:@"tripAdvisorReviewCount"];
    hotel.tripAdvisorRatingUrl = [dict objectForKey:@"tripAdvisorRatingUrl"];
    hotel.locationDescription = [dict objectForKey:@"locationDescription"];
    hotel.shortDescription = [dict objectForKey:@"shortDescription"];
    hotel.highRate = [dict objectForKey:@"highRate"];
    hotel.lowRate = [dict objectForKey:@"lowRate"];
    hotel.rateCurrencyCode = [dict objectForKey:@"rateCurrencyCode"];
    hotel.latitude = [[dict objectForKey:@"latitude"] doubleValue];
    hotel.longitude = [[dict objectForKey:@"longitude"] doubleValue];
    hotel.proximityDistance = [[dict objectForKey:@"proximityDistance"] doubleValue];
    hotel.proximityUnit = [dict objectForKey:@"proximityUnit"];
    hotel.hotelInDestination = [[dict objectForKey:@"hotelInDestination"] boolValue];
    hotel.thumbNailUrl = [dict objectForKey:@"thumbNailUrl"];
    hotel.deepLink = [dict objectForKey:@"deepLink"];
    hotel.roomRateDetailsList = [dict objectForKey:@"RoomRateDetailsList"];
    
    return hotel;
}

- (NSString *)thumbNailUrlEnhanced {
    return [_thumbNailUrl stringByReplacingOccurrencesOfString:@"_t" withString:@"_b"];
}

- (NSString *)hotelNameFormatted {
    return [_hotelName stringByConvertingHTMLToPlainText];
}

- (NSString *)address1Formatted {
    return [_address1 stringByConvertingHTMLToPlainText];
}

@end
