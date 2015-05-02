//
//  AppEnvironment.m
//  ean-ota-ios
//
//  Created by WAYNE SMALL on 3/20/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "AppEnvironment.h"

NSString * const kKeyGuestInfo = @"LgAuYeEsRtCiAnKfEo";
NSString * const kKeyPaymentDetails1 = @"pJaIyMmMeYnBtUdFeFtEaTiWlEsS1";

//NSString * const GOOGLE_API_KEY = @"AIzaSyBTMg_o0S630MntWlqDC4J9tuNrh_YkLIo";
NSString * const GOOGLE_API_KEY = @"AIzaSyDXmlmSp43YsY1QfPMaBP5Ww5UIXWNXXho";

int const URL_REQUEST_TIMEOUT = 30;

NSString * stringByStrippingHTML(NSString * s) {
    s = [s stringByReplacingOccurrencesOfString:@"<br />" withString:@" "];
    s = [s stringByReplacingOccurrencesOfString:@"<br/>" withString:@" "];
    
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

UIColor * kColorGoodToGo() {
    return [UIColor colorWithRed:0 green:255 blue:0 alpha:0.75f];
}

UIColor * kColorNoGo() {
    return [UIColor colorWithRed:255 green:0 blue:0 alpha:0.75f];
}

CGFloat const WOTA_CORNER_RADIUS = 6.0f;