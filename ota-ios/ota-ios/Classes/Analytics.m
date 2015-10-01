//
//  Analytics.m
//  ota-ios
//
//  Created by WAYNE SMALL on 9/28/15.
//  Copyright © 2015 Trotter Travel LLC. All rights reserved.
//

#import "Analytics.h"

NSString * const URL_STRING = @"https://trotter-analytics-development.appspot.com/_ah/api/rpc?prettyPrint=false";
NSString * const API_KEY = @"abcdef";

@implementation Analytics

+ (NSMutableURLRequest *)daReq:(NSDictionary *)body {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_STRING]];
    
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    
    if (body) [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:body options:0 error:nil]];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    return request;
}

+ (void)postBookingRequestWithAffConfId:(NSString *)affiliateConfirmationId
                         room1FirstName:(NSString *)room1FirstName
                          room1LastName:(NSString *)room1LastName
                                hotelId:(NSString *)hotelId
                              hotelName:(NSString *)hotelName
                            arrivalDate:(NSString *)arrivalDate
                             departDate:(NSString *)departDate
                         chargeableRate:(float)chargeableRate
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
                                @"room1LastName":room1LastName,
                                @"affiliateConfirmationId":affiliateConfirmationId,
                                @"room1FirstName":room1FirstName,
                                @"hotelId":hotelId,
                                @"hotelName":hotelName,
                                @"arrivalDate":arrivalDate,
                                @"departDate":departDate,
                                @"chargeableRate":@(chargeableRate),
                                @"email":email,
                                @"homePhone":homePhone,
                                @"rateKey":rateKey,
                                @"roomTypeCode":roomTypeCode,
                                @"rateCode":rateCode,
                                @"roomDescription":roomDescription,
                                @"bedTypeId":bedTypeId,
                                @"smokingPref":smokingPref,
                                @"nonrefundable":nonrefundable,
                                @"customerSessionId":customerSessionId
                                },
                        @"apiVersion":@"v1"
                        };
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:[self daReq:d] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *rs = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *err = error ? error.localizedDescription : @"NO ERROR";
        NSLog(@"POST_REQUEST:%@ ERR:%@", rs, err);
    }] resume];
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
                                @"itineraryId":@(itineraryId),
                                @"affiliateConfirmationId":affiliateConfirmationId,
                                @"confirmationId":@(confirmationId),
                                @"processedWithConfirmation":processedWithConfirmation,
                                @"reservationStatusCode":reservationStatusCode,
                                @"nonrefundable":nonrefundable,
                                @"customerSessionId":customerSessionId
                                },
                        @"apiVersion":@"v1"
                        };
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:[self daReq:d] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *rs = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *err = error ? error.localizedDescription : @"NO ERROR";
        NSLog(@"POST_RESPONSE:%@ ERR:%@", rs, err);
    }] resume];
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
                                @"itineraryId":@(itineraryId),
                                @"verboseMessage":verboseMessage,
                                @"handling":handling,
                                @"category":category,
                                @"presentationMessage":presentationMessage
                                },
                        @"apiVersion":@"v1"
                        };
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:[self daReq:d] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *rs = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *err = error ? error.localizedDescription : @"NO ERROR";
        NSLog(@"POST_RESPONSE:%@ ERR:%@", rs, err);
    }] resume];
}

+ (void)postTrotterProblemWithCategory:(NSString *)category
                          shortMessage:(NSString *)shortMessage
                        verboseMessage:(NSString *)verboseMessage {
    NSDictionary *d = @{
                        @"jsonrpc":@"2.0",
                        @"method":@"wanalytics.postTrotterProblem",
                        @"id":@"gtl_1",
                        @"params":@{
                                @"verboseMessage":verboseMessage,
                                @"category":category,
                                @"shortMessage":shortMessage
                                },
                        @"apiVersion":@"v1"
                        };
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:[self daReq:d] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *rs = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *err = error ? error.localizedDescription : @"NO ERROR";
        NSLog(@"POST_RESPONSE:%@ ERR:%@", rs, err);
    }] resume];
}

@end
