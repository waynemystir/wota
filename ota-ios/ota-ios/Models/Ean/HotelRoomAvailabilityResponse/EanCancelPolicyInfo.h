//
//  EanCancelPolicyInfo.h
//  ota-ios
//
//  Created by WAYNE SMALL on 5/2/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EanCancelPolicyInfo : NSObject

@property (nonatomic) NSInteger versionId;
@property (nonatomic, strong) NSString *cancelTime;
@property (nonatomic) NSInteger startWindowHours;
@property (nonatomic) NSInteger nightCount;
@property (nonatomic, strong) id percent;
@property (nonatomic, strong) id amount;
@property (nonatomic, strong) NSString *currencyCode;
@property (nonatomic, strong) NSString *timeZoneDescription;

+ (EanCancelPolicyInfo *)cancelPolicyFromDict:(NSDictionary *)dict;

@end
