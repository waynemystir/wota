//
//  EanHotelInformationSummary.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/4/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanHotelInformationSummary.h"

@implementation EanHotelInformationSummary

+ (EanHotelInformationSummary *)hotelSummaryFromDictionary:(NSDictionary *)dict {
    if (dict == nil) {
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanHotelInformationSummary *his = [[EanHotelInformationSummary alloc] init];
    
    //*******************
    // TODO: handle cases where the following values are not empty or wrong data type
    //*******************
    his.order = [dict objectForKey:@"@order"];
    his.hotelId = [dict objectForKey:@"hotelId"];
    his.hotelName = [dict objectForKey:@"name"];
    his.address1 = [dict objectForKey:@"address1"];
    his.city = [dict objectForKey:@"city"];
    his.countryCode = [dict objectForKey:@"countryCode"];
    his.propertyCategory = [dict objectForKey:@"propertyCategory"];
    his.hotelRating = [dict objectForKey:@"hotelRating"];
    his.tripAdvisorRating = [dict objectForKey:@"tripAdvisorRating"];
    his.locationDescription = [dict objectForKey:@"locationDescription"];
    his.highRate = [dict objectForKey:@"highRate"];
    his.lowRate = [dict objectForKey:@"lowRate"];
    his.latitude = [[dict objectForKey:@"latitude"] doubleValue];
    his.longitude = [[dict objectForKey:@"longitude"] doubleValue];
    
    return his;
}

@end
