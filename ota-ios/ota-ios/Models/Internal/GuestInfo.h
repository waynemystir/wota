//
//  GuestInfo.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/11/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EanPlace.h"

extern NSUInteger const MAX_FIRST_NAME_LENGTH;
extern NSUInteger const MAX_LAST_NAME_LENGTH;
extern NSUInteger const MAX_EMAIL_LENGTH;

@interface GuestInfo : NSObject <NSCoding>

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *internationalCallingCode;
@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) NSString *phoneNumber;

+ (GuestInfo *)singleton;
+ (void)deleteGuest:(GuestInfo *)guest;

@property (nonatomic, strong, readonly) NSString *apiPhoneNumber;

@end
