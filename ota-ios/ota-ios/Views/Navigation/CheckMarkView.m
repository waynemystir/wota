//
//  CheckMarkView.m
//  ota-ios
//
//  Created by WAYNE SMALL on 5/15/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "CheckMarkView.h"

#define degreesToRadians(x) (M_PI * x / 180.0)

CGFloat const barAngle = -63.0f;
CGFloat const barScale = 1.16f;

@interface CheckMarkView () {
    UIView *upBar;
    UIView *downBar;
}

@end

@implementation CheckMarkView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = NO;
        upBar = [[UIView alloc] initWithFrame:CGRectMake(1, 1, frame.size.width - 2, 5)];
        upBar.backgroundColor = self.tintColor;
        [self addSubview:upBar];
        
        downBar = [[UIView alloc] initWithFrame:CGRectMake(1, frame.size.height - 6, 15, 5)];
        downBar.backgroundColor = self.tintColor;
        [self addSubview:downBar];
        
        upBar.layer.cornerRadius = 3.0f;
        downBar.layer.cornerRadius = 3.0f;
        
        CGPoint rotationPoint = CGPointMake(upBar.frame.size.width, upBar.frame.origin.y + upBar.frame.size.height/2);
        
        CGFloat minX   = CGRectGetMinX(upBar.frame);
        CGFloat minY   = CGRectGetMinY(upBar.frame);
        CGFloat width  = CGRectGetWidth(upBar.frame);
        CGFloat height = CGRectGetHeight(upBar.frame);
        
        CGPoint anchorPoint =  CGPointMake((rotationPoint.x-minX)/width,
                                           (rotationPoint.y-minY)/height);
        
        upBar.layer.anchorPoint = anchorPoint;
        upBar.layer.position = rotationPoint;
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(degreesToRadians(barAngle));
        transform = CGAffineTransformScale(transform, barScale, 1.0f);
        upBar.transform = transform;
        
        CGPoint dRotationPoint = CGPointMake(downBar.frame.size.width, downBar.frame.origin.y +downBar.frame.size.height/2);
        CGFloat dMinX = CGRectGetMinX(downBar.frame);
        CGFloat dMinY = CGRectGetMinY(downBar.frame);
        CGFloat dWidth = CGRectGetWidth(downBar.frame);
        CGFloat dHeight = CGRectGetHeight(downBar.frame);
        
        CGPoint dAnchorPoint = CGPointMake((dRotationPoint.x - dMinX)/dWidth,
                                           (dRotationPoint.y - dMinY)/dHeight);
        
        downBar.layer.anchorPoint = dAnchorPoint;
        downBar.layer.position = dRotationPoint;
        
        CGAffineTransform dTransform = CGAffineTransformMakeRotation(degreesToRadians(-barAngle));
        dTransform = CGAffineTransformScale(dTransform, barScale, 1.0f);
        downBar.transform = dTransform;
    }
    return self;
}

- (void)grayIt {
    upBar.backgroundColor = [UIColor grayColor];
    downBar.backgroundColor = [UIColor grayColor];
}

- (void)blueIt {
    upBar.backgroundColor = self.tintColor;
    downBar.backgroundColor = self.tintColor;
}

@end
