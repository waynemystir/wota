//
//  GooglePlaceMarker.h
//  ota-ios
//
//  Created by WAYNE SMALL on 6/7/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "GoogleNearbyPlace.h"

@interface GooglePlaceMarker : GMSMarker

@property (nonatomic, strong) GoogleNearbyPlace *place;

- (id)initWithPlace:(GoogleNearbyPlace *)place;

@end
