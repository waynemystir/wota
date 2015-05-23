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

NSUInteger const MAX_CARDHOLDER_FIRST_NAME_LENGTH = 25;

static PaymentDetails *_card1 = nil;

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

+ (void)deleteCard:(PaymentDetails *)card {
    if (card == _card1) {
        _card1 = nil;
        if (![JNKeychain deleteValueForKey:kKeyPaymentDetails1]) {
            NSLog(@"ERROR: There was a problem deleting payment details");
        }
    }
}

#pragma mark Setters

- (void)setCardHolderFirstName:(NSString *)cardHolderFirstName {
    _cardHolderFirstName = [cardHolderFirstName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)setCardHolderLastName:(NSString *)cardHolderLastName {
    _cardHolderLastName = [cardHolderLastName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#pragma mark Getter for readonly

- (NSString *)lastFour {
    return [_cardNumber substringFromIndex:MAX((int)[_cardNumber length]-4, 0)];
}

@end
