//
//  BackCancelView.h
//  ota-ios
//
//  Created by WAYNE SMALL on 5/14/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BackCancelView : UIView

- (void)animateToCancel:(NSTimeInterval)animationDuration;
- (void)animateToBack:(NSTimeInterval)animationDuration;
- (void)grayIt;
- (void)blueIt;

@end
