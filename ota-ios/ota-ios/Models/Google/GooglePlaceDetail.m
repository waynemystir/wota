//
//  GooglePlaceDetail.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/25/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "GooglePlaceDetail.h"
#import "GoogleAddressComponent.h"
#import <CoreLocation/CoreLocation.h>

static double const METERS_PER_MILE = 1609.344;

NSString * const kKeyPlaceId = @"placeId";
NSString * const kKeyLatitude = @"latitude";
NSString * const kKeyLongitude = @"longitude";
NSString * const kKeyDisplayName = @"displayName";

@interface GooglePlaceDetail ()

@property (nonatomic, strong) NSString *displayName;

@end

@implementation GooglePlaceDetail

+ (GooglePlaceDetail *)placeDetailFromData:(NSData *)data {
    if (data == nil) {
        return nil;
    }
    
    if (![data isKindOfClass:[NSData class]]) {
        return  nil;
    }
    
    NSError *error;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error != nil) {
        TrotterLog(@"ERROR:%s:%@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    NSString *respString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    TrotterLog(@"%@ PDFData:%@", NSStringFromClass(self.class), respString);
    
    return [self placeDetailFromObject:jsonDictionary wrappedInResult:YES];
}

+ (GooglePlaceDetail *)placeDetailFromGeoCodeData:(NSData *)data {
    if (data == nil) {
        return nil;
    }
    
    if (![data isKindOfClass:[NSData class]]) {
        return  nil;
    }
    
    NSError *error;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error != nil) {
        TrotterLog(@"ERROR:%s:%@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    NSString *respString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    TrotterLog(@"%@ PDFGeo:%@", NSStringFromClass(self.class), respString);
    
    return [self placeDetailFromGeocodeDict:jsonDictionary];
}

+ (GooglePlaceDetail *)placeDetailFromGeocodeDict:(NSDictionary *)dict {
    if (dict == nil) {
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    id resultsId = [dict objectForKey:@"results"];
    
    if (nil == resultsId || ![resultsId isKindOfClass:[NSArray class]] || [resultsId count] == 0) {
        return nil;
    }
    
    NSMutableArray *gpdsMut = [NSMutableArray array];
    for (int j = 0; j < [resultsId count]; j++) {
        GooglePlaceDetail *gpd = [self placeDetailFromObject:resultsId[j] wrappedInResult:NO];
        
        if ([gpd.types indexOfObject:@"neighborhood"] != NSNotFound
                || [gpd.types indexOfObject:@"airport"] != NSNotFound
//                || ([gpd.types indexOfObject:@"natural_feature"] != NSNotFound
//                    && [gpd.types indexOfObject:@"country"] == NSNotFound
//                    && [gpd.types indexOfObject:@"continent"] == NSNotFound
//                    && [gpd.types indexOfObject:@"political"] == NSNotFound)
//                || ([gpd.types indexOfObject:@"establishment"] != NSNotFound
//                    && [gpd.types indexOfObject:@"country"] == NSNotFound
//                    && [gpd.types indexOfObject:@"continent"] == NSNotFound
//                    && [gpd.types indexOfObject:@"political"] == NSNotFound)
                || [gpd.types indexOfObject:@"point_of_interest"] != NSNotFound
                || [gpd.types indexOfObject:@"park"] != NSNotFound) {
            return gpd;
        } /*else if ([gpd.types indexOfObject:@"sublocality"] != NSNotFound) {
            [gpdsMut addObject:gpd];
//            return gpd;
        } else if ([gpd.types indexOfObject:@"locality"] != NSNotFound) {
            [gpdsMut addObject:gpd];
//            return gpd;
        } else if ([gpd.types indexOfObject:@"route"] != NSNotFound) {
            [gpdsMut addObject:gpd];
            //            return gpd;
        } else if ([gpd.types indexOfObject:@"street_address"] != NSNotFound) {
            [gpdsMut addObject:gpd];
        } else if ([gpd.types indexOfObject:@"administrative_area_level_1"] != NSNotFound) {
            [gpdsMut addObject:gpd];
        }*/ else {
            [gpdsMut addObject:gpd];
        }
        
//        [gpdsMut addObject:gpd];
    }
    
    if ([gpdsMut count] == 1) {
        return gpdsMut[0];
    } else if ([gpdsMut count] > 1) {
        
        for (GooglePlaceDetail *wpd in gpdsMut) {
            if ([wpd.types indexOfObject:@"sublocality"] != NSNotFound) {
                return wpd;
            }
        }
        
        for (GooglePlaceDetail *wpd in gpdsMut) {
            if ([wpd.types indexOfObject:@"locality"] != NSNotFound) {
                return wpd;
            }
        }
        
        for (GooglePlaceDetail *wpd in gpdsMut) {
            if ([wpd.types indexOfObject:@"route"] != NSNotFound) {
                return wpd;
            }
        }
        
        for (GooglePlaceDetail *wpd in gpdsMut) {
            if ([wpd.types indexOfObject:@"street_address"] != NSNotFound) {
                return wpd;
            }
        }
        
        for (GooglePlaceDetail *wpd in gpdsMut) {
            if ([wpd.types indexOfObject:@"administrative_area_level_2"] != NSNotFound) {
                return wpd;
            }
        }
        
        for (GooglePlaceDetail *wpd in gpdsMut) {
            if ([wpd.types indexOfObject:@"administrative_area_level_1"] != NSNotFound) {
                return wpd;
            }
        }
        
        for (GooglePlaceDetail *wpd in gpdsMut) {
            if ([wpd.types indexOfObject:@"country"] != NSNotFound) {
                return wpd;
            }
        }
        
        return gpdsMut[0];
        
    } else {
        return nil;
    }
}

+ (GooglePlaceDetail *)placeDetailFromObject:(id)object wrappedInResult:(BOOL)wrapped {
    if (object == nil) {
        return nil;
    }
    
    if (![object isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    GooglePlaceDetail *gpd = [[GooglePlaceDetail alloc] init];
    
    gpd.googlePlaceResultDict = wrapped ? [object objectForKey:@"result"] : object;
    
    gpd.formattedAddress = [gpd.googlePlaceResultDict objectForKey:@"formatted_address"];
    gpd.addressComponents = [gpd.googlePlaceResultDict objectForKey:@"address_components"];
    [gpd parseAddressComponents];
    gpd.placeName = [gpd.googlePlaceResultDict objectForKey:@"name"];
    gpd.placeId = [gpd.googlePlaceResultDict objectForKey:@"place_id"];
    gpd.geometry = [gpd.googlePlaceResultDict objectForKey:@"geometry"];
    gpd.location = [gpd.geometry objectForKey:@"location"];
    gpd.latitude = [[gpd.location objectForKey:@"lat"] doubleValue];
    gpd.longitude = [[gpd.location objectForKey:@"lng"] doubleValue];
    gpd.viewport = [gpd.geometry objectForKey:@"viewport"];
    gpd.types = [gpd.googlePlaceResultDict objectForKey:@"types"];
    gpd.isLodging = [gpd.types containsObject:@"lodging"];
    
    [gpd setWotaDisplayName];
    
    return gpd;
}

- (void)parseAddressComponents {
    if (self.addressComponents == nil || ![self.addressComponents isKindOfClass:[NSArray class]] || [self.addressComponents count] == 0) {
        return;
    }
    
    for (NSObject *object in self.addressComponents) {
        if (nil == object || ![object isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        
        GoogleAddressComponent *gac = [GoogleAddressComponent addCompFromDict:(NSDictionary *)object];
        [self.googleAddressComponents addObject:gac];
        
        if ([gac.types count] == 0) {
            _blankType = gac.longName;
        }
        
        for (int j = 0; j < [gac.types count]; j++) {
            NSString *type = gac.types[j];
            
            if (stringIsEmpty(type)) {
                continue;
            } else if ([type isEqualToString:@"airport"]) {
                self.airportShortName = gac.shortName;
                self.airportLongName = gac.longName;
            } else if ([type isEqualToString:@"establishment"]) {
                self.establishmentShortName = gac.shortName;
                self.establishmentLongName = gac.longName;
            } else if ([type isEqualToString:@"natural_feature"]) {
                self.naturalFeatureShortName = gac.shortName;
                self.naturalFeatureLongName = gac.longName;
            } else if ([type isEqualToString:@"point_of_interest"]) {
                self.pointOfInterestShortName = gac.shortName;
                self.pointOfInterestLongName = gac.longName;
            } else if ([type isEqualToString:@"park"]) {
                self.parkShortName = gac.shortName;
                self.parkLongName = gac.longName;
            } else
                if ([type isEqualToString:@"street_number"]) {
                self.streetNumberShortName = gac.shortName;
                self.streetNumberLongName = gac.longName;
            } else if ([type isEqualToString:@"route"]) {
                self.routeShortName = gac.shortName;
                self.routeLongName = gac.longName;
            } else if ([type isEqualToString:@"premise"]) {
                self.premiseShortName = gac.shortName;
                self.premiseLongName = gac.longName;
            } else if ([type isEqualToString:@"neighborhood"]) {
                self.neighborhoodShortName = gac.shortName;
                self.neighborhoodLongName = gac.longName;
            } else if ([type isEqualToString:@"sublocality"]) {
                self.sublocalityShortName = gac.shortName;
                self.sublocalityLongName = gac.longName;
            } else if ([type isEqualToString:@"locality"]) {
                self.localityShortName = gac.shortName;
                self.localityLongName = gac.longName;
            } else if ([type isEqualToString:@"postal_town"]) {
                self.postalTownShortName = gac.shortName;
                self.postalTownLongName = gac.longName;
            } else if ([type isEqualToString:@"administrative_area_level_3"]) {
                self.administrativeAreaLevel3ShortName = gac.shortName;
                self.administrativeAreaLevel3LongName = gac.longName;
            } else if ([type isEqualToString:@"administrative_area_level_2"]) {
                self.administrativeAreaLevel2ShortName = gac.shortName;
                self.administrativeAreaLevel2LongName = gac.longName;
            } else if ([type isEqualToString:@"administrative_area_level_1"]) {
                self.administrativeAreaLevel1ShortName = gac.shortName;
                self.administrativeAreaLevel1LongName = gac.longName;
            } else if ([type isEqualToString:@"postal_code"]) {
                self.postalCodeShortName = gac.shortName;
                self.postalCodeLongName = gac.longName;
            } else if ([type isEqualToString:@"country"]) {
                self.countryShortName = gac.shortName;
                self.countryLongName = gac.longName;
            }
        }
    }
}

#pragma mark Getters and Setters

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

- (NSMutableArray *)getGoogleAddressComponents {
    if (nil == _googleAddressComponents) {
        _googleAddressComponents = [NSMutableArray array];
    }
    
    return _googleAddressComponents;
}

- (void)setWotaDisplayName {
    
    _zoomRadius = [self viewportToMilesRadius];
    
//    if (!stringIsEmpty(_blankType)) {
//        [self setDisplayName:_blankType];
//        return;
//    }
    
    if (!stringIsEmpty(_placeName) && [_types containsObject:@"country"] && [_placeName isEqualToString:_countryLongName]) {
        _placeDetailLevel = PLACE_LEVEL_COUNTRY;
        [self setDisplayName:_placeName];
        return;
    }
    
    NSString *neighborhood = _placeName ? : _blankType ? : _neighborhoodLongName ? : _airportLongName ? : /*_establishmentLongName ? : _naturalFeatureLongName ? : _pointOfInterestLongName ? :*/ _parkLongName ? : _sublocalityLongName ? : @"";
    
    NSString *city = _localityLongName ? : _postalTownLongName ? : _administrativeAreaLevel3LongName ? : /*_administrativeAreaLevel2LongName ? :*/ @"";
    
    neighborhood = [neighborhood isEqualToString:city] ? @"" : neighborhood;
    
    NSString *sepNeighbCity = !stringIsEmpty(neighborhood) && !stringIsEmpty(city) ? @", " : @"";
    
    NSString *neighbSepCity = [_types containsObject:@"administrative_area_level_1"] ? @"" : [NSString stringWithFormat:@"%@%@%@", neighborhood, sepNeighbCity, city];
    
    // In a case like the Appalachian Trail in PA
    neighbSepCity = !stringIsEmpty(neighbSepCity) ? neighbSepCity : _routeLongName ? : @"";
    
//    NSString *stateProvinceCode = (stringIsEmpty(neighbSepCity) ? _administrativeAreaLevel1LongName : _administrativeAreaLevel1ShortName) ? : @"";
    
    NSString *stateProvinceCode = stringIsEmpty(_administrativeAreaLevel1LongName) ? @"" : _administrativeAreaLevel1LongName;
    
//    neighbSepCity = [_types containsObject:@"administrative_area_level_1"] ? @"" : neighbSepCity;
    
    NSString *countryCode = _countryShortName ? : @"";
    
    NSString *countryName = _countryLongName ? : @"";
    
//    NSString *ccc = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    
    // TODO: Exception: try typing in Ozark and clicking Ozark Mountains
//    NSString *countryString = stringIsEmpty(neighbSepCity) && stringIsEmpty(stateProvinceCode) ? countryName : stringIsEmpty(countryCode) || [countryCode isEqualToString:ccc] ? @"" : [@", " stringByAppendingString:countryName];
    
    // TODO: Exception: try typing in Ozark and clicking Ozark Mountains
    NSString *countryString = stringIsEmpty(neighbSepCity) && stringIsEmpty(stateProvinceCode) ? countryName : !stringIsEmpty(countryName) ? [@", " stringByAppendingString:countryName] : @"";
    
    NSString *tmpDisplayName = @"";
    if ([countryCode isEqualToString:@"US"] || [countryCode isEqualToString:@"CA"] || [countryCode isEqualToString:@"AU"]) {
        
        // In a case like the Appalachian Trail in PA
        neighbSepCity = !stringIsEmpty(neighbSepCity) ? neighbSepCity : _routeLongName ? : @"";
        NSString *sepCityState = stringIsEmpty(neighbSepCity) || stringIsEmpty(stateProvinceCode) ? @"" : @", ";
        tmpDisplayName = [NSString stringWithFormat:@"%@%@%@%@", neighbSepCity, sepCityState, stateProvinceCode, countryString];
        
    } else {
        
        // Analgous to Appalachian Trail case above but we want to be stingy abroad with this rule
        neighbSepCity = stringIsEmpty(neighbSepCity) && stringIsEmpty(stateProvinceCode) ? _routeLongName : neighbSepCity ? : @"";
        
        if (!stringIsEmpty(neighbSepCity)) {
            tmpDisplayName = [NSString stringWithFormat:@"%@%@", neighbSepCity, countryString];
        } else if (!stringIsEmpty(stateProvinceCode)) {
            tmpDisplayName = [NSString stringWithFormat:@"%@%@", stateProvinceCode, countryString];
        } else if (!stringIsEmpty(countryName)) {
            tmpDisplayName = [NSString stringWithFormat:@"%@", countryName];
        }
    }
    
    if (!stringIsEmpty(neighbSepCity) && ![_types containsObject:@"airport"] && ![_types containsObject:@"transit_station"]
            && (!stringIsEmpty(neighborhood) || [neighbSepCity isEqualToString:_routeLongName])) {
        _placeDetailLevel = PLACE_LEVEL_NEIGHBORHOOD;
    } else if (!stringIsEmpty(neighbSepCity) && !stringIsEmpty(city)) {
        _placeDetailLevel = PLACE_LEVEL_CITY;
    } else if (!stringIsEmpty(stateProvinceCode)) {
        _placeDetailLevel = PLACE_LEVEL_STATE;
    } else if (!stringIsEmpty(countryName)) {
        _placeDetailLevel = PLACE_LEVEL_COUNTRY;
    } else {
        _placeDetailLevel = PLACE_LEVEL_EMPTY;
    }
    
    [self setDisplayName:tmpDisplayName];
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

- (double)viewportToMilesRadius {
    if (!_viewport) {
        return 0.0;
    }
    
    NSDictionary *northeast = [_viewport objectForKey:@"northeast"];
    if (!northeast) {
        return 0.0;
    }
    
    NSDictionary *southwest = [_viewport objectForKey:@"southwest"];
    if (!southwest) {
        return 0.0;
    }
    
    double neLat = [[northeast objectForKey:@"lat"] doubleValue];
    double neLng = [[northeast objectForKey:@"lng"] doubleValue];
    double swLat = [[southwest objectForKey:@"lat"] doubleValue];
    double swLng = [[southwest objectForKey:@"lng"] doubleValue];
    
    CLLocation *neLoc = [[CLLocation alloc] initWithLatitude:neLat longitude:neLng];
    CLLocation *swLoc = [[CLLocation alloc] initWithLatitude:swLat longitude:swLng];
    
    CLLocationDistance distance = [swLoc distanceFromLocation:neLoc];
    return distance / METERS_PER_MILE / 1.0;
}

@end
