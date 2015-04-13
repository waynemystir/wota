//
//  GooglePlaces.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/12/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GooglePlaces : NSObject

@property (nonatomic, strong, getter=getPlacesArray) NSMutableArray *placesArray;

+ (GooglePlaces *)placesFromData:(NSData *)data;

@end
