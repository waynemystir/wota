//
//  NightlyRateTableViewDelegateImplementation.h
//  ota-ios
//
//  Created by WAYNE SMALL on 5/5/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EanAvailabilityHotelRoomResponse.h"

@interface NightlyRateTableViewDelegateImplementation : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *tableData;
@property (nonatomic, strong) EanAvailabilityHotelRoomResponse *room;

@end
