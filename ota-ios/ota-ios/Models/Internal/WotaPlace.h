//
//  WotaPlace.h
//  ota-ios
//
//  Created by WAYNE SMALL on 6/19/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WotaPlace : NSObject <NSCoding>

@property (nonatomic, strong) NSString *placeName;
@property (nonatomic, strong) NSString *placeId;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@property (nonatomic, strong, readonly) NSString *formattedWhereTo;
@property (nonatomic, strong, readonly) NSString *formattedWhereToFirst;
@property (nonatomic, strong, readonly) NSString *formattedWhereToSecond;

@end