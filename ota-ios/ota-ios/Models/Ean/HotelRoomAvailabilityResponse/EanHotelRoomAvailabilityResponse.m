//
//  EanHotelRoomAvailabilityResponse.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/4/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanHotelRoomAvailabilityResponse.h"
#import "EanAvailabilityHotelRoomResponse.h"

@implementation EanHotelRoomAvailabilityResponse

+ (instancetype)eanObjectFromApiJsonResponse:(id)jsonResponse {
    if (nil == jsonResponse) {
        return nil;
    }
    
    if (![jsonResponse isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    id idHrar = [jsonResponse objectForKey:@"HotelRoomAvailabilityResponse"];
    
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
    hrar.tripAdvisorReviewCount = [[idHrar objectForKey:@"tripAdvisorReviewCount"] integerValue];
    hrar.tripAdvisorRatingUrl = [idHrar objectForKey:@"tripAdvisorRatingUrl"];
    
    id hrr = [idHrar objectForKey:@"HotelRoomResponse"];
    
    if (nil == hrr) {
        hrar.hotelRoomArray = nil;
    } else if ([hrr isKindOfClass:[NSArray class]]) {
        //        hrar.hotelRoomArray = hrr;
        
        // I previously would just return an array of NSDictionary's
        // that needed to be re-parsed with "roomFromDict" by the table
        // view in SelectRoomView Controller. This seemed terribly
        // inefficient. So now we're parsing the dicts once and the
        // hotelRoomArray is an array of Ean...Room objects
        
        NSMutableArray *tmpRooms = [NSMutableArray array];
        for (int j = 0; j < [hrr count]; j++) {
            EanAvailabilityHotelRoomResponse *room = [EanAvailabilityHotelRoomResponse roomFromDict:hrr[j]];
            [tmpRooms addObject:room];
        }
        
        hrar.hotelRoomArray = [NSArray arrayWithArray:tmpRooms];
        
    } else if ([hrr isKindOfClass:[NSDictionary class]]) {
        
        //        hrar.hotelRoomArray = [NSArray arrayWithObject:hrr];
        
        // Believe it or not, Ean API will not return an array if there
        // is a single room response. Instead they just return a dict
        // of the room. Nice.
        hrar.hotelRoomArray = [NSArray arrayWithObject:[EanAvailabilityHotelRoomResponse roomFromDict:hrr]];
        
    } else {
        hrar.hotelRoomArray = nil;
    }
    
    return hrar;
}

@end
