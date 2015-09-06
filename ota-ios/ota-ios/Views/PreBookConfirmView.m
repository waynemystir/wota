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
    self.frame = CGRectMake(0, 64, 320, 504);
    [_cancelButton addTarget:self action:@selector(clickCancel:) forControlEvents:UIControlEventTouchUpInside];
    [_confirmButton addTarget:self action:@selector(clickConfirm:) forControlEvents:UIControlEventTouchUpInside];
    SelectionCriteria *sc = [SelectionCriteria singleton];
    NSDateFormatter *df = kPrettyDateFormatter();
    _arrivalDateLabel.text = [NSString stringWithFormat:@"Arrive: %@", [df stringFromDate:sc.arrivalDate]];
    _departDateLabel.text = [NSString stringWithFormat:@"Depart: %@", [df stringFromDate:sc.returnDate]];
    _totalChargesLabel.layer.cornerRadius = WOTA_CORNER_RADIUS;
    _totalChargesLabel.layer.borderWidth = 1.0f;
    _totalChargesLabel.layer.borderColor = kTheColorOfMoney().CGColor;
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
