//
//  LoadEanData.h
//  ean-ota-ios
//
//  Created by WAYNE SMALL on 3/20/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoadDataProtocol.h"

@interface LoadEanData : NSObject

@property (nonatomic, weak) id<LoadDataProtocol> delegate;

+ (LoadEanData *)sharedInstance;
+ (LoadEanData *)sharedInstance:(id<LoadDataProtocol>)delegate;

- (void)loadHotelsWithLatitude:(double)latitude
                     longitude:(double)longitude;

- (void)loadHotelsWithLatitude:(double)latitude
                     longitude:(double)longitude
                   arrivalDate:(NSString *)arrivalDate
                    returnDate:(NSString *)returnDate;

- (void)loadHotelDetailsWithId:(NSString *)hotelId;

- (void)loadAvailableRoomsWithHotelId:(NSString *)hotelId
                          arrivalDate:(NSString *)arrivalDate
                        departureDate:(NSString *)departureDate
                       numberOfAdults:(NSUInteger)numberOfAdults
                       childTravelers:(NSArray *)childTravelers;

- (void)bookHotelWithId:(NSString *)hotelId
            arrivalDate:(NSString *)arrivalDate
          departureDate:(NSString *)departureDate;

@end
