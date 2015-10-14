//
//  PreBookConfirmView.m
//  ota-ios
//
//  Created by WAYNE SMALL on 9/5/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "PreBookConfirmView.h"
#import "SelectionCriteria.h"
#import "AppEnvironment.h"

@implementation PreBookConfirmView

- (void)setupTheView {
    CGRect sr = [[UIScreen mainScreen] bounds];
    self.frame = CGRectMake(0, 64, sr.size.width, sr.size.height - 64);
    
    if (sr.size.height == 480) {
        self.canConfContainerBottomConstr.constant = 0.0f;
        self.roomDescHeightConstr.constant = 19.0f;
        self.hotelNameHeightConstr.constant = 19.0f;
        self.headerLabelHeightConstr.constant = 29.0f;
        self.headerLabelTopConstr.constant = 0.0f;
    }
    
    UITapGestureRecognizer *ttgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTotalAmtLabel:)];
    ttgr.numberOfTapsRequired = ttgr.numberOfTouchesRequired = 1;
    [_totalContainer addGestureRecognizer:ttgr];
    
    UITapGestureRecognizer *tncTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTermsAndConditionsLabel:)];
    tncTgr.numberOfTouchesRequired = tncTgr.numberOfTapsRequired = 1;
    [_termsAndConditionsLbl addGestureRecognizer:tncTgr];
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickAcknowLbl:)];
    tgr.numberOfTapsRequired = tgr.numberOfTouchesRequired = 1;
    _acknowCancelTouch.playClickSound = NO;
    [_acknowCancelTouch addGestureRecognizer:tgr];
    
    [_acknowButton addTarget:self action:@selector(clickAcknowBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_cancelButton addTarget:self action:@selector(clickCancel:) forControlEvents:UIControlEventTouchUpInside];
    [_confirmButton addTarget:self action:@selector(clickConfirm:) forControlEvents:UIControlEventTouchUpInside];
    
    SelectionCriteria *sc = [SelectionCriteria singleton];
    NSDateFormatter *df = kPrettyDateFormatter();
    _arrivalDateLabel.text = [NSString stringWithFormat:@"Arrive: %@", [df stringFromDate:sc.arrivalDate]];
    _departDateLabel.text = [NSString stringWithFormat:@"Depart: %@", [df stringFromDate:sc.returnDate]];
    
    _totalContainer.layer.cornerRadius = WOTA_CORNER_RADIUS;
    _totalContainer.layer.borderWidth = 1.0f;
    _totalContainer.layer.borderColor = kTheColorOfMoney().CGColor;
    _totalContainer.tapColor = kTheColorOfMoney();
    
    NSString *text = @"By confirming this booking, I acknowledge that I have read and accept the cancellation policy for the selected room.";
    
    NSDictionary *attribs = @{
                              NSForegroundColorAttributeName: self.acknowCancelLabel.textColor,
                              NSFontAttributeName: self.acknowCancelLabel.font
                              };
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:text
                                           attributes:attribs];
    
    NSRange redTextRange = [text rangeOfString:@"cancellation policy"];// * Notice that usage of rangeOfString in this case may cause some bugs - I use it here only for demonstration
    [attributedText setAttributes:@{NSForegroundColorAttributeName:self.tintColor}
                            range:redTextRange];
    
    self.acknowCancelLabel.attributedText = attributedText;
    
    self.acknowCancelTouch.borderColor = self.acknowCancelTouch.tapColor = self.acknowCancelTouch.untapColor = self.acknowCancelTouch.backgroundColor = [UIColor clearColor];
    self.checkMark.layer.cornerRadius = WOTA_CORNER_RADIUS;
}

- (void)clickTotalAmtLabel:(UITapGestureRecognizer *)tgr {
    if (!self.preBookDelegate) return;
    [self.preBookDelegate clickTotalAmountLbl:tgr];
}

- (void)clickTermsAndConditionsLabel:(UITapGestureRecognizer *)tgr {
    if (!self.preBookDelegate) return;
    [self.preBookDelegate clickTermsAndConditionsLbl:tgr];
}

- (void)clickAcknowLbl:(UITapGestureRecognizer *)tgr {
    if (!self.preBookDelegate) return;
    [self.preBookDelegate clickAcknowledgeCancellationPolicyLbl];
}

- (void)clickAcknowBtn:(id)sender {
    if (self.acknowledged) {
        self.confirmButton.enabled = NO;
        self.checkMark.hidden = YES;
    } else {
        self.confirmButton.enabled = YES;
        self.checkMark.hidden = NO;
    }
    
    self.acknowledged = !self.acknowledged;
}

- (void)clickCancel:(id)sender {
    if (!self.preBookDelegate) return;
    [self.preBookDelegate cancelBooking];
}

- (void)clickConfirm:(id)sender {
    if (!self.preBookDelegate) return;
    [self.preBookDelegate confirmBooking];
}

@end
