//
//  GuestInfo.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/11/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "GuestInfo.h"
#import "JNKeychain.h"
#import "AppEnvironment.h"

NSUInteger const MAX_FIRST_NAME_LENGTH = 25;
NSUInteger const MAX_LAST_NAME_LENGTH = 40;
NSUInteger const MAX_EMAIL_LENGTH = 50;

static GuestInfo *_guestInfo = nil;

NSString * const kKeyFirstName = @"first_name";
NSString * const kKeyLastName = @"last_name";
NSString * const kKeyEmail = @"email_address";
NSString * const kKeyInternationalCallingCode = @"international_calling_code";
NSString * const kKeyIntCountryCode = @"countryCode";
NSString * const kKeyPhoneNumber = @"phone_number";

@implementation GuestInfo

+ (GuestInfo *)singleton {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _guestInfo = [JNKeychain loadValueForKey:kKeyGuestInfo];
    });
    
    if (nil == _guestInfo) {
        _guestInfo = [[self alloc] init];
    }
    
    return _guestInfo;
}

- (void)save {
    if (![JNKeychain saveValue:self forKey:kKeyGuestInfo]) {
        NSLog(@"ERROR: There was a problem saving GuestInfo");
    }
}

+ (void)deleteGuest:(GuestInfo *)guest {
    if (guest == _guestInfo) {
        _guestInfo = nil;
        if (![JNKeychain deleteValueForKey:kKeyGuestInfo]) {
            NSLog(@"ERROR: There was a problem deleting guest info");
        }
    }
}

- (NSString *)apiValue:(NSString *)string maxChar:(int)maxChar {
    NSString *rs = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (stringIsEmpty(rs)) return nil;
    return [rs substringToIndex:MIN(rs.length, maxChar)];
}

#pragma mark NSCoding delegate methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _firstName = [aDecoder decodeObjectForKey:kKeyFirstName];
        _lastName = [aDecoder decodeObjectForKey:kKeyLastName];
        _email = [aDecoder decodeObjectForKey:kKeyEmail];
        _internationalCallingCode = [aDecoder decodeObjectForKey:kKeyInternationalCallingCode];
        _countryCode = [aDecoder decodeObjectForKey:kKeyIntCountryCode];
        _phoneNumber = [aDecoder decodeObjectForKey:kKeyPhoneNumber];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_firstName forKey:kKeyFirstName];
    [aCoder encodeObject:_lastName forKey:kKeyLastName];
    [aCoder encodeObject:_email forKey:kKeyEmail];
    [aCoder encodeObject:_internationalCallingCode forKey:kKeyInternationalCallingCode];
    [aCoder encodeObject:_countryCode forKey:kKeyIntCountryCode];
    [aCoder encodeObject:_phoneNumber forKey:kKeyPhoneNumber];
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

- (void)setInternationalCallingCode:(NSString *)internationalCallingCode {
    _internationalCallingCode = internationalCallingCode;
    [self save];
}

- (void)setCountryCode:(NSString *)countryCode {
    _countryCode = countryCode;
    [self save];
}

- (void)setPhoneNumber:(NSString *)phoneNumber {
    _phoneNumber = [phoneNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self save];
}

#pragma mark API Getters

- (NSString *)apiFirstName {
    return [self apiValue:_firstName maxChar:MAX_FIRST_NAME_LENGTH];
}

- (NSString *)apiLastName {
    return [self apiValue:_lastName maxChar:MAX_LAST_NAME_LENGTH];
}

- (NSString *)apiEmail {
    return [self apiValue:_email maxChar:MAX_EMAIL_LENGTH];
}

- (NSString *)apiPhoneNumber {
    NSString *ic = stringIsEmpty(_internationalCallingCode) ? @"" : [NSString stringWithFormat:@"+%@-", _internationalCallingCode];
    return [NSString stringWithFormat:@"%@%@", ic, _phoneNumber];
}

@end
