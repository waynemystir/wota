//
//  LocationAutoCompleteTableViewCell.h
//  ota-ios
//
//  Created by WAYNE SMALL on 3/24/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceAutoCompleteTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *outletPlaceName;
@property (nonatomic, strong) NSString *placeId;

@end
