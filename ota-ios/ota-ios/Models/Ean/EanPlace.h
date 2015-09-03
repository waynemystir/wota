//
//  EanPlace.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/14/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GooglePlaceDetail.h"

typedef NS_ENUM(NSUInteger, ADDRESS_VALIDITY_REASONS) {
    INVALID_STREET_ADDRESS = 1,
    INVALID_CITY = 2,
    INVALID_STATE = 3,
    INVALID_POSTAL = 4,
    INVALID_COUNTRY = 5,
    VALID_ADDRESS = 6
};

@interface EanPlace : NSObject

@property (nonatomic, strong) NSString *address1;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *stateProvinceCode;
@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) NSString *postalCode;
@property (nonatomic, strong) NSString *formattedAddress;
@property (nonatomic, strong) NSString *googleFormattedAddress;

/**
 *
 */
@property (nonatomic, strong, readonly) NSString *apiAddress1;
@property (nonatomic, strong, readonly) NSString *apiCity;
@property (nonatomic, strong, readonly) NSString *apiStateProvCode;
@property (nonatomic, strong, readonly) NSString *apiCountryCode;
@property (nonatomic, strong, readonly) NSString *apiPostalCode;

- (ADDRESS_VALIDITY_REASONS)isValidToSubmitToEanApiAsBillingAddress;

@end
