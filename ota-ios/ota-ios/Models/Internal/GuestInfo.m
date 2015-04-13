//
//  GuestInfo.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/11/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "GuestInfo.h"
#import "AppEnvironment.h"

NSString * const kKeyFirstName = @"first_name";
NSString * const kKeyLastName = @"last_name";
NSString * const kKeyEmail = @"email_address";
NSString * const kKeyPhoneNumber = @"phone_number";
NSString * const kKeyAddress1 = @"address_1";
NSString * const kKeyCity = @"city";
NSString * const kKeyStateProvinceCode = @"stateProvinceCode";
NSString * const kKeyCountryCode = @"countryCode";

@implementation GuestInfo

+ (GuestInfo *)singleton {
    static GuestInfo *_guestInfo = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _guestInfo = [self unarchiveGuestInfo];
    });
    
    return _guestInfo;
}

+ (GuestInfo *)unarchiveGuestInfo {
    GuestInfo *_guestInfo = nil;
    
    NSString* path = [self pathForGuestInfo];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        _guestInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    }
    
    if (nil == _guestInfo) {
        _guestInfo = [[self alloc] init];
    }
    
    return _guestInfo;
}

- (void)save {
    [NSKeyedArchiver archiveRootObject:self toFile:[[self class] pathForGuestInfo]];
}

+ (NSString *)pathForGuestInfo {
    return [kWotaCacheDirectory() stringByAppendingFormat:@"/%@", @"guest_info"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _firstName = [aDecoder decodeObjectForKey:kKeyFirstName];
        _lastName = [aDecoder decodeObjectForKey:kKeyLastName];
        _email = [aDecoder decodeObjectForKey:kKeyEmail];
        _phoneNumber = [aDecoder decodeObjectForKey:kKeyPhoneNumber];
        _address1 = [aDecoder decodeObjectForKey:kKeyAddress1];
        _city = [aDecoder decodeObjectForKey:kKeyCity];
        _stateProvinceCode = [aDecoder decodeObjectForKey:kKeyStateProvinceCode];
        _countryCode = [aDecoder decodeObjectForKey:kKeyCountryCode];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_firstName forKey:kKeyFirstName];
    [aCoder encodeObject:_lastName forKey:kKeyLastName];
    [aCoder encodeObject:_email forKey:kKeyEmail];
    [aCoder encodeObject:_phoneNumber forKey:kKeyPhoneNumber];
    [aCoder encodeObject:_address1 forKey:kKeyAddress1];
    [aCoder encodeObject:_city forKey:kKeyCity];
    [aCoder encodeObject:_stateProvinceCode forKey:kKeyStateProvinceCode];
    [aCoder encodeObject:_countryCode forKey:kKeyCountryCode];
}

#pragma mark Setters

- (void)setFirstName:(NSString *)firstName {
    _firstName = [firstName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self save];
}

- (void)setLastName:(NSString *)lastName {
    _lastName = [lastName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self save];
}

- (void)setEmail:(NSString *)email {
    _email = [email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self save];
}

- (void)setPhoneNumber:(NSString *)phoneNumber {
    _phoneNumber = [phoneNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self save];
}

- (void)setAddress1:(NSString *)address1 {
    _address1 = [address1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self save];
}

- (void)setCity:(NSString *)city {
    _city = [city stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self save];
}

- (void)setStateProvinceCode:(NSString *)stateProvinceCode {
    _stateProvinceCode = [stateProvinceCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self save];
}

- (void)setCountryCode:(NSString *)countryCode {
    _countryCode = [countryCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self save];
}

@end
