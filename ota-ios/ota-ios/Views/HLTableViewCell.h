//
//  HLTableViewCell.h
//  ota-ios
//
//  Created by WAYNE SMALL on 6/6/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StarBoard.h"

@interface HLTableViewCell : UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier hotelRating:(NSNumber *)hotelRating;

@property (nonatomic, strong) UIImageView *thumbImageView;
//@property (nonatomic, strong) StarBoard *starBoard;
@property (nonatomic, strong) UILabel *hotelNameLabel;
@property (nonatomic, strong) UILabel *roomRateLabel;
@property (nonatomic, strong) UILabel *cityLabel;
@property (nonatomic, strong) UILabel *promoLabel;
@property (nonatomic, strong) UIImageView *starBoardContainer;

@end
