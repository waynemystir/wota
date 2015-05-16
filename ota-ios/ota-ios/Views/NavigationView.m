//
//  NavigationView.m
//  ota-ios
//
//  Created by WAYNE SMALL on 5/12/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "NavigationView.h"
#import "AppEnvironment.h"
#import "SelectionCriteria.h"
#import "ChildTraveler.h"
#import "BackCancelView.h"
#import "CheckMarkView.h"

NSTimeInterval const kNvAnimationDuration = 0.7;
NSUInteger const kNavigationViewTag = 4141414141;
NSUInteger const kDefaultBackButtonTag = 94234598217;
NSUInteger const kWhereToContainerTag = 34958739;
NSUInteger const kWhereToLabelTag = 378209359451;
NSUInteger const kBackCancelTag = 4729431;
NSUInteger const kRightCheckMarkButton = 39618732;
NSUInteger const kRightCheckMarkView = 4921743;

static NSArray *kTitleViews = nil;

@interface NavigationView ()

@property (nonatomic, strong) UIView *whereToContainer;
@property (nonatomic, strong) UILabel *whereToUnderLabel;

@end

@implementation NavigationView

- (void)animateToSecondCancel {
    UIButton *b = (UIButton *) [_leftView viewWithTag:kDefaultBackButtonTag];
    
    [b removeTarget:_navDelegate action:@selector(clickCancel) forControlEvents:UIControlEventTouchUpInside];
    if ([_navDelegate respondsToSelector:@selector(clickSecondCancel)]) {
        [b addTarget:_navDelegate action:@selector(clickSecondCancel) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [UIView transitionWithView:b duration:kNvAnimationDuration options:(UIViewAnimationOptionTransitionFlipFromTop) animations:^{
    } completion:^(BOOL finished) {
        
    }];
}

- (void)animateRevertToFirstCancel {
    UIButton *b = (UIButton *) [_leftView viewWithTag:kDefaultBackButtonTag];
    
    [b removeTarget:_navDelegate action:@selector(clickSecondCancel) forControlEvents:UIControlEventTouchUpInside];
    if ([_navDelegate respondsToSelector:@selector(clickCancel)]) {
        [b addTarget:_navDelegate action:@selector(clickCancel) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [UIView transitionWithView:b duration:kNvAnimationDuration options:(UIViewAnimationOptionTransitionFlipFromTop) animations:^{
        [self blueAndEnableLeftView];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)animateToCancel {
    BackCancelView *bcv = (BackCancelView *) [_leftView viewWithTag:kBackCancelTag];
    UIButton *b = (UIButton *) bcv.superview;
    
    [b removeTarget:_navDelegate action:@selector(clickBack) forControlEvents:UIControlEventTouchUpInside];
    if ([_navDelegate respondsToSelector:@selector(clickCancel)]) {
        [b addTarget:_navDelegate action:@selector(clickCancel) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [bcv animateToCancel];
}

- (void)animateToBack {
    BackCancelView *bcv = (BackCancelView *) [_leftView viewWithTag:kBackCancelTag];
    UIButton *b = (UIButton *) bcv.superview;
    [b removeTarget:_navDelegate action:@selector(clickCancel) forControlEvents:UIControlEventTouchUpInside];
    [b addTarget:_navDelegate action:@selector(clickBack) forControlEvents:UIControlEventTouchUpInside];
    [bcv animateToBack];
}

- (id)initWithDelegate:(id<NavigationDelegate>)navDelegate {
    CGRect frame = CGRectMake(0, 0, 320, 64);
    if (self = [self initWithFrame:frame withDelegate:navDelegate]) {
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withDelegate:(id<NavigationDelegate>)navDelegate {
    if (self = [super initWithFrame:frame]) {
        _navDelegate = navDelegate;
        self.tag = kNavigationViewTag;
        self.opaque = NO;
        self.backgroundColor = kNavigationColor();
        UIView *border = [[UIView alloc] initWithFrame:CGRectMake(0, 63.4f, 320, 0.6f)];
        border.backgroundColor = kNavBorderColor();
        [self addSubview:border];
        
        kTitleViews = [NSArray arrayWithObjects:[NSNumber numberWithInteger:kWhereToContainerTag], nil];
        
        _titleView = [[UIView alloc ]initWithFrame:CGRectMake(46, 20, 228, 44)];
        [self addSubview:_titleView];
        [self setupWhereToContainer];
        [_titleView addSubview:_whereToContainer];
                
        _leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 44, 44)];
        [_leftView addSubview:[self defaultBackButton]];
        [self addSubview:_leftView];
        
        _rightView = [[UIView alloc] initWithFrame:CGRectMake(276, 20, 44, 44)];
        [self addSubview:_rightView];
    }
    return self;
}

- (UIButton *)defaultBackButton {
    UIButton *lb = [[UIButton alloc] initWithFrame:CGRectMake(3, 7, 32, 36)];
//    lb.layer.borderWidth = 1.0f;
//    lb.layer.borderColor = [UIColor orangeColor].CGColor;
//    UIView *cv = [[UIView alloc] initWithFrame:CGRectMake(14, 0, 1, lb.frame.size.height)];
//    cv.backgroundColor = [UIColor orangeColor];
//    [lb addSubview:cv];
//    UIView *cv2 = [[UIView alloc] initWithFrame:CGRectMake(18, 0, 1, lb.frame.size.height)];
//    cv2.backgroundColor = [UIColor orangeColor];
//    [lb addSubview:cv2];
    lb.tag = kDefaultBackButtonTag;
    [lb addTarget:_navDelegate action:@selector(clickBack) forControlEvents:UIControlEventTouchUpInside];
    BackCancelView *bcv = [[BackCancelView alloc] initWithFrame:lb.bounds];
    bcv.tag = kBackCancelTag;
    [lb addSubview:bcv];
    return lb;
}

- (void)replaceTitleViewContainer:(UIView *)replacementView {
    [UIView transitionFromView:_whereToContainer toView:replacementView duration:kNvAnimationDuration options:UIViewAnimationOptionTransitionFlipFromTop completion:^(BOOL finished) {
        ;
    }];
}

- (void)animateRevertToWhereToContainer:(NSUInteger)removeTag {
    UIView *vtr = [_titleView viewWithTag:removeTag];
    
    [UIView transitionFromView:vtr toView:_whereToContainer duration:kNvAnimationDuration options:UIViewAnimationOptionTransitionFlipFromTop completion:^(BOOL finished) {
        ;
    }];
}

- (void)setupWhereToContainer {
    _whereToContainer = [[UIView alloc] initWithFrame:_titleView.bounds];
    _whereToContainer.tag = kWhereToContainerTag;
    [_whereToContainer addSubview:[self whereToLabel]];
    [self setupWhereToUnderLabel];
    [_whereToContainer addSubview:_whereToUnderLabel];
}

- (UILabel *)whereToLabel {
    UILabel *wtl = (UILabel *) [_whereToContainer viewWithTag:kWhereToLabelTag];
    if (nil == wtl) {
        wtl = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, 228, 21)];
        wtl.tag = kWhereToLabelTag;
        wtl.text = [SelectionCriteria singleton].whereTo;
        wtl.textColor = self.tintColor;
        wtl.textAlignment = NSTextAlignmentCenter;
        wtl.font = [UIFont boldSystemFontOfSize:15.0f];
    }
    return wtl;
}

- (void)setupWhereToUnderLabel {
    SelectionCriteria *sc = [SelectionCriteria singleton];
    _whereToUnderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 22, 228, 22)];
    _whereToUnderLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    _whereToUnderLabel.textColor = self.tintColor;
    _whereToUnderLabel.textAlignment = NSTextAlignmentCenter;
    NSDateFormatter *df = kShortShortDateFormatter();
    _whereToUnderLabel.text = [NSString stringWithFormat:@"🛄 %@ - %@  👤 %lu", [df stringFromDate:sc.arrivalDate], [df stringFromDate:sc.returnDate], (sc.numberOfAdults + [ChildTraveler numberOfKids])];
}

- (void)rightViewAddCheckMark {
    UIButton *lb = [[UIButton alloc] initWithFrame:CGRectMake(3, 7, 32, 36)];
    lb.tag = kRightCheckMarkButton;
    
    if ([_navDelegate respondsToSelector:@selector(clickRight)]) {
        [lb addTarget:_navDelegate action:@selector(clickRight) forControlEvents:UIControlEventTouchUpInside];
    }
    
    CheckMarkView *cm = [[CheckMarkView alloc] initWithFrame:lb.bounds];
    cm.tag = kRightCheckMarkView;
    [lb addSubview:cm];
//    [_rightView addSubview:lb];
    
    [UIView transitionWithView:_rightView duration:kNvAnimationDuration options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        [_rightView addSubview:lb];
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)rightViewRemoveCheckMark {
//    [[_rightView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIView *sv = [_rightView viewWithTag:kRightCheckMarkButton];
    [UIView transitionFromView:sv toView:nil duration:kNvAnimationDuration options:UIViewAnimationOptionTransitionFlipFromBottom completion:^(BOOL finished) {
        ;
    }];
}

- (void)rightViewEnableCheckMark {
    UIButton *lb = (UIButton *) [_rightView viewWithTag:kRightCheckMarkButton];
    lb.enabled = YES;
    CheckMarkView *cmv = (CheckMarkView *) [lb viewWithTag:kRightCheckMarkView];
    [cmv blueIt];
    cmv.alpha = 1.0f;
}

- (void)rightViewDisableCheckMark {
    UIButton *lb = (UIButton *) [_rightView viewWithTag:kRightCheckMarkButton];
    lb.enabled = NO;
    CheckMarkView *cmv = (CheckMarkView *) [lb viewWithTag:kRightCheckMarkView];
    cmv.alpha = 0.2f;
}

- (void)grayAndDisableLeftView {
    BackCancelView *bcv = (BackCancelView *) [_leftView viewWithTag:kBackCancelTag];
    [bcv grayIt];
    UIButton *b = (UIButton *) [_leftView viewWithTag:kDefaultBackButtonTag];
    b.enabled = NO;
}

- (void)grayAndDisableRiteView {
    UIButton *lb = (UIButton *) [_rightView viewWithTag:kRightCheckMarkButton];
    lb.enabled = NO;
    CheckMarkView *cmv = (CheckMarkView *) [lb viewWithTag:kRightCheckMarkView];
    [cmv grayIt];
}

- (void)blueAndEnableLeftView {
    BackCancelView *bcv = (BackCancelView *) [_leftView viewWithTag:kBackCancelTag];
    [bcv blueIt];
    UIButton *b = (UIButton *) [_leftView viewWithTag:kDefaultBackButtonTag];
    b.enabled = YES;
}

@end
