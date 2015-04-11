//
//  EanHotelListResponse.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/5/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanHotelListResponse.h"

@implementation EanHotelListResponse

+ (NSArray *)hotelListFromData:(NSData *)data {
    return [self hotelListResponseFromData:data].hotelList;
}

+ (EanHotelListResponse *)hotelListResponseFromData:(NSData *)data {
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
    
    return [self hotelListResponseFromDict:respDict];
}

+ (EanHotelListResponse *)hotelListResponseFromDict:(NSDictionary *)dict {
    if (nil == dict) {
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    id idHlr = [dict objectForKey:@"HotelListResponse"];
    
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
