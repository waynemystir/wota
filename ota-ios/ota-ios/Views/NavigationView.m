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

NSUInteger const kNavigationViewTag = 4141414141;
NSUInteger const kDefaultBackButtonTag = 94234598217;
NSUInteger const kWhereToContainerTag = 3495873928;
NSUInteger const kWhereToLabelTag = 378209359451;
NSUInteger const kBackCancelTag = 4729431;

static NSArray *kTitleViews = nil;

@interface NavigationView ()

@property (nonatomic, strong) UIView *whereToContainer;
@property (nonatomic, strong) UILabel *whereToUnderLabel;

@end

@implementation NavigationView

- (void)animateToCancel {
    BackCancelView *bcv = (BackCancelView *) [_leftView viewWithTag:kBackCancelTag];
    UIButton *b = (UIButton *) bcv.superview;
    NSLog(@"B allTargets %@", [b allTargets]);
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
    }
    return self;
}

- (UIButton *)defaultBackButton {
    UIButton *lb = [[UIButton alloc] initWithFrame:CGRectMake(3, 7, 32, 36)];
    lb.tag = kDefaultBackButtonTag;
    [lb addTarget:_navDelegate action:@selector(clickBack) forControlEvents:UIControlEventTouchUpInside];
    BackCancelView *bcv = [[BackCancelView alloc] initWithFrame:lb.bounds];
    bcv.tag = kBackCancelTag;
    [lb addSubview:bcv];
    return lb;
}

- (void)replaceTitleViewContainer:(UIView *)replacementView {
    for (NSNumber *tag in kTitleViews) {
        UIView *vw = [self viewWithTag:[tag integerValue]];
        vw.hidden = YES;
    }
    
    [_titleView addSubview:replacementView];
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

@end
