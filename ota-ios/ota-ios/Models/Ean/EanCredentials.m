//
//  EanCredentials.m
//  ota-ios
//
//  Created by WAYNE SMALL on 7/20/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanCredentials.h"
#import <CommonCrypto/CommonDigest.h>
#import "AppDelegate.h"
#import "EanHotelListResponse.h"
#import "EanHotelListHotelSummary.h"
#import "EanWsError.h"
#import "AppEnvironment.h"

@interface EanCredentials () <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

+ (NSDictionary *)testingCredentials;
+ (NSDictionary *)enabledCredentials;

@property (nonatomic, strong) NSMutableData *responseData;

@end

static int kTestingCredentialsNumber = 0;
static int kEnabledCredentialsNumber = 0;
static BOOL _stillWaitingForIterations = YES;
static BOOL _successfullyDeterminedEnabledCreds = NO;
static void (^_waitingForIterations)(BOOL success) = nil;

NSString * const EC_API_EXPERIENCE = @"PARTNER_MOBILE_APP";
NSString * const EC_MINOR_REV = @"30";

NSString * const EC_PK_API_EXPERIENCE = @"apiExperience";
NSString * const EC_PK_MINOR_REV = @"minorRev";
NSString * const EC_PK_API_KEY = @"apiKey";
NSString * const EC_PK_CID = @"cid";
NSString * const EC_PK_SHARED_SECRET = @"sharedSecredt";
NSString * const EC_PK_SIG = @"sig";
NSString * const EC_PK_CUSTIPADD = @"customerIpAddress";
NSString * const EC_PK_CUSTUSERAGENT = @"customerUserAgent";
NSString * const EC_PK_CUSTSESSID = @"customerSessionId";
NSString * const EC_PK_LOCALE = @"locale";
NSString * const EC_PK_CURRENCY_CODE = @"currencyCode";

NSString * const EC_GEN_REQ_BASE_URL = @"http://api.ean.com";
NSString * const EC_URL_EXT = @"ean-services/rs";
NSString * const EC_H0TEL_LIST = @"hotel/v3/list";
NSString * const EC_PK_LATITUDE = @"latitude";
NSString * const EC_PK_LONGITUDE = @"longitude";
NSString * const EC_PK_NUMBER_OF_RESULTS = @"numberOfResults";
NSString * const EC_PK_SEARCH_RADIUS = @"searchRadius";
NSString * const EC_PK_SEARCH_RADIUS_UNIT = @"searchRadiusUnit";
NSString * const EC_PK_GEO_SORT = @"sort";
NSString * const EC_PK_ARRIVAL_DATE = @"arrivalDate";
NSString * const EC_PK_DEPART_DATE = @"departureDate";

NSString * kEcGenerateSigMD5() {
    // Curtesy of http://stackoverflow.com/questions/2018550/how-do-i-create-an-md5-hash-of-a-string-in-cocoa
    NSTimeInterval uts = [[NSDate date] timeIntervalSince1970];
    NSUInteger utsInt = uts;
    NSString *unixTimeStamp = [NSString stringWithFormat:@"%lu", (unsigned long)utsInt];
    
    NSString *apiKey = [[EanCredentials testingCredentials] objectForKey:EC_PK_API_KEY];
    NSString *ss = [[EanCredentials testingCredentials] objectForKey:EC_PK_SHARED_SECRET];
    
    NSString *stringToHash = [NSString stringWithFormat:@"%@%@%@", apiKey, ss, unixTimeStamp];
    const char *cstr = [stringToHash UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cstr, (CC_LONG)strlen(cstr), result);
    
    return [[NSString stringWithFormat:
             @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}

NSString * kEcCustomerSessionId() {
    static NSString *_customerSessionId = nil;
    if (!_customerSessionId) {
        NSString *csid = [[[NSUUID UUID] UUIDString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _customerSessionId = [NSString stringWithFormat:@"Trotter-CustSessID-%@", csid];
    }
    return _customerSessionId;
}

NSString * kEcCustomerUserAgent() {
    static NSString *_customerUserAgent = nil;
    if (!_customerUserAgent) {
        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
        NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
        NSString *osVersion = [[UIDevice currentDevice] systemVersion];
        _customerUserAgent = [NSString stringWithFormat:@"%@/%@ (iOS %@) MOBILE_APP", appName, appVersion, osVersion];
    }
    return _customerUserAgent;
}

NSDictionary * kEcCredentials1() {
    return @{EC_PK_CID : @"482231",
             EC_PK_API_KEY : @"5fo5tmsoq7oul81bdon0ju59nu",
             EC_PK_SHARED_SECRET : @"ifpa7qqkuiu1"};
}

NSDictionary * kEcCredentials2() {
    return @{EC_PK_CID : @"493255",
             EC_PK_API_KEY : @"4d2vn0lkhdapmsp9ao25k6otu2",
             EC_PK_SHARED_SECRET : @"dkd9878sllepe"};
}

NSDictionary * kEcCredentials3() {
    return @{EC_PK_CID : @"493528",
             EC_PK_API_KEY : @"5q6r1sm22gp9c4vbiopfvk9qnf",
             EC_PK_SHARED_SECRET : @"8cnuubg6ob4h7"};
}

NSString * kEcCommonParameters() {
    return [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",
            EC_PK_API_EXPERIENCE, EC_API_EXPERIENCE,
            EC_PK_CID, [[EanCredentials testingCredentials] objectForKey:EC_PK_CID],
            EC_PK_API_KEY, [[EanCredentials testingCredentials] objectForKey:EC_PK_API_KEY],
            EC_PK_SIG, kEcGenerateSigMD5(),
            EC_PK_MINOR_REV, EC_MINOR_REV,
            EC_PK_LOCALE, [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier],
            EC_PK_CURRENCY_CODE, [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode],
            EC_PK_CUSTIPADD, [AppDelegate externalIP],
            EC_PK_CUSTSESSID, kEcCustomerSessionId(),
            EC_PK_CUSTUSERAGENT, kEcCustomerUserAgent()];
}

NSString * kURLecHotelList() {
    return [NSString stringWithFormat:@"%@/%@/%@?%@",
            EC_GEN_REQ_BASE_URL, EC_URL_EXT, EC_H0TEL_LIST, kEcCommonParameters()];
}

@implementation EanCredentials

+ (void)waitForEnabledCredentialIterations:(void (^)(BOOL success))completionHandler {
    if (_stillWaitingForIterations) {
        _waitingForIterations = completionHandler;
    } else {
        completionHandler(_successfullyDeterminedEnabledCreds);
    }
}

+ (NSArray *)credentialsArray {
    static NSArray* _ca = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _ca = [NSArray arrayWithObjects:kEcCredentials1(), kEcCredentials2(), kEcCredentials3(), nil];
    });
    
    return _ca;
}

+ (NSDictionary *)testingCredentials {
    return [self credentialsArray][kTestingCredentialsNumber];
}

+ (NSDictionary *)enabledCredentials {
    return [self credentialsArray][kEnabledCredentialsNumber];
}

#pragma mark Public credentials

+ (NSString *)CID {
    return [[self enabledCredentials] objectForKey:EC_PK_CID];
}

+ (NSString *)apiKey {
    return [[self enabledCredentials] objectForKey:EC_PK_API_KEY];
}

+ (NSString *)sharedSecret {
    return [[self enabledCredentials] objectForKey:EC_PK_SHARED_SECRET];
}

#pragma mark Fire up the iterations to check for enabled credentials

+ (void)load {
    [AppDelegate externalIP];
    [self determineEnabledCredentials];
}

+ (void)determineEnabledCredentials {
    kTestingCredentialsNumber = -1;
    [self nextWorkingCredentialsCheck];
}

+ (void)nextWorkingCredentialsCheck {
    kTestingCredentialsNumber++;
    if ((kTestingCredentialsNumber) >= [[self credentialsArray] count]) {
        _successfullyDeterminedEnabledCreds = NO;
        _stillWaitingForIterations = NO;
        if (_waitingForIterations) {
            _waitingForIterations(NO);
        }
        return;
    }
    
    EanCredentials *ec = [[EanCredentials alloc] init];
    NSURL *url = [NSURL URLWithString:[[self testURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:ec];
    ec.responseData = [NSMutableData data];
    [connection start];
    
    NSLog(@"%@.%@:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [url absoluteString]);
}

+ (NSString *)testURL {
    
    NSDate *ad = kAddDays(120, [NSDate date]);
    NSDate *dd = kAddDays(1, ad);
    
    // New York, NY 40.755867, -73.982428
    return [NSString stringWithFormat:@"%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",
            kURLecHotelList(),
            EC_PK_ARRIVAL_DATE, [kEanApiDateFormatter() stringFromDate:ad],
            EC_PK_DEPART_DATE, [kEanApiDateFormatter() stringFromDate:dd],
            EC_PK_LATITUDE, @40.755867,
            EC_PK_LONGITUDE, @-73.982428,
            EC_PK_NUMBER_OF_RESULTS, @2,
            EC_PK_SEARCH_RADIUS, @50,
            EC_PK_SEARCH_RADIUS_UNIT, @"MI",
            EC_PK_GEO_SORT, @"PROXIMITY"
            ];
}

#pragma mark NSURLConnectionDataDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"%@.%@:%@", self.class, NSStringFromSelector(_cmd), response);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self parseResponseData];
}

#pragma mark NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@.%@:%@", self.class, NSStringFromSelector(_cmd), error.userInfo);
    _stillWaitingForIterations = NO;
    _successfullyDeterminedEnabledCreds = YES;
    if (_waitingForIterations) {
        _waitingForIterations(YES);
    }
}

#pragma mark Helper

- (void)parseResponseData {
    NSMutableData *data = self.responseData;
    
    if (data == nil) {
        return [[self class] nextWorkingCredentialsCheck];
    }
    
    NSError *error = nil;
    id respDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error != nil) {
        NSLog(@"%@.%@ ERROR trying to deserialize JSON data:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), error);
        return [[self class] nextWorkingCredentialsCheck];
    }
    
    if (![NSJSONSerialization isValidJSONObject:respDict]) {
        NSLog(@"%@.%@ ERROR: Response is not valid JSON", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
        return [[self class] nextWorkingCredentialsCheck];
    }
    
    NSString *respString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@ JSON Response String:%@", NSStringFromClass(self.class), respString);
    
    if (nil == respDict) {
        return [[self class] nextWorkingCredentialsCheck];
    }
    
    if (![respDict isKindOfClass:[NSDictionary class]]) {
        return [[self class] nextWorkingCredentialsCheck];
    }
    
    id idHlr = [respDict objectForKey:@"HotelListResponse"];
    
    if (nil == idHlr) {
        return [[self class] nextWorkingCredentialsCheck];
    }
    
    if (![idHlr isKindOfClass:[NSDictionary class]]) {
        return [[self class] nextWorkingCredentialsCheck];
    }
    
    EanWsError *ewe = [EanWsError eanErrorFromApiJsonResponse:idHlr];
    if (ewe && [ewe.eweCategory isEqualToString:@"AUTHENTICATION"]) {
        return [[self class] nextWorkingCredentialsCheck];
    }
    
    kEnabledCredentialsNumber = kTestingCredentialsNumber;
    _successfullyDeterminedEnabledCreds = YES;
    _stillWaitingForIterations = NO;
    if (_waitingForIterations) {
        _waitingForIterations(YES);
    }
}

@end
