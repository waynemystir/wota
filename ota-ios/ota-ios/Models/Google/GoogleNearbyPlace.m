//
//  GoogleNearbyPlace.m
//  ota-ios
//
//  Created by WAYNE SMALL on 6/7/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "GoogleNearbyPlace.h"

@implementation GoogleNearbyPlace

+ (GoogleNearbyPlace *)placeNearbyFromDict:(NSDictionary *)dict {
    if (dict == nil) {
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    GoogleNearbyPlace *gnp = [[GoogleNearbyPlace alloc] init];
    gnp.placeId = [dict objectForKey:@"place_id"];
    gnp.placeName = [dict objectForKey:@"name"];
    gnp.geometry = [dict objectForKey:@"geometry"];
    gnp.location = [gnp.geometry objectForKey:@"location"];
    gnp.latitude = [[gnp.location objectForKey:@"lat"] doubleValue];
    gnp.longitude = [[gnp.location objectForKey:@"lng"] doubleValue];
    gnp.types = [dict objectForKey:@"types"];
    gnp.iconUrl = [dict objectForKey:@"icon"];
    gnp.openingHours = [dict objectForKey:@"opening_hours"];
    gnp.photos = [dict objectForKey:@"photos"];
    gnp.rating = [dict objectForKey:@"rating"];
    gnp.reference = [dict objectForKey:@"reference"];
    gnp.vicinity = [dict objectForKey:@"vicinity"];
    
    return gnp;
}

@end
