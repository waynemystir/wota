//
//  EanHotelListResponse.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/5/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanHotelListResponse.h"
#import "EanHotelListHotelSummary.h"
#import "SelectionCriteria.h"

@implementation EanHotelListResponse

+ (instancetype)eanObjectFromApiJsonResponse:(id)jsonResponse {
    if (nil == jsonResponse) {
        return nil;
    }
    
    if (![jsonResponse isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    id idHlr = [jsonResponse objectForKey:@"HotelListResponse"];
    
    if (nil == idHlr) {
        return nil;
    }
    
    if (![idHlr isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanHotelListResponse *hlr = [[EanHotelListResponse alloc] init];
    
    hlr.customerSessionId = [idHlr objectForKey:@"customerSessionId"];
    hlr.numberOfRoomsRequested = [[idHlr objectForKey:@"numberOfRoomsRequested"] integerValue];
    hlr.moreResultsAvailable = [[idHlr objectForKey:@"moreResultsAvailable"] boolValue];
    hlr.cacheKey = [idHlr objectForKey:@"cacheKey"];
    hlr.cacheLocation = [idHlr objectForKey:@"cacheLocation"];
    hlr.hotelListDict = [idHlr objectForKey:@"HotelList"];
    hlr.size = [[hlr.hotelListDict objectForKey:@"@size"] integerValue];
    hlr.activePropertyCount = [[hlr.hotelListDict objectForKey:@"@activePropertyCount"] integerValue];
    
    id hSumm = [hlr.hotelListDict objectForKey:@"HotelSummary"];
    
    if (nil == hSumm) {
        hlr.hotelList = nil;
    } else if ([hSumm isKindOfClass:[NSArray class]]) {
        
        NSMutableArray *tmpHotels = [NSMutableArray array];
        for (int j = 0; j < [hSumm count]; j++) {
            EanHotelListHotelSummary *hotel = [EanHotelListHotelSummary hotelFromDict:hSumm[j]];
            [tmpHotels addObject:hotel];
        }
        
        hlr.hotelList = [NSArray arrayWithArray:tmpHotels];
        
    } else if ([hSumm isKindOfClass:[NSDictionary class]]) {
        hlr.hotelList = [NSArray arrayWithObject:[EanHotelListHotelSummary hotelFromDict:hSumm]];
    } else {
        hlr.hotelList = nil;
    }
    
    double maxLatDelta = 0.0;
    double maxLonDelta = 0.0;
    double selectedLat = [SelectionCriteria singleton].latitude;
    double selectedLon = [SelectionCriteria singleton].longitude;
    for (EanHotelListHotelSummary *hotel in hlr.hotelList) {
        double latDelta = fabs(hotel.latitude - selectedLat);
        maxLatDelta = fmax(maxLatDelta, latDelta);
        
        double lonDelta = fabs(hotel.longitude - selectedLon);
        maxLonDelta = fmax(maxLonDelta, lonDelta);
    }
    hlr.maxLatitudeDelta = maxLatDelta;
    hlr.maxLongitudeDelta = maxLonDelta;
    
    return hlr;
}

@end
