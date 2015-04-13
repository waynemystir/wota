//
//  LoadGooglePlacesData.h
//  ean-ota-ios
//
//  Created by WAYNE SMALL on 3/22/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoadDataProtocol.h"

@interface LoadGooglePlacesData : NSObject

@property (nonatomic, weak) id<LoadDataProtocol> delegate;

+ (LoadGooglePlacesData *)sharedInstance;
+ (LoadGooglePlacesData *)sharedInstance:(id<LoadDataProtocol>)delegate;

- (void)autoCompleteSomePlaces:(NSString *)queryString;
- (void)loadPlaceDetails:(NSString *)placeId;
- (void)loadPlaceDetailsWithPostalCode:(NSString *)postalCode;

@end
