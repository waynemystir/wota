//
//  WotaCardNumberField.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/20/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "WotaCardNumberField.h"
#import "WotaMoneyUtils.h"
#import "Luhn.h"

@interface WotaCardNumberField ()

@property (nonatomic, strong) WotaCardNumberFormatter     *cardNumberFormatter;
@property (nonatomic, strong) UIImageView               *cardLogoImageView;
@property (nonatomic, strong) NSCharacterSet            *numberCharacterSet;

@end

@implementation WotaCardNumberField

#pragma mark - Initialize

- (void)commonInit
{
    [super commonInit];
    
    _cardNumberFormatter = [[WotaCardNumberFormatter alloc] init];
    
    _numberCharacterSet = [WotaMoneyUtils numberCharacterSet];
    
    self.keyboardType = UIKeyboardTypeNumberPad;
    self.clearButtonMode = UITextFieldViewModeAlways;
    
    [self addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
}

#pragma mark - Dealloc

- (void)dealloc
{
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([self.userDelegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        if (NO == [self.userDelegate textField:textField shouldChangeCharactersInRange:range replacementString:string]) {
            return NO;
        }
    }
    
    NSString *currentText = textField.text;
    
    NSCharacterSet *nonNumberCharacterSet = [self.numberCharacterSet invertedSet];
    
    if (string.length == 0 && [[currentText substringWithRange:range] stringByTrimmingCharactersInSet:nonNumberCharacterSet].length == 0) {
        // find non-whitespace character backward
        NSRange numberCharacterRange = [currentText rangeOfCharacterFromSet:self.numberCharacterSet
                                                                    options:NSBackwardsSearch
                                                                      range:NSMakeRange(0, range.location)];
        // adjust replace range
        if (numberCharacterRange.location != NSNotFound) {
            range = NSUnionRange(range, numberCharacterRange);
        }
    }
    
    NSString *newString = [currentText stringByReplacingCharactersInRange:range withString:string];
    
    // formatting card number
    textField.text = [self.cardNumberFormatter formattedStringFromRawString:newString];
    
    // send editing changed action because we edited text manually.
    [self sendActionsForControlEvents:UIControlEventEditingChanged];
    
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if ([self.userDelegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        if (NO == [self.userDelegate textFieldShouldClear:textField]) {
            return NO;
        }
    }
    
    // reset card number formatter
    textField.text = [self.cardNumberFormatter formattedStringFromRawString:@""];
    
    [self sendActionsForControlEvents:UIControlEventEditingChanged];
    
    return NO;
}

- (void)textFieldEditingChanged:(id)sender
{
    [self updateCardLogoImage];
}

#pragma mark - Private Methods

- (void)updateCardLogoImage
{
    if (nil == self.cardLogoImageView) {
        return;
    }
    
    WotaCardPatternInfo *patternInfo = self.cardNumberFormatter.cardPatternInfo;
    
    UIImage *cardLogoImage = [WotaMoneyUtils cardLogoImageWithShortName:patternInfo.shortName];
    
    self.cardLogoImageView.image = cardLogoImage;
}

#pragma mark - Public Methods

- (void)setShowsCardLogo:(BOOL)showsCardLogo
{
    if (_showsCardLogo != showsCardLogo) {
        _showsCardLogo = showsCardLogo;
        
        if (showsCardLogo) {
            
            CGFloat size = CGRectGetHeight(self.frame);
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44.f, size)];
            imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            imageView.contentMode = UIViewContentModeCenter;
            
            self.leftView = imageView;
            self.leftViewMode = UITextFieldViewModeAlways;
            
            self.cardLogoImageView = imageView;
            
            [self updateCardLogoImage];
            
        } else {
            self.leftView = nil;
        }
    }
}

- (void)setCardNumber:(NSString *)cardNumber
{
    self.text = [self.cardNumberFormatter formattedStringFromRawString:cardNumber];
    [self updateCardLogoImage];
}

- (NSString *)cardNumber
{
    return [self.cardNumberFormatter rawStringFromFormattedString:self.text];
}

- (NSString *)cardCompanyName
{
    return self.cardNumberFormatter.cardPatternInfo.companyName;
}

- (NSString *)eanType {
    return self.cardNumberFormatter.cardPatternInfo.eanType;
}

@end
