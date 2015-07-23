//
//  GuestsViewController.h
//  ota-ios
//
//  Created by WAYNE SMALL on 3/29/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChildViewDelegate <NSObject>

@required

- (void)childViewDonePressed;

@end

@interface ChildViewController : UIViewController

@property (nonatomic, weak) id<ChildViewDelegate> childViewDelegate;

@end
