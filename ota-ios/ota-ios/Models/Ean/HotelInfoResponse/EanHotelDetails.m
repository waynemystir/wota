//
//  EanHotelDetails.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/4/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanHotelDetails.h"

@implementation EanHotelDetails

+ (EanHotelDetails *)hotelDetailsFromDictionary:(NSDictionary *)dict {
    if (dict == nil) {
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanHotelDetails *hd = [[EanHotelDetails alloc] init];
    
    hd.numberOfRooms = [[dict objectForKey:@"numberOfRooms"] integerValue];
    hd.numberOfFloors = [[dict objectForKey:@"numberOfFloors"] integerValue];
    hd.checkInTime = [dict objectForKey:@"checkInTime"];
    hd.checkOutTime = [dict objectForKey:@"checkOutTime"];
    hd.propertyInformation = [dict objectForKey:@"propertyInformation"];
    hd.areaInformation = [dict objectForKey:@"areaInformation"];
    hd.propertyDescription = [dict objectForKey:@"propertyDescription"];
    hd.hotelPolicy = [dict objectForKey:@"hotelPolicy"];
    hd.roomInformation = [dict objectForKey:@"roomInformation"];
    hd.drivingDirections = [dict objectForKey:@"drivingDirections"];
    hd.checkInInstructions = [dict objectForKey:@"checkInInstructions"];
    hd.knowBeforeYouGoDescription = [dict objectForKey:@"knowBeforeYouGoDescription"];
    hd.roomFeesDescription = [dict objectForKey:@"roomFeesDescription"];
    hd.locationDescription = [dict objectForKey:@"locationDescription"];
    hd.diningDescription = [dict objectForKey:@"diningDescription"];
    hd.amenitiesDescription = [dict objectForKey:@"amenitiesDescription"];
    hd.businessAmenitiesDescription = [dict objectForKey:@"businessAmenitiesDescription"];
    hd.roomDetailDescription = [dict objectForKey:@"roomDetailDescription"];
    
    return hd;
}

@end
