//
//  GoogleNearbyPlaces.h
//  ota-ios
//
//  Created by WAYNE SMALL on 6/7/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoogleNearbyPlaces : NSObject

@property (nonatomic, strong) NSArray *nearbyPlaces;
@property (nonatomic, strong) NSString *nextPageToken;

+ (GoogleNearbyPlaces *)placesFromResponseData:(NSData *)data;

@end
