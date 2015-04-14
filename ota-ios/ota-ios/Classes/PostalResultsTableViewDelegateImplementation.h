//
//  PostalResultsTableViewDelegateImplementation.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/13/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GooglePlace.h"

@protocol PostResultsDelegate <NSObject>

@required

- (void)didSelectRow:(GooglePlace *)googlePlace;

@end

@interface PostalResultsTableViewDelegateImplementation : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<PostResultsDelegate> delegate;
@property (nonatomic, strong) NSArray *tableData;

@end
