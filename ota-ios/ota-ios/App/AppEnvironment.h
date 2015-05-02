//
//  AppEnvironment.h
//  ean-ota-ios
//
//  Created by WAYNE SMALL on 3/20/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UITransparentFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:0.0]

/**
 * Keychain keys
 */
extern NSString * const kKeyGuestInfo;
extern NSString * const kKeyPaymentDetails1;

/**
 * Google stuff
 */
extern NSString * const GOOGLE_API_KEY;

extern int const URL_REQUEST_TIMEOUT;

/**
 * Various utilities
 */
extern NSString * stringByStrippingHTML(NSString * s);

/**
 * Various directories to persist the cache
 */
extern NSString * kWotaCacheDirectory();
extern NSString * kWotaCacheChildTravelersDirectory();
extern NSString * kWotaCacheGooglePlaceDetailDirectory();

/**
 * Various formatters
 */
extern NSDateFormatter * kEanApiDateFormatter();
extern NSNumberFormatter * kPriceRoundOffFormatter(NSString * currencyCode);
extern NSNumberFormatter * kPriceTwoDigitFormatter(NSString * currencyCode);

/**
 * Various colors
 */
extern UIColor * kColorGoodToGo();
extern UIColor * kColorNoGo();

/**
 * What not
 */
extern CGFloat const WOTA_CORNER_RADIUS;

