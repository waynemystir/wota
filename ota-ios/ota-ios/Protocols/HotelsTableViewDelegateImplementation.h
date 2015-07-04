//
//  HotelsTableViewDelegateImplementation.h
//  ota-ios
//
//  Created by WAYNE SMALL on 6/22/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kNotificationHotelDataChanged;

@interface HotelsTableViewDelegateImplementation : NSObject <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSArray *hotelData;
@property (nonatomic, strong, readonly) NSArray *currentHotelData;

@end
