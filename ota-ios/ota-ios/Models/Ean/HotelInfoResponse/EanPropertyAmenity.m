//
//  EanPropertyAmenity.m
//  ota-ios
//
//  Created by WAYNE SMALL on 5/22/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "EanPropertyAmenity.h"

@interface EanPropertyAmenity ()

@property (nonatomic, strong) NSString *amenity;

@end

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

- (NSString *)amenityName {
    return [[_amenity stringByReplacingOccurrencesOfString:@"Year Built1" withString:@"Year Built 1"] stringByReplacingOccurrencesOfString:@"Year Built2" withString:@"Year Built 2"];
}

@end
