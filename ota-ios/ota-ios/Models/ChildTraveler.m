//
//  ChildTraveler.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/29/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "ChildTraveler.h"

@implementation ChildTraveler

@synthesize childAge = _childAge;

+ (ChildTraveler *)newChildWithAge:(NSUInteger)age {
    ChildTraveler *child = [[ChildTraveler alloc] init];
    child.childAge = age;
    return child;
}

- (NSUInteger)getChildsAge {
    if (self.isLessThanOne) {
        return 0;
    }
    
    return _childAge;
}

- (void)setChildsAge:(NSUInteger)childAge {
    _ageHasBeenSet = YES;
    _childAge = childAge;
}

@end
