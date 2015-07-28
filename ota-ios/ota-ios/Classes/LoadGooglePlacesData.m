//
//  LoadGooglePlacesData.m
//  ean-ota-ios
//
//  Created by WAYNE SMALL on 3/22/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "LoadGooglePlacesData.h"
#import "AppEnvironment.h"

@interface LoadGooglePlacesData () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSMutableData *responseData;

@end

@implementation LoadGooglePlacesData

+ (LoadGooglePlacesData *)sharedInstance {
    static LoadGooglePlacesData *loadPlaces = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        loadPlaces = [[LoadGooglePlacesData alloc] init];
    });
    return loadPlaces;
}

+ (LoadGooglePlacesData *)sharedInstance:(id<LoadDataProtocol>)delegate {
    LoadGooglePlacesData *places = [self sharedInstance];
    places.delegate = delegate;
    return places;
}

- (void)autoCompleteSomePlaces:(NSString *)queryString {
    NSString *urlString = [[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&key=%@", queryString, GOOGLE_API_KEY] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:URL_REQUEST_TIMEOUT];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    self.responseData = [NSMutableData data];
    [connection start];
    [self sendRequestStartedToDelegate:connection];
}

- (void)loadPlaceDetails:(NSString *)placeId {
    
    //***************************************************************
    // TODO: Cancel any and all auto complete requests
    //***************************************************************
    
    //***************************************************************
    // TODO: Get this URL and the one above into AppEnvironment
    //***************************************************************
    
    NSString *urlString = [[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=%@", placeId, GOOGLE_API_KEY] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:URL_REQUEST_TIMEOUT];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    self.responseData = [NSMutableData data];
    [connection start];
    [self sendRequestStartedToDelegate:connection];
}

- (void)loadPlaceDetailsWithLatitude:(double)latitude
                           longitude:(double)longitude
                     completionBlock:(void (^)(NSURLResponse *, NSData *, NSError *))completionBlock {
    
    NSString *types = @"park|natural_feature|establishment|airport|point_of_interest";
    
    NSString *urlString = [[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?&latlng=%f,%f&result_type=%@&key=%@", latitude, longitude, types, GOOGLE_API_KEY] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:URL_REQUEST_TIMEOUT];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSLog(@"PDWLL:%@", urlString);
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        completionBlock(response, data, connectionError);
    }];
}

- (void)loadPlaceDetailsWithPostalCode:(NSString *)postalCode {
    NSString *urlString = [[NSString stringWithFormat:@"https://maps.google.com/maps/api/geocode/json?components=postal_code:%@&key=%@&sensor=false", postalCode, GOOGLE_API_KEY] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:URL_REQUEST_TIMEOUT];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    self.responseData = [NSMutableData data];
    [connection start];
    [self sendRequestStartedToDelegate:connection];
}

- (void)loadNearbyPlacesWithLatitude:(double)latitude
                           longitude:(double)longitude
                               types:(NSArray *)types
                     completionBlock:(void (^)(NSURLResponse *, NSData *, NSError *))completionBlock {
    
    NSString *typesString = [types componentsJoinedByString:@"|"];
    NSString *urlString = [[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=%@&location=%f,%f&radius=%@&rankby=prominence&sensor=true&types=%@", GOOGLE_API_KEY, latitude, longitude, @500, typesString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:URL_REQUEST_TIMEOUT];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        completionBlock(response, data, connectionError);
    }];
}

- (void)sendRequestStartedToDelegate:(NSURLConnection *)connection {
    if ([self.delegate respondsToSelector:@selector(requestStarted:)]) {
        [self.delegate requestStarted:connection];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"%@.%@ RESPONSE:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [response description]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *cs = [[[connection currentRequest] URL] absoluteString];
    if ([cs containsString:@"autocomplete"]) {
        [self.delegate requestFinished:self.responseData dataType:LOAD_GOOGLE_AUTOCOMPLETE];
    } else if ([cs containsString:@"place/details"]
               || [cs containsString:@"maps/api/geocode"]
               || [cs containsString:@"maps/api/place"]) {
        [self.delegate requestFinished:self.responseData dataType:LOAD_GOOGLE_PLACES];
    } else {
        assert(false);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@.%@ ERROR:%@ URL:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [error localizedDescription], [[[connection currentRequest] URL] absoluteString]);
    
    if ([[error localizedDescription] containsString:@"timed out"]) {
        [self.delegate requestTimedOut];
    } else if ([[error localizedDescription] containsString:@"offline"]) {
        [self.delegate requestFailedOffline];
    } else {
        [self.delegate requestFailedOffline];
    }
}

@end
