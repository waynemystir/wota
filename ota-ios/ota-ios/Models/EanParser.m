//
//  EanHotelParser.m
//  ean-ota-ios
//
//  Created by WAYNE SMALL on 3/21/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanParser.h"

@implementation EanParser

+ (NSArray *)parseHotelListResponse:(NSData *)responseData {
//    NSString *jsonResponse = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//    NSLog(@"%@.%@ RESPONSE:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), jsonResponse);
    
    if (responseData == nil) {
        NSLog(@"%@.%@ No response data returned", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSError *error = nil;
    id results = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
    if (error != nil) {
        NSLog(@"%@.%@ Error converting data to JSON:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [error localizedDescription]);
        return nil;
    }
    
    if (![NSJSONSerialization isValidJSONObject:results]) {
        NSLog(@"%@.%@ Response is not valid JSON", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
        return nil;
    }
    
    if (![results isKindOfClass:[NSDictionary class]]) {
        NSLog(@"%@.%@ results type:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), NSStringFromClass([results class]));
        return nil;
    }
    
    NSDictionary *resDict = (NSDictionary *)results;
    id hotelListResponse = [resDict objectForKey:@"HotelListResponse"];
    //*******************
    // TODO: need to check hotelListResponse for EanWsError, particularly for "Multiple locations found"
    //*******************
    
//    NSLog(@"%@.%@ HOTEL_LIST_RESPONSE:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [hotelListResponse description]);
    
    id hotelList = [hotelListResponse objectForKey:@"HotelList"];
//    NSLog(@"%@.%@ HOTEL_LIST:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [hotelList description]);
    
    id hotelSummary = [hotelList objectForKey:@"HotelSummary"];
    NSLog(@"%@.%@ HotelSummaryAAA:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [hotelSummary description]);
    
    // TODO: apparently this hotelSummary could be a dictionary
    // Handle this scenario
    return hotelSummary;
}

@end
