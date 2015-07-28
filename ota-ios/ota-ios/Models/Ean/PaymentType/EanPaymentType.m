//
//  EanPaymentType.m
//  ota-ios
//
//  Created by WAYNE SMALL on 5/25/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "EanPaymentType.h"

@implementation EanPaymentType

+ (EanPaymentType *)paymentTypeFromDict:(NSDictionary *)dict {
    if (nil == dict) {
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanPaymentType *pt = [[EanPaymentType alloc] init];
    pt.ptCode = [dict objectForKey:@"code"];
    pt.ptName = [dict objectForKey:@"name"];
    return pt;
}

@end
