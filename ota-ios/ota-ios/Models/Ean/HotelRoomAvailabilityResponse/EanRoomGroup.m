//
//  EanRoomGroup.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/26/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanRoomGroup.h"

@implementation EanRoomGroup

+ (EanRoomGroup *)roomGroupFromDict:(NSDictionary *)dict {
    if (nil == dict) {
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    id room = [dict objectForKey:@"Room"];
    
    if (nil == room || ![room isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanRoomGroup *rg = [[EanRoomGroup alloc] init];
    rg.numberOfAdults = [[room objectForKey:@"numberOfAdults"] integerValue];
    rg.numberOfChildren = [[room objectForKey:@"numberOfChildren"] integerValue];
    rg.rateKey = [room objectForKey:@"rateKey"];
    return rg;
}

@end
