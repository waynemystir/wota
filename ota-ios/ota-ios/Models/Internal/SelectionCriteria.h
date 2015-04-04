//
//  SelectionCriteria.h
//  ota-ios
//
//  Created by WAYNE SMALL on 3/28/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GooglePlaceDetail.h"
#import "ChildTraveler.h"

@interface SelectionCriteria : NSObject <NSCoding>

@property (nonatomic, strong, setter=setWhereTo:) NSString *whereTo;
@property (nonatomic, strong, setter=setGooglePlaceDetail:) GooglePlaceDetail *googlePlaceDetail;
@property (nonatomic, strong, setter=setArrivalDate:) NSDate *arrivalDate;
@property (nonatomic, strong, setter=setReturnDate:) NSDate *returnDate;
@property (nonatomic, setter=setNumberOfAdults:) NSUInteger numberOfAdults;

- (NSString *)arrivalDateEanString;
- (NSString *)returnDateEanString;

+ (SelectionCriteria *)singleton;

@end
