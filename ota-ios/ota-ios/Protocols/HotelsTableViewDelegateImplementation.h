//
//  HotelsTableViewDelegateImplementation.h
//  ota-ios
//
//  Created by WAYNE SMALL on 6/22/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trotter-Swift.h"

extern NSString * const kNotificationHotelDataFiltered;
extern NSString * const kNotificationHotelDataSorted;

@interface HotelsTableViewDelegateImplementation : NSObject <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSArray *hotelData;
@property (nonatomic, strong, readonly) NSArray *currentHotelData;
@property (nonatomic, readonly) BOOL inFilterMode;
@property (nonatomic) BOOL inFilterModePriorToLoadingFilterView;

@property (nonatomic, strong) NSNumber *bottomPrice;
@property (nonatomic, strong) NSNumber *topPrice;

@property (nonatomic) double selectedBottomPrice;
@property (nonatomic) double selectedTopPrice;

@property (nonatomic) double selectStarRating;

- (void)priceSliderChanged:(RangeSlider *)priceSlider;
- (void)starClicked:(UITapGestureRecognizer *)tgr;
- (int)numberOfFilteredHotels;
- (void)letsFilter;
- (void)letsSortYo:(UITapGestureRecognizer *)tgr;

@end
