//
//  EanRoomImage.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/26/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanRoomImage.h"

@implementation EanRoomImage

+ (EanRoomImage *)roomImageFromDict:(NSDictionary *)dict {
    if (nil == dict) {
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanRoomImage *ri = [[EanRoomImage alloc] init];
    ri.imageUrl = [dict objectForKey:@"url"];
    return ri;
}

@end
