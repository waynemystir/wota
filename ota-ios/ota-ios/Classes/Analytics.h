//
//  Analytics.h
//  ota-ios
//
//  Created by WAYNE SMALL on 9/28/15.
//  Copyright © 2015 Trotter Travel LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Analytics : NSObject

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
                      customerSessionId:(NSString *)customerSessionId;

+ (void)postBookingResponseWithAffConfId:(NSString *)affiliateConfirmationId
                             itineraryId:(long long)itineraryId
                          confirmationId:(long long)confirmationId
               processedWithConfirmation:(NSNumber *)processedWithConfirmation
                   reservationStatusCode:(NSString *)reservationStatusCode
                           nonrefundable:(NSNumber *)nonrefundable
                       customerSessionId:(NSString *)customerSessionId;

+ (void)postEanErrorWithItineraryId:(long long)itineraryId
                           handling:(NSString *)handling
                           category:(NSString *)category
                presentationMessage:(NSString *)presentationMessage
                     verboseMessage:(NSString *)verboseMessage;

+ (void)postTrotterProblemWithCategory:(NSString *)category
                          shortMessage:(NSString *)shortMessage
                        verboseMessage:(NSString *)verboseMessage;

@end
