//
//  EanPaymentTypeResponse.h
//  ota-ios
//
//  Created by WAYNE SMALL on 5/25/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanAbstractResponse.h"

@interface EanPaymentTypeResponse : EanAbstractResponse

@property (nonatomic, strong) id size;
@property (nonatomic, strong) NSString *currencyCode;
@property (nonatomic, strong) NSString *customerSessionId;
@property (nonatomic, strong) NSArray *paymentTypes;
@property (nonatomic, strong, readonly) NSString *paymentTypesBulletted;

@end
