//
//  PreBookConfirmView.h
//  ota-ios
//
//  Created by WAYNE SMALL on 9/5/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WotaButton.h"
#import "WotaTappableView.h"

@protocol PreBookConfirmDelegate <NSObject>

- (void)clickTotalAmountLbl:(UITapGestureRecognizer *)tgr;
- (void)clickAcknowledgeCancellationPolicyLbl;
- (void)cancelBooking;
- (void)confirmBooking;

@end

@interface PreBookConfirmView : UIView

@property (nonatomic) BOOL acknowledged;

@property (weak, nonatomic) id<PreBookConfirmDelegate> preBookDelegate;
@property (weak, nonatomic) IBOutlet UILabel *hotelNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityStateCountryLabel;
@property (weak, nonatomic) IBOutlet UILabel *arrivalDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *departDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalChargesLabel;
@property (weak, nonatomic) IBOutlet WotaButton *cancelButton;
@property (weak, nonatomic) IBOutlet WotaButton *confirmButton;
@property (weak, nonatomic) IBOutlet UILabel *acknowCancelLabel;
@property (weak, nonatomic) IBOutlet WotaButton *acknowButton;
@property (weak, nonatomic) IBOutlet UIView *checkMark;
@property (weak, nonatomic) IBOutlet WotaTappableView *acknowCancelTouch;
@property (weak, nonatomic) IBOutlet WotaTappableView *totalContainer;

- (void)setupTheView;

@end
