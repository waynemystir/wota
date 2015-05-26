//
//  EanPaymentTypeResponse.m
//  ota-ios
//
//  Created by WAYNE SMALL on 5/25/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanPaymentTypeResponse.h"
#import "EanPaymentType.h"

@implementation EanPaymentTypeResponse

+ (instancetype)eanObjectFromApiJsonResponse:(id)jsonResponse {
    if (jsonResponse == nil) {
        return nil;
    }
    
    if (![jsonResponse isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    id idHpr = [jsonResponse objectForKey:@"HotelPaymentResponse"];
    
    if (nil == idHpr) {
        return nil;
    }
    
    if (![idHpr isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanPaymentTypeResponse *ptr = [[EanPaymentTypeResponse alloc] init];
    ptr.size = [idHpr objectForKey:@"@size"];
    ptr.currencyCode = [idHpr objectForKey:@"@currencyCode"];
    ptr.customerSessionId = [idHpr objectForKey:@"customerSessionId"];
    
    id idPaymentTypes = [idHpr objectForKey:@"PaymentType"];
    NSMutableArray *mutPayTypesArray = [NSMutableArray array];
    
    if (nil == idPaymentTypes) {
        ;
    } else if ([idPaymentTypes isKindOfClass:[NSDictionary class]]) {
        EanPaymentType *pt = [EanPaymentType paymentTypeFromDict:idPaymentTypes];
        [mutPayTypesArray addObject:pt];
    } else if ([idPaymentTypes isKindOfClass:[NSArray class]]) {
        for (int j = 0; j < [idPaymentTypes count]; j++) {
            EanPaymentType *pt = [EanPaymentType paymentTypeFromDict:idPaymentTypes[j]];
            [mutPayTypesArray addObject:pt];
        }
    }
    
    ptr.paymentTypes = [NSArray arrayWithArray:mutPayTypesArray];
    
    return ptr;
}

- (NSString *)paymentTypesBulletted {
    NSString *ptb = @"";
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"WotaMoneyKit.bundle/CardPatterns" ofType:@"plist"];
    NSArray *array = [NSArray arrayWithContentsOfFile:filePath];
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    for (NSDictionary *d in array) {
        NSString *eanType = [d objectForKey:@"eantype"];
        NSString *companyName = [d objectForKey:@"companyName"];
        [md setValue:companyName forKey:eanType];
    }
    
    for (EanPaymentType *pt in _paymentTypes) {
        ptb = [ptb stringByAppendingFormat:@"\n● %@", [md objectForKey:pt.ptCode]];
    }
    return ptb;
}

@end
