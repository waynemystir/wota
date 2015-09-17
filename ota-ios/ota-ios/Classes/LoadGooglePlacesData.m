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

- (void)fireOffGoogleConnectionWithURL:(NSURL *)url {
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

- (void)autoCompleteSomePlaces:(NSString *)queryString {
    NSString *urlString = [[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&key=%@", queryString, GoogleApiKey()] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlString];
    [self fireOffGoogleConnectionWithURL:url];
}

- (void)loadPlaceDetails:(NSString *)placeId {
    NSString *urlString = [[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=%@", placeId, GoogleApiKey()] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlString];
    [self fireOffGoogleConnectionWithURL:url];
}

- (void)loadPlaceDetailsWithLatitude:(double)latitude
                           longitude:(double)longitude {
    
    NSString *types = @"park|natural_feature|establishment|airport|point_of_interest";
    
    NSString *urlString = [[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?&latlng=%f,%f&result_type=%@&key=%@", latitude, longitude, types, GoogleApiKey()] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlString];
    [self fireOffGoogleConnectionWithURL:url];
}

- (void)sendRequestStartedToDelegate:(NSURLConnection *)connection {
    if ([self.delegate respondsToSelector:@selector(requestStarted:)]) {
        [self.delegate requestStarted:connection];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    TrotterLog(@"%@.%@ RESPONSE:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [response description]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *cs = [[[connection currentRequest] URL] absoluteString];
    if ([cs containsString:@"autocomplete"]) {
        [self.delegate requestFinished:self.responseData dataType:LOAD_GOOGLE_AUTOCOMPLETE];
    } else if ([cs containsString:@"place/details"]
               || [cs containsString:@"maps/api/place"]) {
        [self.delegate requestFinished:self.responseData dataType:LOAD_GOOGLE_PLACES];
    } else if ([cs containsString:@"maps/api/geocode"]) {
        [self.delegate requestFinished:self.responseData dataType:LOAD_GOOGLE_REVERSE_GEOCODE];
    } else {
        assert(false);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    TrotterLog(@"%@.%@ ERROR:%@ URL:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [error localizedDescription], [[[connection currentRequest] URL] absoluteString]);
    
    NSString *cs = [[[connection currentRequest] URL] absoluteString];
    LOAD_DATA_TYPE dt;
    if ([cs containsString:@"autocomplete"]) {
        dt = LOAD_GOOGLE_AUTOCOMPLETE;
    } else if ([cs containsString:@"place/details"]
               || [cs containsString:@"maps/api/place"]) {
        dt = LOAD_GOOGLE_PLACES;
    } else if ([cs containsString:@"maps/api/geocode"]) {
        dt = LOAD_GOOGLE_REVERSE_GEOCODE;
    } else {
        assert(false);
    }
    
    switch (error.code) {
        case NSURLErrorTimedOut: {
            [self.delegate requestTimedOut:dt];
            break;
        }
            
        case NSURLErrorNotConnectedToInternet: {
            [self.delegate requestFailedOffline];
            break;
        }
            
        default: {
            [self.delegate requestFailed];
            break;
        }
    }
}

@end
