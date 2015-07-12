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
extern BOOL stringIsEmpty(NSString * aString);
extern NSString * stringByStrippingHTML(NSString * s);
extern NSString * stringByStrippingHTMLReplaceBreak(NSString * s, NSString *brReplace);
extern NSString * stringByStrippingHTMLReplaceBreakRemoveTail(NSString * s, NSString *brReplace, BOOL removeLast);

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
extern NSDateFormatter * kPrettyDateFormatter();
extern NSDateFormatter * kShortDateFormatter();
extern NSDateFormatter * kShortShortDateFormatter();
extern NSNumberFormatter * kPriceRoundOffFormatter(NSString * currencyCode);
extern NSNumberFormatter * kPriceTwoDigitFormatter(NSString * currencyCode);
extern NSNumberFormatter * kNumberFormatterWithThousandsSeparatorNoDecimals();

/**
 * Various colors
 */
extern UIColor * kWotaColorOne();
extern UIColor * kColorGoodToGo();
extern UIColor * kColorNoGo();
extern UIColor * kNavigationColor();
extern UIColor * kNavBorderColor();
extern UIColor * kTheColorOfMoney();

/**
 * What not
 */
extern CGFloat const WOTA_CORNER_RADIUS;
extern NSDate * kAddDays(int days, NSDate * toDate);
extern NSDate * kTimelessDate(NSDate * givenDate);
typedef NS_ENUM(NSUInteger, PLACE_DETAIL_LEVEL) {
    PLACE_LEVEL_EMPTY = 0,
    PLACE_LEVEL_NEIGHBORHOOD,
    PLACE_LEVEL_CITY,
    PLACE_LEVEL_STATE,
    PLACE_LEVEL_COUNTRY
};

