//
//  EanHotelFee.h
//  ota-ios
//
//  Created by WAYNE SMALL on 5/9/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EanHotelFee : NSObject

@property (nonatomic, strong) NSString *hfDescription;
@property (nonatomic, strong) NSNumber *amount;

+ (EanHotelFee *)hotelFeeFromDict:(NSDictionary *)dict;

@end
