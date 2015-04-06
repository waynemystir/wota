//
//  EanHotelRoomAvailabilityResponse.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/4/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanHotelRoomAvailabilityResponse.h"

@implementation EanHotelRoomAvailabilityResponse

+ (EanHotelRoomAvailabilityResponse *)roomsAvailableResponseFromData:(NSData *)data {
    if (data == nil) {
        return nil;
    }
    
    NSError *error = nil;
    id respDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error != nil) {
        NSLog(@"ERROR:%@", error);
        return nil;
    }
    
    if (![NSJSONSerialization isValidJSONObject:respDict]) {
        NSLog(@"%@.%@ Response is not valid JSON", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
        return nil;
    }
    
    return [self roomsAvailableResponseFromDict:respDict];
    
}

+ (EanHotelRoomAvailabilityResponse *)roomsAvailableResponseFromDict:(NSDictionary *)dict {
    if (nil == dict) {
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    id idHrar = [dict objectForKey:@"HotelRoomAvailabilityResponse"];
    
    if (nil == idHrar) {
        return nil;
    }
    
    if (![idHrar isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanHotelRoomAvailabilityResponse *hrar = [[EanHotelRoomAvailabilityResponse alloc] init];
    hrar.size = [[idHrar objectForKey:@"@size"] integerValue];
    hrar.customerSessionId = [idHrar objectForKey:@"customerSessionId"];
    hrar.hotelId = [idHrar objectForKey:@"hotelId"];
    hrar.arrivalDate = [idHrar objectForKey:@"arrivalDate"];
    hrar.departureDate = [idHrar objectForKey:@"departureDate"];
    hrar.hotelName = [idHrar objectForKey:@"hotelName"];
    hrar.hotelAddress = [idHrar objectForKey:@"hotelAddress"];
    hrar.hotelCity = [idHrar objectForKey:@"hotelCity"];
    hrar.hotelStateProvince = [idHrar objectForKey:@"hotelStateProvince"];
    hrar.hotelCountry = [idHrar objectForKey:@"hotelCountry"];
    hrar.numberOfRoomsRequested = [[idHrar objectForKey:@"numberOfRoomsRequested"] integerValue];
    hrar.checkInInstructions = [idHrar objectForKey:@"checkInInstructions"];
    hrar.tripAdvisorRating = [idHrar objectForKey:@"tripAdvisorRating"];
    hrar.rateKey = [idHrar objectForKey:@"rateKey"];
    hrar.hotelRoomArray = [idHrar objectForKey:@"HotelRoomResponse"];
    return hrar;
}

@end
