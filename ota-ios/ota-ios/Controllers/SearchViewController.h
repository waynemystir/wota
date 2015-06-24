//
//  SearchViewController.h
//  ota-ios
//
//  Created by WAYNE SMALL on 6/22/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadGooglePlacesData.h"

extern double const DEFAULT_RADIUS;

@interface SearchViewController : UIViewController <LoadDataProtocol>

@property (weak, nonatomic) IBOutlet UITextField *whereToTextField;
@property (weak, nonatomic) IBOutlet UILabel *whereToSecondLevel;
@property (nonatomic, strong) NSArray *placesTableData;
@property (nonatomic, strong) UITableView *placesTableView;
@property (nonatomic) CGRect placesTableViewZeroFrame;
@property (nonatomic) CGRect placesTableViewExpandedFrame;
@property (nonatomic) BOOL isPlacesTableViewExpanded;

- (void)animateTableViewExpansion;
- (void)animateTableViewCompression;
- (void)redrawMapViewAnimated:(BOOL)animated radius:(double)radius;

@end
