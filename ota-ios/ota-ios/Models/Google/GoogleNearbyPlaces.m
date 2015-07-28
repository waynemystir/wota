//
//  GoogleNearbyPlaces.m
//  ota-ios
//
//  Created by WAYNE SMALL on 6/7/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "GoogleNearbyPlaces.h"
#import "GoogleNearbyPlace.h"

@implementation GoogleNearbyPlaces

+ (GoogleNearbyPlaces *)placesFromResponseData:(NSData *)data {
    if (data == nil) {
        return nil;
    }
    
    NSError *error = nil;
    id respDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error != nil) {
        NSLog(@"%@.%@ ERROR trying to deserialize JSON data:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), error);
        return nil;
    }
    
    if (![NSJSONSerialization isValidJSONObject:respDict]) {
        NSLog(@"%@.%@ ERROR: Response is not valid JSON", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSString *respString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@ JSON Response String:%@", NSStringFromClass(self.class), respString);
    
    NSArray *results = [respDict objectForKey:@"results"];
    if (nil == results || ![results isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    GoogleNearbyPlaces *gnps = [[GoogleNearbyPlaces alloc] init];
    NSMutableArray *tmpNp = [NSMutableArray array];
    
    for (NSDictionary *obj in results) {
        GoogleNearbyPlace *gnp = [GoogleNearbyPlace placeNearbyFromDict:obj];
        [tmpNp addObject:gnp];
    }
    
    gnps.nearbyPlaces = [NSArray arrayWithArray:tmpNp];
    gnps.nextPageToken = [respDict objectForKey:@"next_page_token"];
    
    return gnps;
}

@end
