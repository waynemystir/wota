//
//  GuestInfo.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/11/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GuestInfo : NSObject <NSCoding>

@property (nonatomic, strong, setter=setFirstName:) NSString *firstName;
@property (nonatomic, strong, setter=setLastName:) NSString *lastName;
@property (nonatomic, strong, setter=setEmail:) NSString *email;
@property (nonatomic, strong, setter=setPhoneNumber:) NSString *phoneNumber;
@property (nonatomic, strong, setter=setAddress1:) NSString *address1;
@property (nonatomic, strong, setter=setCity:) NSString *city;
@property (nonatomic, strong, setter=setStateProvinceCode:) NSString *stateProvinceCode;
@property (nonatomic, strong, setter=setCountryCode:) NSString *countryCode;
@property (nonatomic, strong, setter=setPostalCode:) NSString *postalCode;

+ (GuestInfo *)singleton;

@end
