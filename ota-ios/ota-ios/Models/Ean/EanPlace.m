//
//  EanPlace.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/14/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "EanPlace.h"

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
