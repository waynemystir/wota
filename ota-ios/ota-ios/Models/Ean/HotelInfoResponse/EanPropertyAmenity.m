//
//  EanPropertyAmenity.m
//  ota-ios
//
//  Created by WAYNE SMALL on 5/22/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanPropertyAmenity.h"

@implementation EanPropertyAmenity

+ (EanPropertyAmenity *)amenityFromDict:(NSDictionary *)dict {
    if (nil == dict) {
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanPropertyAmenity *pa = [[EanPropertyAmenity alloc] init];
    pa.amenityId = [[dict objectForKey:@"amenityId"] integerValue];
    pa.amenity = [dict objectForKey:@"amenity"];
    return pa;
}

@end
