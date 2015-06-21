//
//  WotaPlace.m
//  ota-ios
//
//  Created by WAYNE SMALL on 6/19/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "WotaPlace.h"
#import "AppEnvironment.h"

NSString * const kKeyPlacePlaceName = @"placeName";
NSString * const kKeyPlacePlaceId = @"placeId";
NSString * const kKeyPlaceLatitude = @"latitude";
NSString * const kKeyPlaceLongitude = @"longitude";
NSString * const kKeyPlaceDisplayName = @"displayName";

@implementation WotaPlace

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _placeName = [aDecoder decodeObjectForKey:kKeyPlacePlaceName];
        _placeId = [aDecoder decodeObjectForKey:kKeyPlacePlaceId];
        _latitude = [aDecoder decodeFloatForKey:kKeyPlaceLatitude];
        _longitude = [aDecoder decodeFloatForKey:kKeyPlaceLongitude];
        _displayName = [aDecoder decodeObjectForKey:kKeyPlaceDisplayName];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_placeName forKey:kKeyPlacePlaceName];
    [aCoder encodeObject:_placeId forKey:kKeyPlacePlaceId];
    [aCoder encodeFloat:_latitude forKey:kKeyPlaceLatitude];
    [aCoder encodeFloat:_longitude forKey:kKeyPlaceLongitude];
    [aCoder encodeObject:_displayName forKey:kKeyPlaceDisplayName];
}

#pragma mark Getters

- (NSString *)formattedWhereTo {
    return _displayName;
}

- (NSString *)formattedWhereToFirst {
    NSArray *wta = [_displayName componentsSeparatedByString:@", "];
    if ([wta count] > 0 && !stringIsEmpty(wta[0])) {
        return wta[0];
    } else {
        return @"";
    }
}

- (NSString *)formattedWhereToSecond {
    NSArray *wta = [_displayName componentsSeparatedByString:@", "];
    if ([wta count] > 1) {
        NSString *waynster = @"";
        for (int j = 1; j < [wta count]; j++) {
            NSString *separator = j == 1 ? @"" : @", ";
            waynster = [waynster stringByAppendingFormat:@"%@%@", separator, wta[j]];
        }
        return waynster;
    } else {
        return @"";
    }
}

@end
