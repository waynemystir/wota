//
//  PaymentDetails.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/21/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "PaymentDetails.h"
#import "JNKeychain.h"
#import "AppEnvironment.h"

NSString * const kKeyDaNumber = @"AcBrCeDdEiFtGcHaIrJdKnLuMmNbOePr";
NSString * const kKeyBillingAddress = @"billingAddress";
NSString * const kKeyCardHolderFirstName = @"cardHolderFirstName";
NSString * const kKeyCardHolderLastName = @"cardHolderLastName";

@implementation PaymentDetails

+ (PaymentDetails *)card1 {
    static PaymentDetails *_card1 = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _card1 = [JNKeychain loadValueForKey:kKeyPaymentDetails1];
    });
    
    if (nil == _card1) {
        _card1 = [[PaymentDetails alloc] init];
    }
    
    return _card1;
}

- (void)save {
    if (![JNKeychain saveValue:self forKey:kKeyPaymentDetails1]) {
        NSLog(@"ERROR: There was a problem saving payment details");
    }
}

#pragma mark NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _cardNumber = [aDecoder decodeObjectForKey:kKeyDaNumber];
        _billingAddress = [aDecoder decodeObjectForKey:kKeyBillingAddress];
        _cardHolderFirstName = [aDecoder decodeObjectForKey:kKeyCardHolderFirstName];
        _cardHolderLastName = [aDecoder decodeObjectForKey:kKeyCardHolderLastName];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_cardNumber forKey:kKeyDaNumber];
    [aCoder encodeObject:_billingAddress forKey:kKeyBillingAddress];
    [aCoder encodeObject:_cardHolderFirstName forKey:kKeyCardHolderFirstName];
    [aCoder encodeObject:_cardHolderLastName forKey:kKeyCardHolderLastName];
}

#pragma mark Setters

- (void)setCardNumber:(NSString *)cardNumber {
    _cardNumber = cardNumber;
    [self save];
}

- (void)setBillingAddress:(EanPlace *)billingAddress {
    _billingAddress = billingAddress;
    [self save];
}

- (void)setCardHolderFirstName:(NSString *)cardHolderFirstName {
    _cardHolderFirstName = [cardHolderFirstName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self save];
}

- (void)setCardHolderLastName:(NSString *)cardHolderLastName {
    _cardHolderLastName = [cardHolderLastName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self save];
}

@end
