//
//  GooglePlaceDetail.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/25/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "GooglePlaceDetail.h"

@interface GooglePlaceDetail ()

@property (nonatomic, strong) NSDictionary *dictionary;

@end

@implementation GooglePlaceDetail

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self != nil) {
        _dictionary = dictionary;
    }
    return self;
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
    return gpd;
}

- (void)parseAddressComponents {
    if (self.addressComponents == nil) {
        return;
    }
    
    
}

@end
