//
//  WotaPlace.m
//  ota-ios
//
//  Created by WAYNE SMALL on 6/19/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "WotaPlace.h"

NSString * const kKeyPlacePlaceName = @"placeName";
NSString * const kKeyPlacePlaceId = @"placeId";
NSString * const kKeyPlaceLatitude = @"latitude";
NSString * const kKeyPlaceLongitude = @"longitude";
NSString * const kKeyZoomRadius = @"zoomRadius";
NSString * const kKeyPlaceDetailLevel = @"placeDetailLevel";
NSString * const kKeyPlaceDisplayName = @"displayName";
NSString * const kKeyIsLodging = @"isLodging";

@implementation WotaPlace

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _placeName = [aDecoder decodeObjectForKey:kKeyPlacePlaceName];
        _placeId = [aDecoder decodeObjectForKey:kKeyPlacePlaceId];
        _latitude = [aDecoder decodeDoubleForKey:kKeyPlaceLatitude];
        _longitude = [aDecoder decodeDoubleForKey:kKeyPlaceLongitude];
        _zoomRadius = [aDecoder decodeDoubleForKey:kKeyZoomRadius];
        _placeDetailLevel = [aDecoder decodeIntForKey:kKeyPlaceDetailLevel];
        _displayName = [aDecoder decodeObjectForKey:kKeyPlaceDisplayName];
        _isLodging = [aDecoder decodeBoolForKey:kKeyIsLodging];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_placeName forKey:kKeyPlacePlaceName];
    [aCoder encodeObject:_placeId forKey:kKeyPlacePlaceId];
    [aCoder encodeDouble:_latitude forKey:kKeyPlaceLatitude];
    [aCoder encodeDouble:_longitude forKey:kKeyPlaceLongitude];
    [aCoder encodeDouble:_zoomRadius forKey:kKeyZoomRadius];
    [aCoder encodeInt:_placeDetailLevel forKey:kKeyPlaceDetailLevel];
    [aCoder encodeObject:_displayName forKey:kKeyPlaceDisplayName];
    [aCoder encodeBool:_isLodging forKey:kKeyIsLodging];
}

#pragma mark Getters

- (NSString *)formattedWhereTo {
    return _displayName;
}

- (NSString *)formattedWhereToFirst {
    NSArray *wta = [_displayName componentsSeparatedByString:@", "];
    if (/*_placeDetailLevel == PLACE_LEVEL_NEIGHBORHOOD &&*/ [wta count] > 1
            && !stringIsEmpty(wta[0]) && [wta[0] length] <= 29 && !stringIsEmpty(wta[1])) {
        return [NSString stringWithFormat:@"%@, %@", wta[0], wta[1]];
    } else if ([wta count] > 0 && !stringIsEmpty(wta[0])) {
        return wta[0];
    } else {
        return @"";
    }
}

- (NSString *)formattedWhereToSecond {
    NSArray *wta = [_displayName componentsSeparatedByString:@", "];
    int fromIndex;
    if (/*_placeDetailLevel == PLACE_LEVEL_NEIGHBORHOOD &&*/ [wta count] > 1
        && !stringIsEmpty(wta[0]) && [wta[0] length] <= 29 && !stringIsEmpty(wta[1])) {
        fromIndex = 2;
    } else {
        fromIndex = 1;
    }
    
    if ([wta count] > fromIndex) {
        NSString *waynster = @"";
        for (int j = fromIndex; j < [wta count]; j++) {
            NSString *separator = j == fromIndex ? @"" : @", ";
            waynster = [waynster stringByAppendingFormat:@"%@%@", separator, wta[j]];
        }
        return waynster;
    } else {
        return @"";
    }
}

- (double)zoomRadius {
    if (_zoomRadius != 0.0) {
        return _zoomRadius;
    }
    
    switch (_placeDetailLevel) {
        case PLACE_LEVEL_NEIGHBORHOOD:
            return 2.0;
        case PLACE_LEVEL_CITY:
            return 12.0;
        case PLACE_LEVEL_STATE:
            return 50.0;
        case PLACE_LEVEL_COUNTRY:
            return 50.0;
        case PLACE_LEVEL_EMPTY:
            return 12.0;
            
        default:
            return 12.0;
    }
}

@end
