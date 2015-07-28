//
//  GooglePlace.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/24/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "GooglePlace.h"

@implementation GooglePlace

+ (GooglePlace *)placeFromObject:(id)object {
    if (object == nil) {
        return nil;
    }
    
    GooglePlace *place = [[GooglePlace alloc] init];
    
    //***************************************************************
    // TODO: handle cases where the following values are not empty or wrong data type
    //***************************************************************
//    NSArray *terms = [object objectForKey:@"terms"];
//    id theName = [terms objectAtIndex:0];
//    place.placeName = [theName objectForKey:@"value"];
    
    place.placeName = [object objectForKey:@"description"];
    place.placeId = [object objectForKey:@"place_id"];
    //***************************************************************
    
    return place;
}

@end
