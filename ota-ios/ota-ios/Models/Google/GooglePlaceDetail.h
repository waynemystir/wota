//
//  GooglePlaceDetail.h
//  ota-ios
//
//  Created by WAYNE SMALL on 3/25/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppEnvironment.h"

@interface GooglePlaceDetail : NSObject

@property (nonatomic, strong) NSDictionary *googlePlaceResultDict;
@property (nonatomic, strong) NSString *placeName;
@property (nonatomic, strong, setter=setPlaceId:) NSString *placeId;
@property (nonatomic, strong) NSString *formattedAddress;
@property (nonatomic, strong) NSArray *addressComponents;
@property (nonatomic, strong, getter=getGoogleAddressComponents) NSMutableArray *googleAddressComponents;
@property (nonatomic, strong) NSString *blankType;
@property (nonatomic, strong) NSString *airportShortName;
@property (nonatomic, strong) NSString *airportLongName;
@property (nonatomic, strong) NSString *establishmentShortName;
@property (nonatomic, strong) NSString *establishmentLongName;
@property (nonatomic, strong) NSString *naturalFeatureShortName;
@property (nonatomic, strong) NSString *naturalFeatureLongName;
@property (nonatomic, strong) NSString *pointOfInterestShortName;
@property (nonatomic, strong) NSString *pointOfInterestLongName;
@property (nonatomic, strong) NSString *parkShortName;
@property (nonatomic, strong) NSString *parkLongName;
@property (nonatomic, strong) NSString *streetNumberShortName;
@property (nonatomic, strong) NSString *streetNumberLongName;
@property (nonatomic, strong) NSString *routeShortName;
@property (nonatomic, strong) NSString *routeLongName;
@property (nonatomic, strong) NSString *premiseShortName;
@property (nonatomic, strong) NSString *premiseLongName;
@property (nonatomic, strong) NSString *neighborhoodShortName;
@property (nonatomic, strong) NSString *neighborhoodLongName;
@property (nonatomic, strong) NSString *sublocalityShortName;
@property (nonatomic, strong) NSString *sublocalityLongName;
@property (nonatomic, strong) NSString *localityShortName;
@property (nonatomic, strong) NSString *localityLongName;
@property (nonatomic, strong) NSString *postalTownShortName;
@property (nonatomic, strong) NSString *postalTownLongName;
@property (nonatomic, strong) NSString *administrativeAreaLevel3ShortName;
@property (nonatomic, strong) NSString *administrativeAreaLevel3LongName;
@property (nonatomic, strong) NSString *administrativeAreaLevel2ShortName;
@property (nonatomic, strong) NSString *administrativeAreaLevel2LongName;
@property (nonatomic, strong) NSString *administrativeAreaLevel1ShortName;
@property (nonatomic, strong) NSString *administrativeAreaLevel1LongName;
@property (nonatomic, strong) NSString *postalCodeShortName;
@property (nonatomic, strong) NSString *postalCodeLongName;
@property (nonatomic, strong) NSString *countryLongName;
@property (nonatomic, strong) NSString *countryShortName;
@property (nonatomic, strong) NSDictionary *geometry;
@property (nonatomic, strong) NSDictionary *location;
@property (nonatomic, setter=setLatitude:) double latitude;
@property (nonatomic, setter=setLongitude:) double longitude;
@property (nonatomic, strong) NSDictionary *viewport;
@property (nonatomic) double zoomRadius;
@property (nonatomic) PLACE_DETAIL_LEVEL placeDetailLevel;
@property (nonatomic, strong) NSArray *types;
@property (nonatomic) BOOL isLodging;

@property (nonatomic, strong, readonly) NSString *formattedWhereTo;
@property (nonatomic, strong, readonly) NSString *formattedWhereToFirst;
@property (nonatomic, strong, readonly) NSString *formattedWhereToSecond;

+ (GooglePlaceDetail *)placeDetailFromData:(NSData *)data;
+ (GooglePlaceDetail *)placeDetailFromGeoCodeData:(NSData *)data;
+ (GooglePlaceDetail *)placeDetailFromObject:(id)object wrappedInResult:(BOOL)wrapped;

@end
