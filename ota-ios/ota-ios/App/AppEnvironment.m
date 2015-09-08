//
//  AppEnvironment.m
//  ean-ota-ios
//
//  Created by WAYNE SMALL on 3/20/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "AppEnvironment.h"

/**
 * General
 */

ENVIRONMENT_MODE environmentMode = DEVELOPMENT_MODE;

BOOL inProductionMode() {
    return environmentMode == PRODUCTION_MODE;
}

BOOL const isLogging = NO;

void TrotterLog(NSString *format, ...) {
    if (!isLogging) {
        return;
    }
    
    va_list args;
    va_start(args, format);
    NSString *log_msg = [[NSString alloc] initWithFormat:format arguments:args];
    NSLog(@"%@", log_msg);
    va_end(args);
}

NSString * const kKeyGuestInfo = @"LgAuYeEsRtCiAnKfEo";

//NSString * const GOOGLE_API_KEY = @"AIzaSyBTMg_o0S630MntWlqDC4J9tuNrh_YkLIo";
//NSString * const GOOGLE_API_KEY = @"AIzaSyDXmlmSp43YsY1QfPMaBP5Ww5UIXWNXXho";
NSString * GoogleApiKey() {
    if (inProductionMode()) {
        return @"AIzaSyDXmlmSp43YsY1QfPMaBP5Ww5UIXWNXXho"; // project name: ota-iOS
    } else if (environmentMode == BETA_MODE) {
        return @"AIzaSyDXmlmSp43YsY1QfPMaBP5Ww5UIXWNXXho"; // project name: ota-iOS
    } else {
        return @"AIzaSyBTMg_o0S630MntWlqDC4J9tuNrh_YkLIo"; // project name: ean-ota-ios
    }
}

int const URL_REQUEST_TIMEOUT = 30;

BOOL stringIsEmpty(NSString * aString) {
    
    if ((NSNull *) aString == [NSNull null]) {
        return YES;
    }
    
    if (aString == nil) {
        return YES;
    } else if ([aString length] == 0) {
        return YES;
    } else {
        aString = [aString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([aString length] == 0) {
            return YES;
        }
    }
    
    return NO;
}

NSString * stringByStrippingHTML(NSString * s) {
    return stringByStrippingHTMLReplaceBreak(s, @" ");
}

NSString * stringByStrippingHTMLReplaceBreak(NSString * s, NSString *brReplace) {
    return stringByStrippingHTMLReplaceBreakRemoveTail(s, brReplace, YES);
}

NSString * stringByStrippingHTMLReplaceBreakRemoveTail(NSString * s, NSString *brReplace, BOOL removeTail) {
    if (stringIsEmpty(s)) {
        return @"";
    }
    
    s = [s stringByReplacingOccurrencesOfString:@"<br />" withString:brReplace];
    s = [s stringByReplacingOccurrencesOfString:@"<br/>" withString:brReplace];
    
    if (removeTail) {
        NSRange lastOccurence = [s rangeOfString:brReplace options:NSBackwardsSearch];
        NSUInteger loc = lastOccurence.location;
        NSUInteger len = lastOccurence.length;
        NSUInteger sl = s.length;
        if (loc + len == sl) {
            s = [s stringByReplacingCharactersInRange:lastOccurence withString:@""];
        }
    }
    
    NSRange r;
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

NSString * const WOTA_CACHE_DIRECTORY = @"wota_cache_directory";
NSString * const WOTA_CACHE_CHILD_TRAVELERS_DIRECTORY = @"child_travelers_directory";
NSString * const WOTA_CACHE_GOOGLE_PLACE_DETAIL_DIRECTORY = @"google_place_detail_directory";

NSString * kWotaCacheDirectory() {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
                      stringByAppendingFormat:@"/%@", WOTA_CACHE_DIRECTORY];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return path;
}

NSString * kWotaCacheChildTravelersDirectory() {
    NSString *path = [kWotaCacheDirectory() stringByAppendingFormat:@"/%@", WOTA_CACHE_CHILD_TRAVELERS_DIRECTORY];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return path;
}

NSString * kWotaCacheGooglePlaceDetailDirectory() {
    NSString *path = [kWotaCacheDirectory() stringByAppendingFormat:@"/%@", WOTA_CACHE_GOOGLE_PLACE_DETAIL_DIRECTORY];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return path;
}

NSDateFormatter * kEanApiDateFormatter() {
    static NSDateFormatter *_eanApiDateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _eanApiDateFormatter = [[NSDateFormatter alloc] init];
        [_eanApiDateFormatter setDateFormat:@"MM/dd/yyyy"];
    });
    return _eanApiDateFormatter;
}

NSDateFormatter * kPrettyDateFormatter() {
    static NSDateFormatter *_prettyDateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _prettyDateFormatter = [[NSDateFormatter alloc] init];
        NSString *fStr = [NSDateFormatter dateFormatFromTemplate:@"MMMM dd, yyyy" options:0 locale:[NSLocale currentLocale]];
        [_prettyDateFormatter setLocale:[NSLocale currentLocale]];
        [_prettyDateFormatter setDateFormat:fStr];
        
    });
    return _prettyDateFormatter;
}

NSDateFormatter * kShortDateFormatter() {
    static NSDateFormatter *f = nil;
    static dispatch_once_t shortDateOnceToken;
    dispatch_once(&shortDateOnceToken, ^{
        f = [[NSDateFormatter alloc] init];
        NSString *fStr = [NSDateFormatter dateFormatFromTemplate:@"MMMd" options:0 locale:[NSLocale currentLocale]];
        [f setLocale:[NSLocale currentLocale]];
        [f setDateFormat:fStr];
    });
    return f;
}

NSDateFormatter * kShortShortDateFormatter() {
    static NSDateFormatter *f = nil;
    static dispatch_once_t shortDateOnceToken;
    dispatch_once(&shortDateOnceToken, ^{
        f = [[NSDateFormatter alloc] init];
        NSString *fStr = [NSDateFormatter dateFormatFromTemplate:@"MMd" options:0 locale:[NSLocale currentLocale]];
        [f setLocale:[NSLocale currentLocale]];
        [f setDateFormat:fStr];
    });
    return f;
}

NSNumberFormatter * kPriceRoundOffFormatter(NSString * currencyCode) {
    static NSNumberFormatter *_currencyStyle = nil;
    
    NSString *ccc = _currencyStyle.currencyCode;
    
    if (nil == _currencyStyle || nil == ccc || ![ccc isEqualToString:currencyCode]) {
        
        _currencyStyle = [[NSNumberFormatter alloc] init];
        [_currencyStyle setCurrencyCode:currencyCode];
        [_currencyStyle setNumberStyle:NSNumberFormatterCurrencyStyle];
        [_currencyStyle setMaximumFractionDigits:0];
        [_currencyStyle setRoundingMode: NSNumberFormatterRoundHalfUp];
        
    }
    
    return _currencyStyle;
}

NSNumberFormatter * kPriceTwoDigitFormatter(NSString * currencyCode) {
    static NSNumberFormatter *_currencyStyle = nil;
    
    NSString *ccc = _currencyStyle.currencyCode;
    
    if (nil == _currencyStyle || nil == ccc || ![ccc isEqualToString:currencyCode]) {
        
        _currencyStyle = [[NSNumberFormatter alloc] init];
        [_currencyStyle setCurrencyCode:currencyCode];
        [_currencyStyle setNumberStyle:NSNumberFormatterCurrencyStyle];
        [_currencyStyle setMaximumFractionDigits:2];
        [_currencyStyle setRoundingMode: NSNumberFormatterRoundHalfUp];
        
    }
    
    return _currencyStyle;
}

NSNumberFormatter * kNumberFormatterWithThousandsSeparatorNoDecimals() {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[NSLocale currentLocale]];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:0];
    return numberFormatter;
}

UIColor * kWotaColorOne() {
    return [UIColor colorWithRed:0.77f green:0.43f blue:0.00f alpha:1.00f];
}

UIColor * kColorGoodToGo() {
    return [UIColor colorWithRed:0 green:255 blue:0 alpha:0.75f];
}

UIColor * kColorNoGo() {
    return [UIColor colorWithRed:255 green:0 blue:0 alpha:0.75f];
}

UIColor * kNavigationColor() {
    return [UIColor colorWithRed:0.93f green:0.93f blue:0.93f alpha:1.0f];
}

UIColor * kNavBorderColor() {
    return [UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:1.0f];
}

UIColor * kTheColorOfMoney() {
    return UIColorFromRGB(0x0D9C03);
}

CGFloat const WOTA_CORNER_RADIUS = 6.0f;

NSDate * kAddDays(int days, NSDate * toDate) {
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = days;
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    return [theCalendar dateByAddingComponents:dayComponent toDate:toDate options:0];
}

NSDate * kTimelessDate(NSDate * givenDate) {
    unsigned int flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:flags fromDate:givenDate];
    return [calendar dateFromComponents:components];
}