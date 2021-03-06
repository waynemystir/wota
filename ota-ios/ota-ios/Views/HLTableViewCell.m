//
//  HLTableViewCell.m
//  ota-ios
//
//  Created by WAYNE SMALL on 6/6/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "HLTableViewCell.h"
#import "AppEnvironment.h"

#define degreesToRadians(x) (M_PI * x / 180.0)

@implementation HLTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier hotelRating:(NSNumber *)hotelRating {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.clipsToBounds = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGRect r = [[UIScreen mainScreen] bounds];
        
        _thumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 96, 96)];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImageView.clipsToBounds = YES;
        [self.contentView addSubview:_thumbImageView];
        
        CGFloat hnlX = r.size.width - 109;
        _hotelNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(99, 5, hnlX, 26)];
        _hotelNameLabel.backgroundColor = [UIColor clearColor];
        _hotelNameLabel.textColor = [UIColor blackColor];
        _hotelNameLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        _hotelNameLabel.adjustsFontSizeToFitWidth = YES;
        _hotelNameLabel.minimumScaleFactor = 0.98f;
        [self.contentView addSubview:_hotelNameLabel];
        
        _starBoardContainer = [[UIImageView alloc] initWithFrame:CGRectMake(98, 39, 129, 26)];
        _starBoardContainer.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_starBoardContainer];
        
//        _starBoard = [[StarBoard alloc] initWithFrame:CGRectMake(98, 35, 129, 26)];
//        _starBoard.numberOfStars = hotelRating;
//        CGAffineTransform t = CGAffineTransformMakeScale(0.75f, 0.75f);
//        t = CGAffineTransformTranslate(t, -21, 0);
//        _starBoard.transform = t;
//        [self.contentView addSubview:_starBoard];
        
        CGFloat rrlX = r.size.width - 122;
        _roomRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(rrlX, 32, 119, 33)];
        _roomRateLabel.backgroundColor = [UIColor clearColor];
        _roomRateLabel.numberOfLines = 1;
        _roomRateLabel.minimumScaleFactor = 0.4f;
        _roomRateLabel.adjustsFontSizeToFitWidth = YES;
        _roomRateLabel.textColor = kTheColorOfMoney();
        _roomRateLabel.textAlignment = NSTextAlignmentRight;
        _roomRateLabel.font = [UIFont boldSystemFontOfSize:19.0f];
        [self.contentView addSubview:_roomRateLabel];
        
        _cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(99, 65, 216, 26)];
        _cityLabel.textColor = [UIColor grayColor];
        _cityLabel.textAlignment = NSTextAlignmentLeft;
        _cityLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        [self.contentView addSubview:_cityLabel];
        
        CGFloat plX = r.size.width - 35;
        _promoLabel = [[UILabel alloc] initWithFrame:CGRectMake(plX, -8, 60, 27)];
        _promoLabel.backgroundColor = kTheColorOfMoney();
        _promoLabel.textColor = [UIColor whiteColor];
        _promoLabel.textAlignment = NSTextAlignmentCenter;
        _promoLabel.font = [UIFont boldSystemFontOfSize:11.0f];
        _promoLabel.numberOfLines = 2;
        _promoLabel.transform = CGAffineTransformMakeRotation(degreesToRadians(45));
        [self.contentView addSubview:_promoLabel];
        
        UIView *separator = [[UILabel alloc] initWithFrame:CGRectMake(0, 95.5f, r.size.width, 0.5f)];
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
