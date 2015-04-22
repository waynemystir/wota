//
//  EanPlace.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/14/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanPlace.h"

NSString * const kKeyAddress1 = @"address1";
NSString * const kKeyCity = @"city";
NSString * const kKeyStateProvCode = @"stateProvinceCode";
NSString * const kKeyCountryCode = @"countryCode";
NSString * const kKeyPostalCode = @"postalCode";
NSString * const kKeyFormattedAddress = @"formattedAddress";
NSString * const kKeyGoogleFormattedAddress = @"googleFormattedAddress";

@implementation EanPlace

- (BOOL)isValidToSubmitAsBillingAddress {
    if (nil == self.address1 || [self.address1 length] < 2) {
        return NO;
    }
    
    if (nil == self.city) {
        return NO;
    }
    
    if (nil == self.stateProvinceCode) {
        return NO;
    }
    
    if (nil == self.postalCode) {
        return NO;
    }
    
    if (nil == self.countryCode) {
        return NO;
    }
    
    return YES;
}

+ (EanPlace *)eanPlaceFromGooglePlaceDetail:(GooglePlaceDetail *)gpd {
    if (nil == gpd) {
        return nil;
    }
    
    EanPlace *ep = [[EanPlace alloc] init];
    
    ep.address1 = [NSString stringWithFormat:@"%@ %@", gpd.streetNumberLongName, gpd.routeLongName];
    
    ep.city = gpd.localityLongName ? : gpd.postalTownShortName ? : gpd.neighborhoodShortName ? : gpd.administrativeAreaLevel3ShortName;
    
    ep.stateProvinceCode = gpd.administrativeAreaLevel1ShortName;
    
    ep.countryCode = gpd.countryShortName;
    
    ep.postalCode = gpd.postalCodeShortName;
    
    ep.formattedAddress = [NSString stringWithFormat:@"%@, %@, %@ %@ %@", ep.address1, ep.city, ep.stateProvinceCode, ep.postalCode, ep.countryCode];
    
    ep.googleFormattedAddress = gpd.formattedAddress;
    
    return ep;
}

#pragma mark NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _address1 = [aDecoder decodeObjectForKey:kKeyAddress1];
        _city = [aDecoder decodeObjectForKey:kKeyCity];
        _stateProvinceCode = [aDecoder decodeObjectForKey:kKeyStateProvCode];
        _countryCode = [aDecoder decodeObjectForKey:kKeyCountryCode];
        _postalCode = [aDecoder decodeObjectForKey:kKeyPostalCode];
        _formattedAddress = [aDecoder decodeObjectForKey:kKeyFormattedAddress];
        _googleFormattedAddress = [aDecoder decodeObjectForKey:kKeyGoogleFormattedAddress];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_address1 forKey:kKeyAddress1];
    [aCoder encodeObject:_city forKey:kKeyCity];
    [aCoder encodeObject:_stateProvinceCode forKey:kKeyStateProvCode];
    [aCoder encodeObject:_countryCode forKey:kKeyCountryCode];
    [aCoder encodeObject:_postalCode forKey:kKeyPostalCode];
    [aCoder encodeObject:_formattedAddress forKey:kKeyFormattedAddress];
    [aCoder encodeObject:_googleFormattedAddress forKey:kKeyGoogleFormattedAddress];
}

@end
