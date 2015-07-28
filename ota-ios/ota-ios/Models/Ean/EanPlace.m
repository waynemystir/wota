//
//  EanPlace.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/14/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
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

- (ADDRESS_VALIDITY_REASONS)isValidToSubmitToEanApiAsBillingAddress {
    if (nil == self.address1 || [self.address1 length] < 2) {
        return INVALID_STREET_ADDRESS;
    }
    
    if (nil == self.city) {
        return INVALID_CITY;
    }
    
    if ([self.countryCode isEqualToString:@"US"] || [self.countryCode isEqualToString:@"CA"] || [self.countryCode isEqualToString:@"AU"]) {
        if (nil == self.stateProvinceCode) {
            return INVALID_STATE;
        }
    }
    
    if (nil == self.postalCode) {
        return INVALID_POSTAL;
    }
    
    if (nil == self.countryCode) {
        return INVALID_COUNTRY;
    }
    
    return VALID_ADDRESS;
}

+ (EanPlace *)eanPlaceFromGooglePlaceDetail:(GooglePlaceDetail *)gpd {
    if (nil == gpd) {
        return nil;
    }
    
    EanPlace *ep = [[EanPlace alloc] init];
    
    NSString *addressSpace = gpd.streetNumberLongName && gpd.routeLongName ? @" " : @"";
    
    ep.address1 = [[gpd.streetNumberLongName ? : @"" stringByAppendingString:addressSpace] stringByAppendingString:gpd.routeLongName ? : @""];
    
    ep.city = gpd.localityLongName ? : gpd.postalTownShortName ? : gpd.neighborhoodShortName ? : gpd.administrativeAreaLevel3ShortName;
    
    ep.stateProvinceCode = gpd.administrativeAreaLevel1ShortName;
    
    ep.countryCode = gpd.countryShortName;
    
    ep.postalCode = gpd.postalCodeShortName;
    
    if ([ep.countryCode isEqualToString:@"US"] || [ep.countryCode isEqualToString:@"CA"] || [ep.countryCode isEqualToString:@"AU"]) {
        ep.formattedAddress = [NSString stringWithFormat:@"%@, %@, %@ %@, %@", ep.address1, ep.city, ep.stateProvinceCode, ep.postalCode, ep.countryCode];
    } else {
        ep.formattedAddress = [NSString stringWithFormat:@"%@, %@ %@, %@", ep.address1, ep.city, ep.postalCode, ep.countryCode];
    }
    
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

#pragma mark EAN API Getters

- (NSString *)apiAddress1 {
    NSUInteger len = MIN(28, [self.address1 length]);
    return [self.address1 substringToIndex:len];
}

- (NSString *)apiCity {
    return self.city;
}

- (NSString *)apiStateProvCode {
    if ([self.countryCode isEqualToString:@"US"] || [self.countryCode isEqualToString:@"CA"]) {
        
        return self.stateProvinceCode;
        
    } else if ([self.countryCode isEqualToString:@"AU"]) {
        
        if ([self.stateProvinceCode isEqualToString:@"ACT"]) {
            return @"AC";
        } else if ([self.stateProvinceCode isEqualToString:@"NSW"]) {
            return @"NW";
        } else if ([self.stateProvinceCode isEqualToString:@"NT"]) {
            return @"NT";
        } else if ([self.stateProvinceCode isEqualToString:@"QLD"]) {
            return @"QL";
        } else if ([self.stateProvinceCode isEqualToString:@"SA"]) {
            return @"SA";
        } else if ([self.stateProvinceCode isEqualToString:@"TAS"]) {
            return @"TS";
        } else if ([self.stateProvinceCode isEqualToString:@"VIC"]) {
            return @"VC";
        } else if ([self.stateProvinceCode isEqualToString:@"WA"]) {
            return @"WT";
        } else {
            return nil;
        }
        
    } else {
        return nil;
    }
}

- (NSString *)apiCountryCode {
    return self.countryCode;
}

- (NSString *)apiPostalCode {
    return self.postalCode;
}

@end
