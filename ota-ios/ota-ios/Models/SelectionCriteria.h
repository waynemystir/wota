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

@interface SelectionCriteria : NSObject

@property (nonatomic, strong) NSString *whereTo;
@property (nonatomic, strong) GooglePlaceDetail *googlePlaceDetail;
@property (nonatomic, strong) NSDate *arrivalDate;
@property (nonatomic, strong) NSDate *returnDate;
@property (nonatomic) NSUInteger numberOfAdults;
@property (nonatomic, strong) NSMutableArray *childTravelers;

- (NSString *)arrivalDateEanString;
- (NSString *)returnDateEanString;
- (NSUInteger)numberOfKids;
- (NSInteger)addChildTraveler:(ChildTraveler *)childTraveler;
- (NSInteger)removeLastChildTraveler;
- (BOOL)moreKidsOk;
- (BOOL)lessKidsOk;
- (ChildTraveler *)retrieveChildTravelerByNumber:(NSUInteger)number;
- (NSDictionary *)childTravelersWithoutAges;

+ (SelectionCriteria *)singleton;

@end
