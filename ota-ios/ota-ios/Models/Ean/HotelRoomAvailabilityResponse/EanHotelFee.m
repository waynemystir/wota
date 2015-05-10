//
//  EanHotelFee.m
//  ota-ios
//
//  Created by WAYNE SMALL on 5/9/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanHotelFee.h"

@implementation EanHotelFee

+ (EanHotelFee *)hotelFeeFromDict:(NSDictionary *)dict {
    if (nil == dict) {
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanHotelFee *hf = [[EanHotelFee alloc] init];
    hf.hfDescription = [dict objectForKey:@"@description"];
    hf.amount = [dict objectForKey:@"@amount"];
    return hf;
}

@end
