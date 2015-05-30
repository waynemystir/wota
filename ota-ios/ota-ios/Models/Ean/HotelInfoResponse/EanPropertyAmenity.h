//
//  EanPropertyAmenity.h
//  ota-ios
//
//  Created by WAYNE SMALL on 5/22/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EanPropertyAmenity : NSObject

@property (nonatomic) NSUInteger amenityId;
@property (nonatomic, strong, readonly) NSString *amenityName;

+ (EanPropertyAmenity *)amenityFromDict:(NSDictionary *) dict;

@end
