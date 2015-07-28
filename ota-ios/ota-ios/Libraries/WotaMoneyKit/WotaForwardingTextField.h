//
//  WotaForwardingTextField.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/20/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WotaForwardingTextField : UITextField <UITextFieldDelegate>

@property (nonatomic, assign, readonly) id<UITextFieldDelegate> userDelegate;

- (void)commonInit;

@end
