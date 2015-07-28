//
//  EanAvailabilityRoomType.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/25/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EanAvailabilityRoomType : NSObject

@property (nonatomic, strong) NSString *roomTypeId;
@property (nonatomic, strong) NSString *roomCode;
@property (nonatomic, strong) NSString *roomTypeDescrition;
@property (nonatomic, strong) NSString *descriptionLong;
@property (nonatomic, strong, readonly) NSString *descriptionLongStripped;

+ (EanAvailabilityRoomType *)roomTypeFromDict:(NSDictionary *)dict;

@end
