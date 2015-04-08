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

- (void)bookHotelRoomWithHotelId:(NSString *)hotelId
                     arrivalDate:(NSString *)arrivalDate
                   departureDate:(NSString *)departureDate
                    supplierType:(NSString *)supplierType
                         rateKey:(NSString *)rateKey
                    roomTypeCode:(NSString *)roomTypeCode
                        rateCode:(NSString *)rateCode
                  chargeableRate:(float)chargeableRate
                  numberOfAdults:(NSUInteger)numberOfAdults
                  childTravelers:(NSArray *)childTravelers
                  room1FirstName:(NSString *)room1FirstName
                   room1LastName:(NSString *)room1LastName
                  room1BedTypeId:(NSString *)room1BedTypeId
          room1SmokingPreference:(NSString *)room1SmokingPreference
         affiliateConfirmationId:(NSUUID *)affiliateConfirmationId
                           email:(NSString *)email
                       firstName:(NSString *)firstName
                        lastName:(NSString *)lastName
                       homePhone:(NSString *)homePhone
                  creditCardType:(NSString *)creditCardType
                creditCardNumber:(NSString *)creditCardNumber
            creditCardIdentifier:(NSString *)creditCardIdentifier
       creditCardExpirationMonth:(NSString *)creditCardExpirationMonth
        creditCardExpirationYear:(NSString *)creditCardExpirationYear
                        address1:(NSString *)address1
                            city:(NSString *)city
               stateProvinceCode:(NSString *)stateProvinceCode
                     countryCode:(NSString *)countryCode
                      postalCode:(NSString *)postalCode;

@end
