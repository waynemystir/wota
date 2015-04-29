//
//  GuestInfo.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/11/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "GuestInfo.h"
#import "JNKeychain.h"
#import "AppEnvironment.h"

NSString * const kKeyFirstName = @"first_name";
NSString * const kKeyLastName = @"last_name";
NSString * const kKeyEmail = @"email_address";
NSString * const kKeyPhoneNumber = @"phone_number";

@implementation GuestInfo

+ (GuestInfo *)singleton {
    static GuestInfo *_guestInfo = nil;
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

#pragma mark NSCoding delegate methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _firstName = [aDecoder decodeObjectForKey:kKeyFirstName];
        _lastName = [aDecoder decodeObjectForKey:kKeyLastName];
        _email = [aDecoder decodeObjectForKey:kKeyEmail];
        _phoneNumber = [aDecoder decodeObjectForKey:kKeyPhoneNumber];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_firstName forKey:kKeyFirstName];
    [aCoder encodeObject:_lastName forKey:kKeyLastName];
    [aCoder encodeObject:_email forKey:kKeyEmail];
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

- (void)setPhoneNumber:(NSString *)phoneNumber {
    _phoneNumber = [phoneNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self save];
}

@end