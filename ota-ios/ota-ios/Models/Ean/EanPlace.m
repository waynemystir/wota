//
//  EanPlace.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/14/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanPlace.h"

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

@end
