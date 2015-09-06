//
//  SelectRoomViewController.h
//  ota-ios
//
//  Created by WAYNE SMALL on 3/28/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadDataProtocol.h"

@interface SelectRoomViewController : UIViewController <LoadDataProtocol>

- (id)initWithPlaceholderImage:(UIImage *)placeholderImage
                     hotelName:(NSString *)hotelName
                  locationName:(NSString *)locationName;

@end
