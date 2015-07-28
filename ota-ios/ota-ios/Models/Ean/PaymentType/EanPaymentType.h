//
//  EanPaymentType.h
//  ota-ios
//
//  Created by WAYNE SMALL on 5/25/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EanPaymentType : NSObject

@property (nonatomic, strong) NSString *ptCode;
@property (nonatomic, strong) NSString *ptName;

+ (EanPaymentType *)paymentTypeFromDict:(NSDictionary *)dict;

@end
