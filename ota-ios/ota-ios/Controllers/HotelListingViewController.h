//
//  HotelListingViewController.h
//  ean-ota-ios
//
//  Created by WAYNE SMALL on 3/21/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchViewController.h"
#import "LoadEanData.h"

@interface HotelListingViewController : SearchViewController <LoadDataProtocol>

- (id)initWithProvisionalTitle:(NSString *)provisionalTitle;

@end
