//
//  ChildTraveler.h
//  ota-ios
//
//  Created by WAYNE SMALL on 3/29/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CHILD_TRAVELER_ID) {
    CHILD_TRAVELER_1 = 1,
    CHILD_TRAVELER_2 = 2,
    CHILD_TRAVELER_3 = 3,
    CHILD_TRAVELER_4 = 4
};

@interface ChildTraveler : NSObject <NSCoding>

@property (nonatomic, setter=setChildTravlerId:) CHILD_TRAVELER_ID childTravelerId;
@property (nonatomic, setter=setAgeHasBeenSet:) BOOL ageHasBeenSet;
@property (nonatomic, setter=setIsLessThanOne:) BOOL isLessThanOne;
@property (nonatomic, getter=getChildsAge, setter=setChildsAge:) NSUInteger childAge;

+ (ChildTraveler *)childTravelerForId:(CHILD_TRAVELER_ID)childTravelerId;
+ (NSArray *)childTravelers;
+ (int)numberOfKids;
+ (NSInteger)addChildTraveler;
+ (NSInteger)removeLastChildTraveler;
+ (BOOL)moreKidsOk;
+ (BOOL)lessKidsOk;
+ (NSDictionary *)childTravelersWithoutAges;

@end
