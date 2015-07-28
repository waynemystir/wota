//
//  EanNightlyRate.h
//  ota-ios
//
//  Created by WAYNE SMALL on 5/1/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EanNightlyRate : NSObject

@property (nonatomic) BOOL promo;
@property (nonatomic, strong) NSNumber *rate;
@property (nonatomic, strong) NSNumber *baseRate;
@property (nonatomic, strong) NSDate *daDate;

+ (EanNightlyRate *)nightRateFromDict:(NSDictionary *)dict;

@end
