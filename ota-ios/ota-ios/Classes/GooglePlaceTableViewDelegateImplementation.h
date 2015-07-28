//
//  GooglePlaceTableViewDelegateImplementation.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/13/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GooglePlace.h"

@protocol SelectGooglePlaceDelegate <NSObject>

@required

- (void)didSelectRow:(GooglePlace *)googlePlace;

@end

@interface GooglePlaceTableViewDelegateImplementation : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<SelectGooglePlaceDelegate> delegate;
@property (nonatomic, strong) NSArray *tableData;

@end
