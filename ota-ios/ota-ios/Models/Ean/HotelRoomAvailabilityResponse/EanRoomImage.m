//
//  EanRoomImage.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/26/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "EanRoomImage.h"
#import <SDWebImage/SDWebImageManager.h>

@implementation EanRoomImage

+ (EanRoomImage *)roomImageFromDict:(NSDictionary *)dict {
    if (nil == dict) {
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanRoomImage *ri = [[EanRoomImage alloc] init];
    ri.imageUrl = [dict objectForKey:@"url"];
    
    [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:ri.imageUrl]
                                               options:0
                                              progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                  ;
                                              }
                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                                 ;
                                             }];
    
    return ri;
}

@end
