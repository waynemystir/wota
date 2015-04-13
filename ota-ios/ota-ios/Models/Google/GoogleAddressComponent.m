//
//  GoogleAddressComponent.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/12/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "GoogleAddressComponent.h"

@implementation GoogleAddressComponent

+ (GoogleAddressComponent *)addCompFromDict:(NSDictionary *)dict {
    if (nil == dict) {
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    GoogleAddressComponent *gac = [[GoogleAddressComponent alloc] init];
    gac.longName = [dict objectForKey:@"long_name"];
    gac.shortName = [dict objectForKey:@"short_name"];
    gac.types = [dict objectForKey:@"types"];
    return gac;
}

@end
