//
//  BackCancelViewSmaller.m
//  ota-ios
//
//  Created by WAYNE SMALL on 7/30/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "BackCancelViewSmaller.h"
#import "BackCancelView.h"

NSUInteger const bcvTag = 123456;

@implementation BackCancelViewSmaller

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = NO;
        BackCancelView *bcv = [[BackCancelView alloc] initWithFrame:CGRectMake(0, 0, 28, 36)];
        bcv.tag = bcvTag;
        bcv.transform = CGAffineTransformMakeScale(0.7f, 0.7f);
        bcv.frame = CGRectMake((frame.size.width - 19.6)/2, (frame.size.height - 25.2)/2, 19.6, 25.2);
        [self addSubview:bcv];
    }
    return self;
}

- (void)animateToCancel:(NSTimeInterval)animationDuration {
    BackCancelView *bcv = (BackCancelView *) [self viewWithTag:bcvTag];
    [bcv animateToCancel:animationDuration];
}

- (void)animateToBack:(NSTimeInterval)animationDuration {
    BackCancelView *bcv = (BackCancelView *) [self viewWithTag:bcvTag];
    [bcv animateToBack:animationDuration];
}

- (void)grayIt {
    BackCancelView *bcv = (BackCancelView *) [self viewWithTag:bcvTag];
    [bcv grayIt];
}

- (void)blueIt {
    BackCancelView *bcv = (BackCancelView *) [self viewWithTag:bcvTag];
    [bcv blueIt];
}

@end
