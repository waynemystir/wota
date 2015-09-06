//
//  PaymentDetails.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/21/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EanPlace.h"

@interface PaymentDetails : NSObject

@property (nonatomic, strong) NSString *cardNumber;
@property (nonatomic, strong, readonly) NSString *lastFour;
@property (nonatomic, strong) NSString *eanCardType;
@property (nonatomic, strong) UIImage *cardImage;
@property (nonatomic, strong) EanPlace *billingAddress;
@property (nonatomic, strong) NSString *expirationMonth;
@property (nonatomic, strong) NSString *expirationYear;
@property (nonatomic, strong) NSString *cardHolderFirstName;
@property (nonatomic, strong) NSString *cardHolderLastName;

@end
