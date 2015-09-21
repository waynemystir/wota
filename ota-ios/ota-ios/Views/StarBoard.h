//
//  StarBoard.h
//  ota-ios
//
//  Created by WAYNE SMALL on 6/6/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StarBoard : UIView

+ (UIImage *)starBoardImageForHotelListWithRating:(NSNumber *)rating;
+ (UIImage *)starBoardImageWithFrame:(CGRect)frame rating:(NSNumber *)rating;

@property (nonatomic, strong) NSNumber* numberOfStars;

@end
