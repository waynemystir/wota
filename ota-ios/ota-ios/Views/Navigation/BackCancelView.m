//
//  BackCancelView.m
//  ota-ios
//
//  Created by WAYNE SMALL on 5/14/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "BackCancelView.h"

#define degreesToRadians(x) (M_PI * x / 180.0)

CGFloat const startAngle = -24.8f;
CGFloat const endAngle = -48.4f;
CGFloat const startScale = 1.13f;
CGFloat const endScale = 1.626f;

@interface BackCancelView () {
    UIView *upBar;
    UIView *upBar2;
    UIView *downBar;
    UIView *downBar2;
}

@end

@implementation BackCancelView

+ (NSString *)mediaTimingFunction {
    return kCAMediaTimingFunctionEaseInEaseOut;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = NO;
        
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.shouldRasterize = YES;
        
        upBar = [[UIView alloc] initWithFrame:CGRectMake(1, 7, frame.size.width - 2, 5)];
        upBar.backgroundColor = self.tintColor;
        [self addSubview:upBar];
        upBar2 = [[UIView alloc] initWithFrame:CGRectMake(1, 7, frame.size.width - 2, 5)];
        upBar2.backgroundColor = self.tintColor;
        [self addSubview:upBar2];
        
        downBar = [[UIView alloc] initWithFrame:CGRectMake(1, frame.size.height - 12, frame.size.width - 2, 5)];
        downBar.backgroundColor = self.tintColor;
        [self addSubview:downBar];
        downBar2 = [[UIView alloc] initWithFrame:CGRectMake(1, frame.size.height - 12, frame.size.width - 2, 5)];
        downBar2.backgroundColor = self.tintColor;
        [self addSubview:downBar2];
        
        upBar2.layer.cornerRadius = upBar.layer.cornerRadius = downBar2.layer.cornerRadius = downBar.layer.cornerRadius = 3.0f;
        
        CGPoint rotationPoint = CGPointMake(upBar.frame.size.width *.8, upBar.frame.origin.y + upBar.frame.size.height/2);
        
        CGFloat minX   = CGRectGetMinX(upBar.frame);
        CGFloat minY   = CGRectGetMinY(upBar.frame);
        CGFloat width  = CGRectGetWidth(upBar.frame);
        CGFloat height = CGRectGetHeight(upBar.frame);
        
        CGPoint anchorPoint =  CGPointMake((rotationPoint.x-minX)/width,
                                           (rotationPoint.y-minY)/height);
        
        upBar2.layer.anchorPoint = upBar.layer.anchorPoint = anchorPoint;
        upBar2.layer.position = upBar.layer.position = rotationPoint;
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(degreesToRadians(startAngle));
        transform = CGAffineTransformScale(transform, startScale, 1.0f);
        upBar2.transform = upBar.transform = transform;
        
        CGPoint dRotationPoint = CGPointMake(downBar.frame.size.width * .8, downBar.frame.origin.y +downBar.frame.size.height/2);
        CGFloat dMinX = CGRectGetMinX(downBar.frame);
        CGFloat dMinY = CGRectGetMinY(downBar.frame);
        CGFloat dWidth = CGRectGetWidth(downBar.frame);
        CGFloat dHeight = CGRectGetHeight(downBar.frame);
        
        CGPoint dAnchorPoint = CGPointMake((dRotationPoint.x - dMinX)/dWidth,
                                           (dRotationPoint.y - dMinY)/dHeight);
        
        downBar2.layer.anchorPoint = downBar.layer.anchorPoint = dAnchorPoint;
        downBar2.layer.position = downBar.layer.position = dRotationPoint;
        
        CGAffineTransform dTransform = CGAffineTransformMakeRotation(degreesToRadians(-startAngle));
        dTransform = CGAffineTransformScale(dTransform, startScale, 1.0f);
        downBar2.transform = downBar.transform = dTransform;
    }
    return self;
}

- (void)animateToCancel:(NSTimeInterval)animationDuration {
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotate.fromValue = @(degreesToRadians(startAngle));
    rotate.toValue = @(degreesToRadians(endAngle));
    rotate.duration = animationDuration;
    [rotate setFillMode:kCAFillModeForwards];
    [rotate setRemovedOnCompletion:NO];
    rotate.timingFunction = [CAMediaTimingFunction functionWithName:[[self class] mediaTimingFunction]];
    [upBar.layer addAnimation:rotate forKey:@"myRotationAnimation"];
    [upBar2.layer addAnimation:rotate forKey:@"myRotationAnimation"];
    
    rotate.fromValue = @(degreesToRadians(-startAngle));
    rotate.toValue = @(degreesToRadians(-endAngle));
    [downBar.layer addAnimation:rotate forKey:@"myRotationAnimation"];
    [downBar2.layer addAnimation:rotate forKey:@"myRotationAnimation"];
    
    CABasicAnimation* expand = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    expand.fromValue = [NSNumber numberWithFloat:startScale];
    expand.toValue = [NSNumber numberWithFloat:endScale];
    expand.duration = animationDuration;
    expand.delegate = self;
    [expand setFillMode:kCAFillModeForwards];
    [expand setRemovedOnCompletion:NO];
    expand.timingFunction = [CAMediaTimingFunction functionWithName:[[self class] mediaTimingFunction]];
    [[upBar layer] addAnimation:expand forKey:@"shrink"];
    [[upBar2 layer] addAnimation:expand forKey:@"shrink"];
    [[downBar layer] addAnimation:expand forKey:@"shrink"];
    [[downBar2 layer] addAnimation:expand forKey:@"shrink"];
    
    CABasicAnimation *thickness = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
    thickness.fromValue = [NSNumber numberWithFloat:1.0f];
    thickness.toValue = [NSNumber numberWithFloat:1.3f];
    thickness.duration = animationDuration;
    thickness.delegate = self;
    [thickness setFillMode:kCAFillModeForwards];
    [thickness setRemovedOnCompletion:NO];
    thickness.timingFunction = [CAMediaTimingFunction functionWithName:[[self class] mediaTimingFunction]];
    [[upBar layer] addAnimation:thickness forKey:@"thicker"];
    [[upBar2 layer] addAnimation:thickness forKey:@"thicker"];
    [[downBar layer] addAnimation:thickness forKey:@"thicker"];
    [[downBar2 layer] addAnimation:thickness forKey:@"thicker"];
}

- (void)animateToBack:(NSTimeInterval)animationDuration {
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotate.fromValue = @(degreesToRadians(endAngle));
    rotate.toValue = @(degreesToRadians(startAngle));
    rotate.duration = animationDuration;
    [rotate setFillMode:kCAFillModeForwards];
    [rotate setRemovedOnCompletion:NO];
    rotate.timingFunction = [CAMediaTimingFunction functionWithName:[[self class] mediaTimingFunction]];
    [upBar.layer addAnimation:rotate forKey:@"myRotationAnimation"];
    [upBar2.layer addAnimation:rotate forKey:@"myRotationAnimation"];
    
    rotate.fromValue = @(degreesToRadians(-endAngle));
    rotate.toValue = @(degreesToRadians(-startAngle));
    [downBar.layer addAnimation:rotate forKey:@"myRotationAnimation"];
    [downBar2.layer addAnimation:rotate forKey:@"myRotationAnimation"];
    
    CABasicAnimation* shrink = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    shrink.fromValue = [NSNumber numberWithFloat:endScale];
    shrink.toValue = [NSNumber numberWithFloat:startScale];
    shrink.duration = animationDuration;
    shrink.delegate = self;
    [shrink setFillMode:kCAFillModeForwards];
    [shrink setRemovedOnCompletion:NO];
    shrink.timingFunction = [CAMediaTimingFunction functionWithName:[[self class] mediaTimingFunction]];
    [[upBar layer] addAnimation:shrink forKey:@"shrink"];
    [[upBar2 layer] addAnimation:shrink forKey:@"shrink"];
    [[downBar layer] addAnimation:shrink forKey:@"shrink"];
    [[downBar2 layer] addAnimation:shrink forKey:@"shrink"];
    
    CABasicAnimation *thickness = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
    thickness.fromValue = [NSNumber numberWithFloat:1.3f];
    thickness.toValue = [NSNumber numberWithFloat:1.0f];
    thickness.duration = animationDuration;
    thickness.delegate = self;
    [thickness setFillMode:kCAFillModeForwards];
    [thickness setRemovedOnCompletion:NO];
    thickness.timingFunction = [CAMediaTimingFunction functionWithName:[[self class] mediaTimingFunction]];
    [[upBar layer] addAnimation:thickness forKey:@"thicker"];
    [[upBar2 layer] addAnimation:thickness forKey:@"thicker"];
    [[downBar layer] addAnimation:thickness forKey:@"thicker"];
    [[downBar2 layer] addAnimation:thickness forKey:@"thicker"];
}

- (void)grayIt {
    upBar.backgroundColor = [UIColor grayColor];
    upBar2.backgroundColor = [UIColor grayColor];
    downBar.backgroundColor = [UIColor grayColor];
    downBar2.backgroundColor = [UIColor grayColor];
}

- (void)blueIt {
    upBar.backgroundColor = self.tintColor;
    upBar2.backgroundColor = self.tintColor;
    downBar.backgroundColor = self.tintColor;
    downBar2.backgroundColor = self.tintColor;
}

@end
