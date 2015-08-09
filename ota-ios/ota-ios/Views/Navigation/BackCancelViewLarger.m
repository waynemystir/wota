//
//  BackCancelViewLarger.m
//  ota-ios
//
//  Created by WAYNE SMALL on 8/8/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "BackCancelViewLarger.h"
#import "BackCancelView.h"

NSUInteger const bcvBigTag = 9876543;

@implementation BackCancelViewLarger

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = NO;
        BackCancelView *bcv = [[BackCancelView alloc] initWithFrame:CGRectMake(0, 0, 28, 36)];
        bcv.tag = bcvBigTag;
        bcv.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
        bcv.frame = CGRectMake((frame.size.width - 36.4)/2, (frame.size.height - 46.8)/2, 36.4, 46.8);
        [self addSubview:bcv];
    }
    return self;
}

- (void)animateToCancel:(NSTimeInterval)animationDuration {
    BackCancelView *bcv = (BackCancelView *) [self viewWithTag:bcvBigTag];
    [bcv animateToCancel:animationDuration];
}

- (void)animateToBack:(NSTimeInterval)animationDuration {
    BackCancelView *bcv = (BackCancelView *) [self viewWithTag:bcvBigTag];
    [bcv animateToBack:animationDuration];
}

- (void)grayIt {
    BackCancelView *bcv = (BackCancelView *) [self viewWithTag:bcvBigTag];
    [bcv grayIt];
}

- (void)blueIt {
    BackCancelView *bcv = (BackCancelView *) [self viewWithTag:bcvBigTag];
    [bcv blueIt];
}

@end
