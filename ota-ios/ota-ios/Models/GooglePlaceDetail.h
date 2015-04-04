//
//  GooglePlaceDetail.h
//  ota-ios
//
//  Created by WAYNE SMALL on 3/25/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GooglePlaceDetail : NSObject <NSCoding>

@property (nonatomic, strong) NSDictionary *googlePlaceResultDict;
@property (nonatomic, strong, setter=setPlaceId:) NSString *placeId;
@property (nonatomic, strong) NSString *formattedAddress;
@property (nonatomic, strong) NSArray *addressComponents;
@property (nonatomic, strong) NSString *postalCode;
@property (nonatomic, strong) NSString *countryLongName;
@property (nonatomic, strong) NSString *countryShortName;
@property (nonatomic, strong) NSDictionary *geometry;
@property (nonatomic, strong) NSDictionary *location;
@property (nonatomic, setter=setLatitude:) double latitude;
@property (nonatomic, setter=setLongitude:) double longitude;

+ (GooglePlaceDetail *)placeDetailFromId:(NSString *)placeId;
+ (GooglePlaceDetail *)placeDetailFromData:(NSData *)data;
+ (GooglePlaceDetail *)placeDetailFromObject:(id)object;

@end
