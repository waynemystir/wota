//
//  WotaTappableView.h
//  ota-ios
//
//  Created by WAYNE SMALL on 5/4/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WotaTappableView : UIControl

@property (nonatomic, strong) UIColor *tapColor;
@property (nonatomic, strong) UIColor *untapColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic) BOOL playClickSound;

@end
