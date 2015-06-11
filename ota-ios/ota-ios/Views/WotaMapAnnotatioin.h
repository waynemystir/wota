//
//  WotaMapAnnotatioin.h
//  ota-ios
//
//  Created by WAYNE SMALL on 6/10/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface WotaMapAnnotatioin : MKPointAnnotation

@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic) NSUInteger rowNUmber;

@end
