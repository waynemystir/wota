//
//  EanRoomImage.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/26/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EanRoomImage : NSObject

@property (nonatomic, strong) NSString *imageUrl;

+ (EanRoomImage *)roomImageFromDict:(NSDictionary *)dict;

@end
