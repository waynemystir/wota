//
//  HotelTableViewCell.h
//  ean-ota-ios
//
//  Created by WAYNE SMALL on 3/22/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HotelTableViewCell : UITableViewCell

@property (nonatomic, strong) NSString *hotelId;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (weak, nonatomic) IBOutlet UILabel *hotelNameLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *roomRateLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *tripAdvisorRatingLabelOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *thumbImageViewOutlet;

@end
