//
//  EanHotelItineraryResponse.h
//  ota-ios
//
//  Created by WAYNE SMALL on 9/12/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanAbstractResponse.h"

@interface EanHotelItineraryResponse : EanAbstractResponse

@property (nonatomic, strong) NSArray *itineraries;
@property (nonatomic, strong) EanWsError *eanWsError;

@end
