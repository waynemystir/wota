//
//  EanSurcharge.m
//  ota-ios
//
//  Created by WAYNE SMALL on 5/1/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "EanSurcharge.h"

@implementation EanSurcharge

+ (EanSurcharge *)surchargeFromDict:(NSDictionary *)dict {
    if (nil == dict) {
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanSurcharge *sc = [[EanSurcharge alloc] init];
    sc.amount = [NSNumber numberWithDouble:[[dict objectForKey:@"@amount"] doubleValue]];
    sc.typeEanString = [dict objectForKey:@"@type"];
    
    if ([sc.typeEanString isEqualToString:@"TaxAndServiceFee"]) {
        sc.surchargeType = TaxAndServiceFee;
    } else if ([sc.typeEanString isEqualToString:@"ExtraPersonFee"]) {
        sc.surchargeType = ExtraPersonFee;
    } else if ([sc.typeEanString isEqualToString:@"Tax"]) {
        sc.surchargeType = Tax;
    } else if ([sc.typeEanString isEqualToString:@"ServiceFee"]) {
        sc.surchargeType = ServiceFee;
    } else if ([sc.typeEanString isEqualToString:@"SalesTax"]) {
        sc.surchargeType = SalesTax;
    } else if ([sc.typeEanString isEqualToString:@"HotelOccupancyTax"]) {
        sc.surchargeType = HotelOccupancyTax;
    } else {
        sc.surchargeType = Other;
    }
    
    return sc;
}

@end
