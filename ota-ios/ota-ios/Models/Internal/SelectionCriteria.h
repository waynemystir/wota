//
//  SelectionCriteria.h
//  ota-ios
//
//  Created by WAYNE SMALL on 3/28/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GooglePlaceDetail.h"
#import "ChildTraveler.h"
#import "WotaPlace.h"

extern NSString * const kSelectionCriteriaLocationNotificationName;

@interface SelectionCriteria : NSObject <NSCoding>

@property (nonatomic, strong) NSMutableArray *placesArray;
@property (nonatomic, strong) WotaPlace *selectedPlace;

@property (nonatomic, strong, setter=setGooglePlaceDetail:) GooglePlaceDetail *googlePlaceDetail;
@property (nonatomic, strong, setter=setArrivalDate:) NSDate *arrivalDate;
@property (nonatomic, strong, setter=setReturnDate:) NSDate *returnDate;
@property (nonatomic, setter=setNumberOfAdults:) NSUInteger numberOfAdults;

@property (nonatomic, strong, readonly) NSString *whereTo;
@property (nonatomic, strong, readonly) NSString *whereToFirst;
@property (nonatomic, strong, readonly) NSString *whereToSecond;

@property (nonatomic, readonly) double latitude;
@property (nonatomic, readonly) double longitude;
@property (nonatomic) double zoomRadius;
@property (nonatomic, readonly) BOOL isLodging;

@property (nonatomic, strong, readonly) NSString *arrivalDateEanString;
@property (nonatomic, strong, readonly) NSString *returnDateEanString;

- (void)savePlace:(GooglePlaceDetail *)googlePlaceDetail;
- (BOOL)currentLocationIsSelectedPlace;

- (void)save;

+ (SelectionCriteria *)singleton;

@end
