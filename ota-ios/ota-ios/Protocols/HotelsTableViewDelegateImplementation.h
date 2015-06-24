//
//  HotelsTableViewDelegateImplementation.h
//  ota-ios
//
//  Created by WAYNE SMALL on 6/22/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HotelsTableViewDelegateImplementation : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *hotelData;

@end
