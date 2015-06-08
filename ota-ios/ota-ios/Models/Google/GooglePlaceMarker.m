//
//  GooglePlaceMarker.m
//  ota-ios
//
//  Created by WAYNE SMALL on 6/7/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "GooglePlaceMarker.h"
#import <SDWebImage/SDWebImageManager.h>

@implementation GooglePlaceMarker

- (id)initWithPlace:(GoogleNearbyPlace *)place {
    if (self = [super init]) {
        _place = place;
        self.position = CLLocationCoordinate2DMake(place.latitude, place.longitude);
        __weak typeof(self) weakSelf = self;
        
        [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:place.iconUrl] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            ;
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
            UIImage *ni = [[self class] imageWithImage:image scaledToSize:CGSizeMake(16, 16)];
            weakSelf.icon = ni;
        }];
        
        self.groundAnchor = CGPointMake(0.5f, 1);
        self.appearAnimation = kGMSMarkerAnimationPop;
    }
    return self;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
