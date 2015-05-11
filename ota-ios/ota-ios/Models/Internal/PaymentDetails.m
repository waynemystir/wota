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

static PaymentDetails *_card1 = nil;

NSString * const kKeyDaNumber = @"AcBrCeDdEiFtGcHaIrJdKnLuMmNbOePr";
NSString * const kKeyEanCardType = @"eanType";
NSString * const kKeyBillingAddress = @"billingAddress";
NSString * const kKeyExpirMonth = @"expirationMonth";
NSString * const kKeyExpirYear = @"expirationYear";
NSString * const kKeyCardHolderFirstName = @"cardHolderFirstName";
NSString * const kKeyCardHolderLastName = @"cardHolderLastName";

@implementation PaymentDetails

+ (PaymentDetails *)card1 {
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

+ (void)deleteCard:(PaymentDetails *)card {
    if (card == _card1) {
        _card1 = nil;
        if (![JNKeychain deleteValueForKey:kKeyPaymentDetails1]) {
            NSLog(@"ERROR: There was a problem deleting payment details");
        }
    }
}

#pragma mark NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _cardNumber = [aDecoder decodeObjectForKey:kKeyDaNumber];
        _eanCardType = [aDecoder decodeObjectForKey:kKeyEanCardType];
        _billingAddress = [aDecoder decodeObjectForKey:kKeyBillingAddress];
        _expirationMonth = [aDecoder decodeObjectForKey:kKeyExpirMonth];
        _expirationYear = [aDecoder decodeObjectForKey:kKeyExpirYear];
        _cardHolderFirstName = [aDecoder decodeObjectForKey:kKeyCardHolderFirstName];
        _cardHolderLastName = [aDecoder decodeObjectForKey:kKeyCardHolderLastName];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_cardNumber forKey:kKeyDaNumber];
    [aCoder encodeObject:_eanCardType forKey:kKeyEanCardType];
    [aCoder encodeObject:_billingAddress forKey:kKeyBillingAddress];
    [aCoder encodeObject:_expirationMonth forKey:kKeyExpirMonth];
    [aCoder encodeObject:_expirationYear forKey:kKeyExpirYear];
    [aCoder encodeObject:_cardHolderFirstName forKey:kKeyCardHolderFirstName];
    [aCoder encodeObject:_cardHolderLastName forKey:kKeyCardHolderLastName];
}

#pragma mark Setters

- (void)setCardNumber:(NSString *)cardNumber {
    _cardNumber = cardNumber;
    [self save];
}

- (void)setEanCardType:(NSString *)eanCardType {
    _eanCardType = eanCardType;
    [self save];
}

- (void)setBillingAddress:(EanPlace *)billingAddress {
    _billingAddress = billingAddress;
    [self save];
}

- (void)setExpirationMonth:(NSString *)expirationMonth {
    _expirationMonth = expirationMonth;
    [self save];
}

- (void)setExpirationYear:(NSString *)expirationYear {
    _expirationYear = expirationYear;
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

#pragma mark Getter for readonly

- (NSString *)lastFour {
    return [_cardNumber substringFromIndex:MAX((int)[_cardNumber length]-4, 0)];
}

@end
