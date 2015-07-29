//
//  ChildView.h
//  ota-ios
//
//  Created by WAYNE SMALL on 7/26/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChildView;

@protocol ChildViewDelegate <NSObject>

@required

- (void)childViewDonePressed;
- (void)childViewCancelled;
- (void)didHideChildView:(ChildView *)childView;

@end

@interface ChildView : UIView

@property (nonatomic, weak) id<ChildViewDelegate> childViewDelegate;

- (void)loadChildView;
+ (ChildView *)childViewFromNib;

@end
