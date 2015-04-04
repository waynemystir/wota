//
//  GooglePlaceDetail.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/25/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "GooglePlaceDetail.h"
#import "AppEnvironment.h"

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
    
    return [self placeDetailFromObject:jsonDictionary];
}

+ (GooglePlaceDetail *)placeDetailFromObject:(id)object {
    if (object == nil) {
        return nil;
    }
    
    if (![object isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    GooglePlaceDetail *gpd = [[GooglePlaceDetail alloc] initWithDictionary:object];
    gpd.googlePlaceResultDict = [object objectForKey:@"result"];
    gpd.formattedAddress = [gpd.googlePlaceResultDict objectForKey:@"formatted_address"];
    gpd.addressComponents = [gpd.googlePlaceResultDict objectForKey:@"address_components"];
    gpd.placeId = [gpd.googlePlaceResultDict objectForKey:@"place_id"];
    gpd.geometry = [gpd.googlePlaceResultDict objectForKey:@"geometry"];
    gpd.location = [gpd.geometry objectForKey:@"location"];
    gpd.latitude = [[gpd.location objectForKey:@"lat"] doubleValue];
    gpd.longitude = [[gpd.location objectForKey:@"lng"] doubleValue];
    
    [gpd save];
    
    return gpd;
}

- (void)parseAddressComponents {
    if (self.addressComponents == nil) {
        return;
    }
    
    
}

#pragma mark Getters and Setters

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

@end
