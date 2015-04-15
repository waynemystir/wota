//
//  EanPlace.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/14/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GooglePlaceDetail.h"

@interface EanPlace : NSObject

@property (nonatomic, strong) NSString *address1;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *stateProvinceCode;
@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) NSString *postalCode;
@property (nonatomic, strong) NSString *formattedAddress;
@property (nonatomic, strong) NSString *googleFormattedAddress;

+ (EanPlace *)eanPlaceFromGooglePlaceDetail:(GooglePlaceDetail *)gpd;

@end
