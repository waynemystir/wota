//
//  LoadDataProtocol.h
//  ean-ota-ios
//
//  Created by WAYNE SMALL on 3/20/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LOAD_DATA_TYPE) {
    LOAD_EAN_HOTELS_LIST = 0,
    LOAD_EAN_HOTEL_DETAILS,
    LOAD_EAN_PAYMENT_TYPES,
    LOAD_EAN_AVAILABLE_ROOMS,
    LOAD_EAN_BOOK,
    LOAD_EAN_ITIN,
    LOAD_GOOGLE_AUTOCOMPLETE,
    LOAD_GOOGLE_PLACES,
    LOAD_GOOGLE_REVERSE_GEOCODE
};

@protocol LoadDataProtocol <NSObject>

@required

- (void)requestFinished:(NSData *)responseData dataType:(LOAD_DATA_TYPE)dataType;
- (void)requestTimedOut:(LOAD_DATA_TYPE)dataType;
- (void)requestFailedOffline;
- (void)requestFailedCredentials;
- (void)requestFailed;

@optional

- (void)requestStarted:(NSURLConnection *)connection;

@end
