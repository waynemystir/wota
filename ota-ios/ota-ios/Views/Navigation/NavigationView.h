//
//  NavigationView.h
//  ota-ios
//
//  Created by WAYNE SMALL on 5/12/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSUInteger const kNavigationViewTag;

@protocol NavigationDelegate <NSObject>

@required

- (void)clickBack;
- (void)clickTitle;

@optional

- (void)clickCancel;
- (void)clickSecondCancel;
- (void)clickRight;

@end

@interface NavigationView : UIView

- (id)initWithDelegate:(id<NavigationDelegate>)navDelegate;

@property (nonatomic, strong) UILabel *whereToLabel;
@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UIView *theView;
@property (nonatomic, weak) id<NavigationDelegate> navDelegate;
@property (nonatomic) NSTimeInterval animationDuration;

- (void)blueAndEnableLeftView;
- (void)grayAndDisableLeftView;
- (void)grayAndDisableRiteView;

- (void)animateRevertToWhereToContainer:(NSUInteger)removeTag;
- (void)animateRevertToFirstCancel;
- (void)animateToSecondCancel;
- (void)animateToCancel;
- (void)animateToBack;
//- (void)clearLeftView;
- (void)replaceTitleViewContainer:(UIView *)replacementView;
- (void)rightViewAddCheckMark;
- (void)rightViewRemoveCheckMark;
- (void)rightViewEnableCheckMark;
- (void)rightViewDisableCheckMark;

- (void)rightViewAddSearch;
- (void)rightViewFlipToRefresh;
- (void)rightViewFlipToSearch;

@end
