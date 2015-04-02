//
//  LoadGooglePlacesData.m
//  ean-ota-ios
//
//  Created by WAYNE SMALL on 3/22/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
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
    [self.delegate requestStarted:url];
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
    [self.delegate requestStarted:url];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"%@.%@ RESPONSE:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [response description]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.delegate requestFinished:self.responseData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"ERROR:%@", [error localizedDescription]);
}

@end
