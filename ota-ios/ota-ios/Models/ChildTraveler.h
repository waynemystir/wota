//
//  ChildTraveler.h
//  ota-ios
//
//  Created by WAYNE SMALL on 3/29/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChildTraveler : NSObject

@property (nonatomic) BOOL ageHasBeenSet;
@property (nonatomic) BOOL isLessThanOne;
@property (nonatomic, getter=getChildsAge, setter=setChildsAge:) NSUInteger childAge;

+ (ChildTraveler * )newChildWithAge:(NSUInteger)age;

@end
