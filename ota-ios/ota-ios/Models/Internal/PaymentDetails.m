//
//  PaymentDetails.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/21/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "PaymentDetails.h"
#import "JNKeychain.h"
#import "AppEnvironment.h"

static PaymentDetails *_card1 = nil;

@implementation PaymentDetails

#pragma mark Setters

- (id)init {
    if (self = [super init]) {
        _billingAddress = [EanPlace new];
    }
    return self;
}

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
