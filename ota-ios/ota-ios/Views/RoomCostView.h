//
//  RoomCostView.h
//  ota-ios
//
//  Created by WAYNE SMALL on 9/18/15.
//  Copyright © 2015 Irwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EanAvailabilityHotelRoomResponse.h"

@interface RoomCostView : UIView

- (void)loadCostSummaryView:(UIView *)superView xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset;
- (void)loadCostSummaryView:(UIView *)superView wx:(CGFloat)wx wy:(CGFloat)wy xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset;
- (id)initWithFrame:(CGRect)frame room:(EanAvailabilityHotelRoomResponse *)room;

@end
