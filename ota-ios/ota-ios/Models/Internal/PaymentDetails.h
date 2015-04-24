//
//  PaymentDetails.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/21/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EanPlace.h"

@interface PaymentDetails : NSObject <NSCoding>

@property (nonatomic, strong) NSString *cardNumber;
@property (nonatomic, strong) EanPlace *billingAddress;
@property (nonatomic, strong) NSString *expirationMonth;
@property (nonatomic, strong) NSString *expirationYear;
@property (nonatomic, strong) NSString *cardHolderFirstName;
@property (nonatomic, strong) NSString *cardHolderLastName;

+ (PaymentDetails *)card1;

+ (void)deleteCard:(PaymentDetails *)card;

@end
