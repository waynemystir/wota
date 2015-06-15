//
//  GooglePlaceDetail.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/25/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "GooglePlaceDetail.h"
#import "AppEnvironment.h"
#import "GoogleAddressComponent.h"

NSString * const kKeyPlaceId = @"placeId";
NSString * const kKeyLatitude = @"latitude";
NSString * const kKeyLongitude = @"longitude";

@interface GooglePlaceDetail ()

@property (nonatomic, strong) NSDictionary *dictionary;

@end

@implementation GooglePlaceDetail

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _placeId = [aDecoder decodeObjectForKey:kKeyPlaceId];
        _latitude = [aDecoder decodeFloatForKey:kKeyLatitude];
        _longitude = [aDecoder decodeFloatForKey:kKeyLongitude];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_placeId forKey:kKeyPlaceId];
    [aCoder encodeFloat:_latitude forKey:kKeyLatitude];
    [aCoder encodeFloat:_longitude forKey:kKeyLongitude];
}

+ (NSString *)pathToGooglePlaceDetailForId:(NSString *)placeId {
    return [kWotaCacheGooglePlaceDetailDirectory() stringByAppendingFormat:@"/%@", placeId];
}

- (BOOL)save {
    BOOL saveResult = [NSKeyedArchiver archiveRootObject:self toFile:[[self class] pathToGooglePlaceDetailForId:_placeId]];
    return saveResult;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self != nil) {
        _dictionary = dictionary;
    }
    return self;
}

+ (GooglePlaceDetail *)placeDetailFromId:(NSString *)placeId {
    GooglePlaceDetail * _gpd = nil;
    NSString *path = [self pathToGooglePlaceDetailForId:placeId];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        _gpd = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    }
    
    return _gpd;
}

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
        NSLog(@"");
        return nil;
    }
    
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
        NSLog(@"");
        return nil;
    }
    
    NSString *respString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@ PDFGeo:%@", NSStringFromClass(self.class), respString);
    
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
        
        if ([gpd.types indexOfObject:@"neighborhood"] != NSNotFound) {
            return gpd;
        } else if ([gpd.types indexOfObject:@"locality"] != NSNotFound) {
            return gpd;
        }
        
        [gpdsMut addObject:gpd];
    }
    
    if ([gpdsMut count] > 0) {
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
    
    GooglePlaceDetail *gpd = [[GooglePlaceDetail alloc] initWithDictionary:object];
    
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
    gpd.types = [gpd.googlePlaceResultDict objectForKey:@"types"];
    
    [gpd save];
    
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
        
        for (int j = 0; j < [gac.types count]; j++) {
            NSString *type = gac.types[j];
            
            if (nil == type || [type isEqualToString:@""]) {
                continue;
            } else if ([type isEqualToString:@"street_number"]) {
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
    return _placeName ? : _formattedAddress;
}

- (void)setPlaceId:(NSString *)placeId {
    _placeId = placeId;
    [self save];
}

- (void)setLatitude:(double)latitude {
    _latitude = latitude;
    [self save];
}

- (void)setLongitude:(double)longitude {
    _longitude = longitude;
    [self save];
}

- (NSMutableArray *)getGoogleAddressComponents {
    if (nil == _googleAddressComponents) {
        _googleAddressComponents = [NSMutableArray array];
    }
    
    return _googleAddressComponents;
}

@end
