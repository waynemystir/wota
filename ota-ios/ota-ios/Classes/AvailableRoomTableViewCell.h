//
//  AvailableRoomTableViewCell.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/5/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AvailableRoomTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *borderViewOutlet;
@property (weak, nonatomic) IBOutlet UILabel *roomTypeDescriptionOutlet;
@property (weak, nonatomic) IBOutlet UILabel *rateOutlet;
@property (weak, nonatomic) IBOutlet UILabel *nonrefundOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *roomImageViewOutlet;

@end
