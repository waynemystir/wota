//
//  WotaCardNumberField.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/20/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "WotaForwardingTextField.h"
#import "WotaCardNumberFormatter.h"

@interface WotaCardNumberField : WotaForwardingTextField

/**
 * A Boolean indicating whether shows card logo left side or not.
 */
@property (nonatomic) BOOL showsCardLogo;

/**
 * The card number without blank space. (e.g., 1234123412341234)
 * Use this property to set or get card number instead of text property.
 */
@property (nonatomic, strong) NSString *cardNumber;

/**
 * The card company name. (e.g., Visa, Master, ...)
 */
@property (nonatomic, readonly) NSString *cardCompanyName;

/**
 * The card number formatter. You can change formatting behavior using this property.
 */
@property (nonatomic, strong, readonly) WotaCardNumberFormatter *cardNumberFormatter;

/**
 * The card number logo image view.
 */
@property (nonatomic, strong, readonly) UIImageView *cardLogoImageView;

/**
 *
 */
@property (nonatomic, getter=isCompletelyFilled) BOOL isCompletelyFilledIn;

@end
