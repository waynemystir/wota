//
//  GoogleAddressComponent.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/12/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoogleAddressComponent : NSObject

@property (nonatomic, strong) NSString *longName;
@property (nonatomic, strong) NSString *shortName;
@property (nonatomic, strong) NSArray *types;

+ (GoogleAddressComponent *)addCompFromDict:(NSDictionary *)dict;

@end
