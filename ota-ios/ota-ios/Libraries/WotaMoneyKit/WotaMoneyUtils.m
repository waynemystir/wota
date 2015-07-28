//
//  WotaMoneyUtils.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/20/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "WotaMoneyUtils.h"

@implementation WotaMoneyUtils

+ (NSRegularExpression *)nonNumericRegularExpression
{
    return [NSRegularExpression regularExpressionWithPattern:@"[^0-9]+" options:0 error:nil];
}

+ (NSCharacterSet *)numberCharacterSet
{
    return [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
}

+ (UIImage *)cardLogoImageWithShortName:(NSString *)shortName
{
    UIImage *cardLogoImage = nil;
    
    if (shortName) {
        cardLogoImage = [UIImage imageNamed:[NSString stringWithFormat:@"WotaMoneyKit.bundle/CardLogo/%@", shortName]];
    }
    
    if (nil == cardLogoImage) {
        cardLogoImage = [UIImage imageNamed:@"WotaMoneyKit.bundle/CardLogo/default"];
    }
    
    return cardLogoImage;
}

@end
