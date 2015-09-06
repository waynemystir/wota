//
//  PreBookConfirmView.h
//  ota-ios
//
//  Created by WAYNE SMALL on 9/5/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WotaButton.h"

@protocol PreBookConfirmDelegate <NSObject>

- (void)cancelBooking;
- (void)confirmBooking;

@end

@interface PreBookConfirmView : UIView

@property (weak, nonatomic) id<PreBookConfirmDelegate> preBookDelegate;
@property (weak, nonatomic) IBOutlet UILabel *hotelNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityStateCountryLabel;
@property (weak, nonatomic) IBOutlet UILabel *arrivalDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *departDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalChargesLabel;
@property (weak, nonatomic) IBOutlet UILabel *refundableLabel;
@property (weak, nonatomic) IBOutlet WotaButton *cancelButton;
@property (weak, nonatomic) IBOutlet WotaButton *confirmButton;

- (void)setupTheView;

@end
