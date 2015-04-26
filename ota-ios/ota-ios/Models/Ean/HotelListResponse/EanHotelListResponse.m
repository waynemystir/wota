//
//  EanHotelListResponse.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/5/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanHotelListResponse.h"

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
    
    if ([hSumm isKindOfClass:[NSArray class]]) {
        hlr.hotelList = hSumm;
    } else if ([hSumm isKindOfClass:[NSDictionary class]]) {
        hlr.hotelList = [NSArray arrayWithObject:hSumm];
    } else {
        hlr.hotelList = nil;
    }
    
    return hlr;
}

@end
