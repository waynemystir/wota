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
NSUInteger const kDefaultBackButtonTag = 942398217;
NSUInteger const kWhereToContainerTag = 34958739;
NSUInteger const kWhereToLabelTag = 3782359451;
NSUInteger const kTitleUnderViewTag = 9127539;
NSUInteger const kBackCancelTag = 4729431;
NSUInteger const kRightCheckMarkButton = 39618732;
NSUInteger const kRightCheckMarkView = 4921743;

@interface NavigationView ()

@property (nonatomic, strong) UIView *whereToContainer;

@end

@implementation NavigationView

- (void)animateToSecondCancel {
    UIButton *b = (UIButton *) [_leftView viewWithTag:kDefaultBackButtonTag];
    
    [b removeTarget:_navDelegate action:@selector(clickCancel) forControlEvents:UIControlEventTouchUpInside];
    if ([_navDelegate respondsToSelector:@selector(clickSecondCancel)]) {
        [b addTarget:_navDelegate action:@selector(clickSecondCancel) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [UIView transitionWithView:b duration:[self navigationAnimationDuration] options:(UIViewAnimationOptionTransitionFlipFromTop) animations:^{
    } completion:^(BOOL finished) {
        
    }];
}

- (void)animateRevertToFirstCancel {
    UIButton *b = (UIButton *) [_leftView viewWithTag:kDefaultBackButtonTag];
    
    [b removeTarget:_navDelegate action:@selector(clickSecondCancel) forControlEvents:UIControlEventTouchUpInside];
    if ([_navDelegate respondsToSelector:@selector(clickCancel)]) {
        [b addTarget:_navDelegate action:@selector(clickCancel) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [UIView transitionWithView:b duration:[self navigationAnimationDuration] options:(UIViewAnimationOptionTransitionFlipFromTop) animations:^{
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
    
    [bcv animateToCancel:[self navigationAnimationDuration]];
}

- (void)animateToBack {
    BackCancelView *bcv = (BackCancelView *) [_leftView viewWithTag:kBackCancelTag];
    UIButton *b = (UIButton *) bcv.superview;
    [b removeTarget:_navDelegate action:@selector(clickCancel) forControlEvents:UIControlEventTouchUpInside];
    [b addTarget:_navDelegate action:@selector(clickBack) forControlEvents:UIControlEventTouchUpInside];
    [bcv animateToBack:[self navigationAnimationDuration]];
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
        
        _titleView = [[UIView alloc ]initWithFrame:CGRectMake(46, 20, 228, 44)];
        [self addSubview:_titleView];
        [self setupWhereToContainer];
        [_titleView addSubview:_whereToContainer];
                
        _leftView = [[UIView alloc] initWithFrame:CGRectMake(-4, 16, 48, 48)];
        [_leftView addSubview:[self defaultBackButton]];
        [self addSubview:_leftView];
        
        _rightView = [[UIView alloc] initWithFrame:CGRectMake(276, 20, 44, 44)];
        [self addSubview:_rightView];
    }
    return self;
}

- (UIButton *)defaultBackButton {
    UIButton *lb = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
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
    BackCancelView *bcv = [[BackCancelView alloc] initWithFrame:CGRectMake(10, 11, 28, 36)];
    bcv.tag = kBackCancelTag;
    [lb addSubview:bcv];
    return lb;
}

- (void)replaceTitleViewContainer:(UIView *)replacementView {
    [UIView transitionFromView:_whereToContainer toView:replacementView duration:[self navigationAnimationDuration] options:UIViewAnimationOptionTransitionFlipFromTop completion:^(BOOL finished) {
        ;
    }];
}

- (void)animateRevertToWhereToContainer:(NSUInteger)removeTag {
    UIView *vtr = [_titleView viewWithTag:removeTag];
    
    [UIView transitionFromView:vtr toView:_whereToContainer duration:[self navigationAnimationDuration] options:UIViewAnimationOptionTransitionFlipFromTop completion:^(BOOL finished) {
        ;
    }];
}

- (void)setupWhereToContainer {
    _whereToContainer = [[UIView alloc] initWithFrame:_titleView.bounds];
    _whereToContainer.tag = kWhereToContainerTag;
    [_whereToContainer addSubview:[self whereToLabel]];
    [_whereToContainer addSubview:[self titleUnderView]];
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:_navDelegate action:@selector(clickTitle)];
    tgr.numberOfTapsRequired = 1;
    tgr.numberOfTouchesRequired = 1;
    [_whereToContainer addGestureRecognizer:tgr];
}

- (UILabel *)whereToLabel {
    UILabel *wtl = (UILabel *) [_whereToContainer viewWithTag:kWhereToLabelTag];
    if (nil == wtl) {
        wtl = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, 228, 21)];
        wtl.tag = kWhereToLabelTag;
        wtl.lineBreakMode = NSLineBreakByClipping;
        
        NSArray *wta = [[SelectionCriteria singleton].whereTo componentsSeparatedByString:@","];
        if ([wta count] > 0 && !stringIsEmpty(wta[0])) {
            wtl.text = wta[0];
        }
        
        wtl.textColor = self.tintColor;
        wtl.textAlignment = NSTextAlignmentCenter;
        wtl.font = [UIFont boldSystemFontOfSize:15.0f];
    }
    return wtl;
}

- (UIView *)titleUnderView {
    UIView *tuv = [_whereToContainer viewWithTag:kTitleUnderViewTag];
    if (nil == tuv) {
        SelectionCriteria *sc = [SelectionCriteria singleton];
        
        UIImage *calendarImage = [[UIImage imageNamed:@"calendar.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImageView *cv = [[UIImageView alloc ]initWithFrame:CGRectMake(0, 3, 16, 16)];
        cv.image = calendarImage;
        cv.tintColor = self.tintColor;
        
        UILabel *datesLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 107, 22)];
        datesLabel.font = [UIFont boldSystemFontOfSize:15.0f];;
        datesLabel.textColor = self.tintColor;
        datesLabel.textAlignment = NSTextAlignmentLeft;
        NSDateFormatter *df = kShortShortDateFormatter();
        datesLabel.text = [NSString stringWithFormat:@"%@ - %@", [df stringFromDate:sc.arrivalDate], [df stringFromDate:sc.returnDate]];
        [datesLabel sizeToFit];
        CGRect dd = datesLabel.frame;
        datesLabel.frame = CGRectMake(dd.origin.x, dd.origin.y, dd.size.width, 22);
        CGFloat maxDatesPoint = CGRectGetMaxX(datesLabel.frame);
        
        UIImage *userSilhouetteImage = [[UIImage imageNamed:@"user_silhouette"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImageView *sv = [[UIImageView alloc] initWithFrame:CGRectMake(maxDatesPoint + 9, 3, 16, 16)];
        sv.image = userSilhouetteImage;
        sv.tintColor = self.tintColor;
        CGFloat maxSilhPoint = CGRectGetMaxX(sv.frame);
        
        UILabel *numbLabel = [[UILabel alloc] initWithFrame:CGRectMake(maxSilhPoint + 2, 0, 25, 22)];
        numbLabel.font = [UIFont boldSystemFontOfSize:15.0f];;
        numbLabel.textColor = self.tintColor;
        numbLabel.textAlignment = NSTextAlignmentLeft;
        numbLabel.text = [NSString stringWithFormat:@"%lu", (sc.numberOfAdults + [ChildTraveler numberOfKids])];
        [numbLabel sizeToFit];
        CGRect nn = numbLabel.frame;
        numbLabel.frame = CGRectMake(nn.origin.x, nn.origin.y, nn.size.width, 22);
        
        tuv = [[UIView alloc] initWithFrame:CGRectMake(0, 22, 228, 22)];
        tuv.tag = kTitleUnderViewTag;
        UIView *stuffContainer = [[UIView alloc] initWithFrame:tuv.bounds];
        [tuv addSubview:stuffContainer];
        
        [stuffContainer addSubview:cv];
        [stuffContainer addSubview:datesLabel];
        [stuffContainer addSubview:sv];
        [stuffContainer addSubview:numbLabel];
        CGFloat maxNumbPoint = CGRectGetMaxX(numbLabel.frame);
        stuffContainer.frame = CGRectMake((228 - maxNumbPoint)/2, 0, maxNumbPoint, 22);
    }
    return tuv;
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
    
    [UIView transitionWithView:_rightView duration:[self navigationAnimationDuration] options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        [_rightView addSubview:lb];
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)rightViewRemoveCheckMark {
//    [[_rightView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIView *sv = [_rightView viewWithTag:kRightCheckMarkButton];
    [UIView transitionFromView:sv toView:nil duration:[self navigationAnimationDuration] options:UIViewAnimationOptionTransitionFlipFromBottom completion:^(BOOL finished) {
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

- (void)rightViewAddSearch {
    UIImage *imr = [UIImage imageNamed:@"refresh.png"];
    UIImageView *ivr = [[UIImageView alloc] initWithImage:imr];
    ivr.tag = 92827262;
    ivr.frame = CGRectMake(6, 8, 32, 32);
    ivr.contentMode = UIViewContentModeScaleAspectFit;
    ivr.hidden = YES;
    [_rightView addSubview:ivr];
    
    UIImage *im = [UIImage imageNamed:@"search.png"];
    UIImageView *iv = [[UIImageView alloc] initWithImage:im];
    iv.tag = 93837363;
    iv.frame = CGRectMake(8, 12, 26, 26);
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [_rightView addSubview:iv];
    
    if ([_navDelegate respondsToSelector:@selector(clickRight)]) {
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:_navDelegate action:@selector(clickRight)];
        tgr.numberOfTapsRequired = 1;
        tgr.numberOfTouchesRequired = 1;
        _rightView.userInteractionEnabled = YES;
        [_rightView addGestureRecognizer:tgr];
    }
}

- (void)rightViewFlipToRefresh {
    UIView *ivr = [_rightView viewWithTag:92827262];
    UIView *sv = [_rightView viewWithTag:93837363];
    
    [UIView transitionFromView:sv
                        toView:ivr
                      duration:0.3
                       options:UIViewAnimationOptionTransitionFlipFromBottom|UIViewAnimationOptionShowHideTransitionViews
                    completion:^(BOOL finished) {
    }];
}

- (void)rightViewFlipToSearch {
    UIView *ivr = [_rightView viewWithTag:92827262];
    UIView *sv = [_rightView viewWithTag:93837363];
    
    [UIView transitionFromView:ivr
                        toView:sv
                      duration:0.3
                       options:UIViewAnimationOptionTransitionFlipFromBottom|UIViewAnimationOptionShowHideTransitionViews
                    completion:^(BOOL finished) {
    }];
}

- (NSTimeInterval)navigationAnimationDuration {
    if (_animationDuration > 0.0) {
        return _animationDuration;
    }
    return kNvAnimationDuration;
}

@end
