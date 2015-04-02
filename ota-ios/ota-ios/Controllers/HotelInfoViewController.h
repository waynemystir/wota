//
//  HotelInfoViewController.h
//  ota-ios
//
//  Created by WAYNE SMALL on 3/26/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadDataProtocol.h"
#import "EanHotel.h"

@interface HotelInfoViewController : UIViewController <LoadDataProtocol>

@property (nonatomic, strong) EanHotel *eanHotel;

- (id)initWithHotel:(EanHotel *)eanHotel;

@end
