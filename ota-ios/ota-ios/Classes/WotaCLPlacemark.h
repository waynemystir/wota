//
//  WotaCLPlacemark.h
//  ota-ios
//
//  Created by WAYNE SMALL on 6/14/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface WotaCLPlacemark : CLPlacemark

@property (nonatomic, strong, readonly) NSString *formattedWhereTo;

@end
