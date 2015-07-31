//
//  BackCancelViewSmaller.h
//  ota-ios
//
//  Created by WAYNE SMALL on 7/30/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BackCancelViewSmaller : UIView

- (void)animateToCancel:(NSTimeInterval)animationDuration;
- (void)animateToBack:(NSTimeInterval)animationDuration;
- (void)grayIt;
- (void)blueIt;

@end
