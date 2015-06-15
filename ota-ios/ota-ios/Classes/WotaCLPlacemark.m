//
//  WotaCLPlacemark.m
//  ota-ios
//
//  Created by WAYNE SMALL on 6/14/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "WotaCLPlacemark.h"
#import "AppEnvironment.h"

@implementation WotaCLPlacemark

- (NSString *)formattedWhereTo {
    NSDictionary *pmDict = self.addressDictionary;
//    NSString *abString = ABCreateStringWithAddressDictionary(pmDict, YES);
//    NSLog(@"this should be interesting hey:%@", abString);
    
//    NSString *sublocality = [pmDict objectForKey:@"SubLocality"];
    NSString *city = [pmDict objectForKey:@"City"];
    NSString *state = [pmDict objectForKey:@"State"];
    NSString *countryCode = [pmDict objectForKey:@"CountryCode"];
    NSString *ocean = [pmDict objectForKey:@"Ocean"];
    
    NSString *formattedWT;
    
    if (!stringIsEmpty(city)) {
        formattedWT = [self appendBaseString:city state:state country:countryCode];
    } else if (!stringIsEmpty(state)) {
        formattedWT = [self appendCountryString:state country:countryCode];
    } else if (!stringIsEmpty(ocean)) {
        formattedWT = [self appendBaseString:ocean state:state country:countryCode];
    }
    
    return formattedWT;
}

- (NSString *)appendBaseString:(NSString *)baseString state:(NSString *)state country:(NSString *)country {
    baseString = [self appendStateString:baseString state:state];
    return [self appendCountryString:baseString country:country];
}

- (NSString *)appendStateString:(NSString *)baseString state:(NSString *)state {
    return !stringIsEmpty(state) ? [baseString stringByAppendingFormat:@", %@", state] : baseString;
}

- (NSString *)appendCountryString:(NSString *)baseString country:(NSString *)country {
    if (stringIsEmpty(country)) {
        return baseString;
    }
    
    NSString *ccc = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    if ([ccc isEqualToString:country]) {
        return baseString;
    }
    
    return [baseString stringByAppendingFormat:@", %@", country];
}

@end
