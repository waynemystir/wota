//
//  EanAvailabilityRoomType.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/25/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "EanAvailabilityRoomType.h"
#import "AppEnvironment.h"

@implementation EanAvailabilityRoomType

+ (EanAvailabilityRoomType *)roomTypeFromDict:(NSDictionary *)dict {
    if (nil == dict) {
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanAvailabilityRoomType *rt = [[EanAvailabilityRoomType alloc] init];
    
    rt.roomTypeId = [dict objectForKey:@"@roomTypeId"];
    rt.roomCode = [dict objectForKey:@"@roomCode"];
    rt.roomTypeDescrition = [dict objectForKey:@"description"];
    rt.descriptionLong = [dict objectForKey:@"descriptionLong"];
    
    return rt;
}

- (NSString *)descriptionLongStripped {
    return stringByStrippingHTML(self.descriptionLong);
}

@end
