//
//  EanBedType.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/24/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EanBedType : NSObject

@property (nonatomic, strong) NSString *bedTypeId;
@property (nonatomic, strong) NSString *bedTypeDescription;

+ (EanBedType *)bedTypeFromDict:(NSDictionary *)dict;

@end
