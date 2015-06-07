//
//  HLTableViewCell.m
//  ota-ios
//
//  Created by WAYNE SMALL on 6/6/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "HLTableViewCell.h"
#import "AppEnvironment.h"

@implementation HLTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier hotelRating:(NSNumber *)hotelRating {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _thumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 96, 96)];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImageView.clipsToBounds = YES;
        [self.contentView addSubview:_thumbImageView];
        
        _hotelNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(99, 3, 220, 26)];
        _hotelNameLabel.textColor = [UIColor blackColor];
        _hotelNameLabel.font = [UIFont boldSystemFontOfSize:15.5f];
        [self.contentView addSubview:_hotelNameLabel];
        
        _starBoard = [[StarBoard alloc] initWithFrame:CGRectMake(98, 35, 129, 26)];
        _starBoard.numberOfStars = hotelRating;
        CGAffineTransform t = CGAffineTransformMakeScale(0.75f, 0.75f);
        t = CGAffineTransformTranslate(t, -21, 0);
        _starBoard.transform = t;
        [self.contentView addSubview:_starBoard];
        
        _roomRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(198, 32, 119, 33)];
        _roomRateLabel.backgroundColor = [UIColor clearColor];
        _roomRateLabel.numberOfLines = 1;
        _roomRateLabel.minimumScaleFactor = 0.5f;
        _roomRateLabel.adjustsFontSizeToFitWidth = YES;
        _roomRateLabel.textColor = kTheColorOfMoney();
        _roomRateLabel.textAlignment = NSTextAlignmentRight;
        _roomRateLabel.font = [UIFont boldSystemFontOfSize:19.0f];
        [self.contentView addSubview:_roomRateLabel];
        
        _cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(99, 66, 150, 26)];
        _cityLabel.textColor = [UIColor grayColor];
        _cityLabel.textAlignment = NSTextAlignmentLeft;
        _cityLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        [self.contentView addSubview:_cityLabel];
        
        _waynester = [[UILabel alloc] initWithFrame:CGRectMake(260, 66, 30, 26)];
        _waynester.backgroundColor = [UIColor greenColor];
//        [self.contentView addSubview:_waynester];
        
        _hotelRatingLabel = [[UILabel alloc] initWithFrame:CGRectMake(290, 66, 30, 26)];
        _hotelRatingLabel.backgroundColor = [UIColor lightGrayColor];
        _hotelRatingLabel.text = [hotelRating stringValue];
//        [self.contentView addSubview:_hotelRatingLabel];
        
        UIView *separator = [[UILabel alloc] initWithFrame:CGRectMake(0, 95.5f, 320, 0.5f)];
        separator.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:separator];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
