//
//  WotaMoneyUtils.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/20/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WotaMoneyUtils : NSObject

+ (NSRegularExpression *)nonNumericRegularExpression;

+ (NSCharacterSet *)numberCharacterSet;

+ (UIImage *)cardLogoImageWithShortName:(NSString *)shortName;

@end
