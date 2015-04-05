//
//  GooglePlace.h
//  ota-ios
//
//  Created by WAYNE SMALL on 3/24/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GooglePlace : NSObject

@property (nonatomic, strong) NSString *placeName;
@property (nonatomic, strong) NSString *placeId;

+ (GooglePlace *)placeFromObject:(id)object;

@end