//
//  LoadEanData.m
//  ean-ota-ios
//
//  Created by WAYNE SMALL on 3/20/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "LoadEanData.h"
#import "AppEnvironment.h"
#import "ChildTraveler.h"

@interface LoadEanData () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSMutableData *responseData;

@end

@implementation LoadEanData

+ (LoadEanData *)sharedInstance {
    static LoadEanData *_instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _instance = [[LoadEanData alloc] init];
    });
    
    return _instance;
}

+ (LoadEanData *)sharedInstance:(id<LoadDataProtocol>)delegate {
    LoadEanData *ean = [self sharedInstance];
    ean.delegate = delegate;
    return ean;
}

- (void)loadHotelsWithLatitude:(double)latitude
                     longitude:(double)longitude {
    [self loadHotelsWithLatitude:latitude longitude:longitude arrivalDate:nil returnDate:nil];
}

- (void)loadHotelsWithLatitude:(double)latitude
                     longitude:(double)longitude
                   arrivalDate:(NSString *)arrivalDate
                    returnDate:(NSString *)returnDate {
    NSURL *url = [NSURL URLWithString:[self hotelUrlWithLatitude:latitude longitude:longitude arrivalDate:arrivalDate returnDate:returnDate]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:URL_REQUEST_TIMEOUT];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    self.responseData = [NSMutableData data];
    [connection start];
    [self notifyDelegateRequestHasStarted:url];
}

- (NSString *)hotelUrlWithLatitude:(double)latitude
                         longitude:(double)longitude
                       arrivalDate:(NSString *)arrivalDate
                        returnDate:(NSString *)returnDate {
    NSString *appendage = nil;
    
    if (arrivalDate == nil || returnDate == nil) {
        appendage = [NSString stringWithFormat:@""];
    } else {
        appendage = [NSString stringWithFormat:@"&%@=%@&%@=%@",
                     EAN_PK_ARRIVAL_DATE, arrivalDate,
                     EAN_PK_DEPART_DATE, returnDate];
    }
    
    return [[[self hotelUrlWithLatitude:latitude longitude:longitude] stringByAppendingString:appendage] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)hotelUrlWithLatitude:(double)latitude
                         longitude:(double)longitude {
    return [NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%f&%@=%f&%@=%@&%@=%@&%@=%@",
            kEanHotelListRequestUrl(),
            EAN_PK_CID, EAN_CID,
            EAN_PK_API_KEY, EAN_API_KEY,
            EAN_PK_LATITUDE, latitude,
            EAN_PK_LONGITUDE, longitude,
            EAN_PK_SEARCH_RADIUS, @10,
            EAN_PK_SEARCH_RADIUS_UNIT, @"MI",
            EAN_PK_GEO_SORT, @"PROXIMITY"];
}

- (void)loadHotelDetailsWithId:(NSString *)hotelId {
    NSURL *url = [NSURL URLWithString:[self hotelInfoUrlWithId:hotelId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:URL_REQUEST_TIMEOUT];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    self.responseData = [NSMutableData data];
    [connection start];
    [self notifyDelegateRequestHasStarted:url];
}

- (NSString *)hotelInfoUrlWithId:(NSString *)hotelId {
    return [NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@",
            kEanHotelInfoRequestUrl(),
            EAN_PK_CID, EAN_CID,
            EAN_PK_API_KEY, EAN_API_KEY,
            @"hotelId", hotelId];
}

- (void)loadAvailableRoomsWithHotelId:(NSString *)hotelId
                          arrivalDate:(NSString *)arrivalDate
                        departureDate:(NSString *)departureDate
                       numberOfAdults:(NSUInteger)numberOfAdults
                       childTravelers:(NSArray *)childTravelers {
    NSURL *url = [NSURL URLWithString:[self loadAvailableRoomsUrlWithHotelId:hotelId arrivalDate:arrivalDate departureDate:departureDate numberOfAdults:numberOfAdults childTravelers:childTravelers]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:URL_REQUEST_TIMEOUT];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    self.responseData = [NSMutableData data];
    [connection start];
    [self notifyDelegateRequestHasStarted:url];
}

- (NSString *)loadAvailableRoomsUrlWithHotelId:(NSString *)hotelId
                                   arrivalDate:(NSString *)arrivalDate
                                 departureDate:(NSString *)departureDate
                                numberOfAdults:(NSUInteger)numberOfAdults
                                childTravelers:(NSArray *)childTravelers {
    return [[NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@",
            kEanAvailableRoomsRequestUrl(),
            EAN_PK_CID, EAN_CID,
            EAN_PK_API_KEY, EAN_API_KEY,
            @"hotelId", hotelId,
            EAN_PK_ARRIVAL_DATE, arrivalDate,
            EAN_PK_DEPART_DATE, departureDate,
            [self getRoomGroupParamWithNumberOfAdults:numberOfAdults childTravelers:childTravelers]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)getRoomGroupParamWithNumberOfAdults:(NSUInteger)numberOfAdults
                                   childTravelers:(NSArray *)childTravelers {
    NSMutableString *roomGroup = [NSMutableString stringWithFormat:@"room1=%lu", (unsigned long)numberOfAdults];
    
    if (childTravelers == nil || [childTravelers count] == 0) {
        return roomGroup;
    }
    
    for (ChildTraveler *ct in childTravelers) {
        [roomGroup appendFormat:@",%lu", (unsigned long)ct.childAge];
    }
    
    return roomGroup;
}


- (void)bookHotelWithId:(NSString *)hotelId
            arrivalDate:(NSString *)arrivalDate
          departureDate:(NSString *)departureDate {
    
}

#pragma mark Various

- (void)notifyDelegateRequestHasStarted:(NSURL *)url {
    if ([self.delegate respondsToSelector:@selector(requestStarted:)]) {
        [self.delegate requestStarted:url];
    }
}

#pragma mark NSURLConnectionDataDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"%@.%@ RESPONSE:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [response description]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.delegate requestFinished:self.responseData];    
}

#pragma mark NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@.%@ ERROR:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [error localizedDescription]);
}

@end
