//
//  GooglePlaces.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/12/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "GooglePlaces.h"
#import "GooglePlaceDetail.h"

@implementation GooglePlaces

+ (GooglePlaces *)placesFromData:(NSData *)data {
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
    
    return [self placesFromDict:respDict];
}

+ (GooglePlaces *)placesFromDict:(NSDictionary *)dict {
    if (nil == dict) {
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    id reslts = [dict objectForKey:@"results"];
    
    if (nil == reslts || ![reslts isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    GooglePlaces *gps = [[GooglePlaces alloc] init];
    
    for (NSObject *object in reslts) {
        if (nil == object || ![object isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        
        GooglePlaceDetail *gpd = [GooglePlaceDetail placeDetailFromObject:object wrappedInResult:NO];
        
        if (nil != gpd) {
            [gps.placesArray addObject:gpd];
        }
    }
    
    return gps;
}

- (NSMutableArray *)getPlacesArray {
    if (nil == _placesArray) {
        _placesArray = [NSMutableArray array];
    }
    
    return _placesArray;
}

@end
