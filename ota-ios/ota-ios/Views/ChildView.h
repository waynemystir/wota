//
//  ChildView.h
//  ota-ios
//
//  Created by WAYNE SMALL on 7/26/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChildViewDelegate <NSObject>

@required

- (void)childViewDonePressed;
- (void)childViewCancelled;
- (void)childViewDidHide;

@end

@interface ChildView : UIView

@property (nonatomic, weak) id<ChildViewDelegate> childViewDelegate;

- (void)loadChildView;
+ (ChildView *)childViewFromNib;

@end
