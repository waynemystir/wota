//
//  EanRoomGroup.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/26/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EanRoomGroup : NSObject

@property (nonatomic) NSUInteger numberOfAdults;
@property (nonatomic) NSUInteger numberOfChildren;
@property (nonatomic, strong) NSString *rateKey;

+ (EanRoomGroup *)roomGroupFromDict:(NSDictionary *)dict;

@end
