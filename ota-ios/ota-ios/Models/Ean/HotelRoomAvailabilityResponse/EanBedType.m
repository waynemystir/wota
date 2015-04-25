//
//  EanBedType.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/24/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanBedType.h"

@implementation EanBedType

+ (EanBedType *)bedTypeFromDict:(NSDictionary *)dict {
    if (nil == dict) {
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanBedType *bedType = [[EanBedType alloc] init];
    bedType.bedTypeId = [dict objectForKey:@"@id"];
    NSString *btd = [dict objectForKey:@"description"];
    bedType.bedTypeDescription = [btd capitalizedStringWithLocale:nil];
    return bedType;
}

@end
