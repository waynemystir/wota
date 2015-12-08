 //
//  Analytics.m
//  ota-ios
//
//  Created by WAYNE SMALL on 9/28/15.
//  Copyright © 2015 Trotter Travel LLC. All rights reserved.
//

#import "Analytics.h"
#import "AppEnvironment.h"
#import "AppDelegate.h"
#import "EanCredentials.h"
#import <AdSupport/AdSupport.h>

static NSString * const API_KEY = @"AIzaSyDOdThZQk931Sx7EQnMDA8spwSXk0NHw0E";
static NSString * const kNotAvailStr = @"nwa";
static const double kNotAvailDbl = -41.4141;
static const int kNotAvailInt = -41;
static BOOL verboseAnalytics = YES;

NSString * projectString() {
    if (inProductionMode()) {
        return @"trotter-analytics-production";
    } else if (inTestFlightMode()) {
        return @"trotter-analytics-beta";
    } else {
        return @"trotter-analytics-development";
    }
}

NSString * analyticsUrlString() {
    return [NSString stringWithFormat:@"https://%@.appspot.com/_ah/api/rpc?prettyPrint=false", projectString()];
}

@implementation Analytics

+ (NSMutableURLRequest *)daReq:(NSDictionary *)body {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:analyticsUrlString()]];
    
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    if (body) [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:body options:0 error:nil]];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    return request;
}

+ (void)performPost:(NSDictionary *)body {
    NSURLSessionConfiguration *urlconfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    urlconfig.timeoutIntervalForRequest = 30;
    urlconfig.timeoutIntervalForResource = 30;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:urlconfig];
    
    [[session dataTaskWithRequest:[self daReq:body] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!data || [self handleError:error] || [self handleResponse:response]) return;
        
        NSError *err = nil;
        id respDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        if (err != nil) {
            TrotterLog(@"%s ERROR trying to deserialize Analytics data:%@", __PRETTY_FUNCTION__, err);
            return;
        }
        
        if (respDict && [respDict isKindOfClass:[NSDictionary class]]) {
            id result = [respDict objectForKey:@"result"];
            if (result && [result isKindOfClass:[NSDictionary class]]) {
                id va = [result objectForKey:@"verboseAnalytics"];
                verboseAnalytics = va ? [va boolValue] : YES;
            }
        }
        
    }] resume];
}

+ (BOOL)handleError:(NSError *)error {
    if (!error) return NO;
    
    switch (error.code) {
        case NSURLErrorCancelled: break;
        case NSURLErrorTimedOut: break;
        case NSURLErrorNotConnectedToInternet: break;
        default: break;
    }
    
    return YES;
}

+ (BOOL)handleResponse:(NSURLResponse *)response {
    if (((NSHTTPURLResponse *)response).statusCode == 200) return NO;
    return YES;
}

+ (void)postLaunch:(NSString *)ipAddress {
    NSNumber *newInstall = [NSNumber numberWithBool:NO];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    BOOL alreadyInstalled = [ud boolForKey:@"trotterinstalled"];
    if (!alreadyInstalled) {
        newInstall = [NSNumber numberWithBool:YES];
        [ud setBool:YES forKey:@"trotterinstalled"];
    }
    
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSString *deviceType = [[UIDevice currentDevice] model];
    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    BOOL lat = [ASIdentifierManager sharedManager].advertisingTrackingEnabled;
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSDictionary *d = @{@"jsonrpc":@"2.0",
                        @"method":@"wanalytics.postLaunch",
                        @"id":@"gtl_1",
                        @"params":@{
                                @"apiKey":API_KEY,
                                @"ipAddress":ipAddress ? : kNotAvailStr,
                                @"osType":@"iOS",
                                @"osVersion":osVersion ? : kNotAvailStr,
                                @"deviceType":deviceType ? : kNotAvailStr,
                                @"newInstall":newInstall,
                                @"iosIdfa":idfa ? : kNotAvailStr,
                                @"limitAdTracking":[NSNumber numberWithBool:lat],
                                @"bundleId":bundleId ? : kNotAvailStr,
                                @"bundleVersion":bundleVersion ? : kNotAvailStr,
                                @"appVersion":appVersion ? : kNotAvailStr
                                },
                        @"apiVersion":@"v1"
                        };
    
    [self performPost:d];
}

+ (void)postHotelSearch:(NSString *)placeName
                placeId:(NSString *)placeId
            displayName:(NSString *)displayName
               latitude:(double)latitude
              longitude:(double)longitude
             zoomRadius:(double)zoomRadius
          numberResults:(int)numberResults {
    
    if (!verboseAnalytics) return;
    
    NSDictionary *d = @{@"jsonrpc":@"2.0",
                        @"method":@"wanalytics.postHotelSearch",
                        @"id":@"gtl_1",
                        @"params":@{
                                @"apiKey":API_KEY,
                                @"ipAddress":[AppDelegate externalIP],
                                @"placeName":placeName ? : kNotAvailStr,
                                @"placeId":placeId ? : kNotAvailStr,
                                @"displayName":displayName ? : kNotAvailStr,
                                @"latitude":@(latitude) ? : @(kNotAvailDbl),
                                @"longitude":@(longitude) ? : @(kNotAvailDbl),
                                @"zoomRadius":@(zoomRadius) ? : @(kNotAvailDbl),
                                @"numberResults":@(numberResults) ? : @(kNotAvailInt)
                                },
                        @"apiVersion":@"v1"
                        };
    
    [self performPost:d];
}

+ (void)postHotelInfo:(NSString *)hotelId hotelName:(NSString *)hotelName {
    
    if (!verboseAnalytics) return;
    
    NSDictionary *d = @{@"jsonrpc":@"2.0",
                        @"method":@"wanalytics.postHotelInfo",
                        @"id":@"gtl_1",
                        @"params":@{
                                @"apiKey":API_KEY,
                                @"ipAddress":[AppDelegate externalIP],
                                @"hotelId":hotelId ? : kNotAvailStr,
                                @"hotelName":hotelName ? : kNotAvailStr
                                },
                        @"apiVersion":@"v1"
                        };
    
    [self performPost:d];
}

+ (void)postRooms:(NSString *)hotelId hotelName:(NSString *)hotelName numberRooms:(int)numberRooms {
    
    if (!verboseAnalytics) return;
    
    NSDictionary *d = @{@"jsonrpc":@"2.0",
                        @"method":@"wanalytics.postRooms",
                        @"id":@"gtl_1",
                        @"params":@{
                                @"apiKey":API_KEY,
                                @"ipAddress":[AppDelegate externalIP],
                                @"hotelId":hotelId ? : kNotAvailStr,
                                @"hotelName":hotelName ? : kNotAvailStr,
                                @"numberRooms":@(numberRooms) ? : @(kNotAvailInt)
                                },
                        @"apiVersion":@"v1"
                        };
    
    [self performPost:d];
}

+ (void)postBookingRequestWithAffConfId:(NSString *)affiliateConfirmationId
                         room1FirstName:(NSString *)room1FirstName
                          room1LastName:(NSString *)room1LastName
                                hotelId:(NSString *)hotelId
                              hotelName:(NSString *)hotelName
                            arrivalDate:(NSString *)arrivalDate
                             departDate:(NSString *)departDate
                         chargeableRate:(float)chargeableRate
                           currencyCode:(NSString *)currencyCode
                                  email:(NSString *)email
                              homePhone:(NSString *)homePhone
                                rateKey:(NSString *)rateKey
                           roomTypeCode:(NSString *)roomTypeCode
                               rateCode:(NSString *)rateCode
                        roomDescription:(NSString *)roomDescription
                              bedTypeId:(NSString *)bedTypeId
                            smokingPref:(NSString *)smokingPref
                          nonrefundable:(NSNumber *)nonrefundable
                      customerSessionId:(NSString *)customerSessionId {
    NSDictionary *d = @{@"jsonrpc":@"2.0",
                        @"method":@"wanalytics.postBookingRequest",
                        @"id":@"gtl_1",
                        @"params":@{
                                @"apiKey":API_KEY,
                                @"room1LastName":room1LastName,
                                @"affiliateConfirmationId":affiliateConfirmationId ? : kNotAvailStr,
                                @"room1FirstName":room1FirstName,
                                @"hotelId":hotelId ? : kNotAvailStr,
                                @"hotelName":hotelName ? : kNotAvailStr,
                                @"arrivalDate":arrivalDate ? : kNotAvailStr,
                                @"departDate":departDate ? : kNotAvailStr,
                                @"chargeableRate":@(chargeableRate) ? : @(kNotAvailDbl),
                                @"currencyCode":currencyCode ? : kNotAvailStr,
                                @"email":email,
                                @"homePhone":homePhone,
                                @"rateKey":rateKey ? : kNotAvailStr,
                                @"roomTypeCode":roomTypeCode ? : kNotAvailStr,
                                @"rateCode":rateCode ? : kNotAvailStr,
                                @"roomDescription":roomDescription ? : kNotAvailStr,
                                @"bedTypeId":bedTypeId ? : kNotAvailStr,
                                @"smokingPref":smokingPref ? : kNotAvailStr,
                                @"nonrefundable":nonrefundable ? : @(0),
                                @"customerSessionId":customerSessionId ? : kNotAvailStr,
                                @"ipAddress":[AppDelegate externalIP],
                                @"eanCid":[EanCredentials CID] ? : kNotAvailStr
                                },
                        @"apiVersion":@"v1"
                        };
    
    [self performPost:d];
}

+ (void)postBookingResponseWithAffConfId:(NSString *)affiliateConfirmationId
                             itineraryId:(long long)itineraryId
                          confirmationId:(long long)confirmationId
               processedWithConfirmation:(NSNumber *)processedWithConfirmation
                   reservationStatusCode:(NSString *)reservationStatusCode
                           nonrefundable:(NSNumber *)nonrefundable
                       customerSessionId:(NSString *)customerSessionId {
    NSDictionary *d = @{@"jsonrpc":@"2.0",
                        @"method":@"wanalytics.postBookingResponse",
                        @"id":@"gtl_1",
                        @"params":@{
                                @"apiKey":API_KEY,
                                @"itineraryId":@(itineraryId) ? : @(kNotAvailInt),
                                @"affiliateConfirmationId":affiliateConfirmationId ? : kNotAvailStr,
                                @"confirmationId":@(confirmationId) ? : @(kNotAvailInt),
                                @"processedWithConfirmation":processedWithConfirmation ? : @(0),
                                @"reservationStatusCode":reservationStatusCode ? : kNotAvailStr,
                                @"nonrefundable":nonrefundable ? : @(0),
                                @"customerSessionId":customerSessionId ? : kNotAvailStr,
                                @"ipAddress":[AppDelegate externalIP],
                                @"eanCid":[EanCredentials CID] ? : kNotAvailStr
                                },
                        @"apiVersion":@"v1"
                        };
    
    [self performPost:d];
}

+ (void)postEanErrorWithItineraryId:(long long)itineraryId
                           handling:(NSString *)handling
                           category:(NSString *)category
                presentationMessage:(NSString *)presentationMessage
                     verboseMessage:(NSString *)verboseMessage {
    NSDictionary *d = @{
                        @"jsonrpc":@"2.0",
                        @"method":@"wanalytics.postEanError",
                        @"id":@"gtl_1",
                        @"params":@{
                                @"apiKey":API_KEY,
                                @"itineraryId":@(itineraryId) ? : @(kNotAvailInt),
                                @"verboseMessage":verboseMessage ? : kNotAvailStr,
                                @"handling":handling ? : kNotAvailStr,
                                @"category":category ? : kNotAvailStr,
                                @"presentationMessage":presentationMessage ? : kNotAvailStr
                                },
                        @"apiVersion":@"v1"
                        };
    
    [self performPost:d];
}

+ (void)postTrotterProblemWithCategory:(NSString *)category
                          shortMessage:(NSString *)shortMessage
                        verboseMessage:(NSString *)verboseMessage {
    NSDictionary *d = @{
                        @"jsonrpc":@"2.0",
                        @"method":@"wanalytics.postTrotterProblem",
                        @"id":@"gtl_1",
                        @"params":@{
                                @"apiKey":API_KEY,
                                @"verboseMessage":verboseMessage ? : kNotAvailStr,
                                @"category":category ? : kNotAvailStr,
                                @"shortMessage":shortMessage ? : kNotAvailStr
                                },
                        @"apiVersion":@"v1"
                        };
    
    [self performPost:d];
}

@end
