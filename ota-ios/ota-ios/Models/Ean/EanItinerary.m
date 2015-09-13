//
//  EanItinerary.m
//  ota-ios
//
//  Created by WAYNE SMALL on 9/12/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanItinerary.h"
#import "AppEnvironment.h"

@implementation EanItinerary

+ (EanItinerary *)itineraryFromDict:(NSDictionary *)dict {
    if (nil == dict) {
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanItinerary *itin = [[EanItinerary alloc] init];
    
    itin.itineraryId = [[dict objectForKey:@"itineraryId"] integerValue];
    itin.affiliateId = [[dict objectForKey:@"affiliateId"] integerValue];
    itin.creationDate = [kEanApiDateFormatter() dateFromString:[dict objectForKey:@"creationDate"]];
    itin.itineraryStartDate = [kEanApiDateFormatter() dateFromString:[dict objectForKey:@"itineraryStartDate"]];
    itin.itineraryEndDate = [kEanApiDateFormatter() dateFromString:[dict objectForKey:@"itineraryEndDate"]];
    itin.hotelConfirmation = [EanHotelConfirmation confirmFromDict:[dict objectForKey:@"HotelConfirmation"]];
    
    return itin;
}

@end
