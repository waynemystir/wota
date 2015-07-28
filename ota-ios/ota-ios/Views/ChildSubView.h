//
//  ChildSubView.h
//  ota-ios
//
//  Created by WAYNE SMALL on 3/29/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WotaTappableView.h"

IB_DESIGNABLE

@interface ChildSubView : WotaTappableView

@property (weak, nonatomic) IBOutlet UILabel *worbelOutlet;
@property (strong, nonatomic) IBOutlet UIView *theViewOutlet;
@property (weak, nonatomic) IBOutlet UILabel *childAbcdLabelOutlet;

@end
