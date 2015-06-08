//
//  GoogleNearbyPlace.h
//  ota-ios
//
//  Created by WAYNE SMALL on 6/7/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoogleNearbyPlace : NSObject

@property (nonatomic, strong) NSString *placeId;
@property (nonatomic, strong) NSString *placeName;
@property (nonatomic, strong) NSDictionary *geometry;
@property (nonatomic, strong) NSDictionary *location;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic, strong) NSArray *types;
@property (nonatomic, strong) NSString *iconUrl;
@property (nonatomic, strong) NSDictionary *openingHours;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, strong) NSString *reference;
@property (nonatomic, strong) NSString *vicinity;

+ (GoogleNearbyPlace *)placeNearbyFromDict:(NSDictionary *)dict;

@end
