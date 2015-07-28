//
//  HotelInfoViewController.h
//  ota-ios
//
//  Created by WAYNE SMALL on 3/26/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadDataProtocol.h"
#import "EanHotelListHotelSummary.h"

@interface HotelInfoViewController : UIViewController <LoadDataProtocol>

@property (nonatomic, strong) EanHotelListHotelSummary *eanHotel;

- (id)initWithHotel:(EanHotelListHotelSummary *)eanHotel;

@end
