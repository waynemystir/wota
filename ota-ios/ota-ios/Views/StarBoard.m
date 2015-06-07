//
//  StarBoard.m
//  ota-ios
//
//  Created by WAYNE SMALL on 6/6/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "StarBoard.h"
#import "AppEnvironment.h"

@interface StarBoard ()

@property (nonatomic, strong) UIImageView *star1;
@property (nonatomic, strong) UIImageView *star2;
@property (nonatomic, strong) UIImageView *star3;
@property (nonatomic, strong) UIImageView *star4;
@property (nonatomic, strong) UIImageView *star5;
@property (nonatomic, strong) NSArray *stars;

@end

@implementation StarBoard

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initDaStars];
    }
    return self;
}

- (void)initDaStars {
    _star1 = [[UIImageView alloc] initWithFrame:CGRectMake(1, 1, 24, 24)];
    _star2 = [[UIImageView alloc] initWithFrame:CGRectMake(26, 1, 24, 24)];
    _star3 = [[UIImageView alloc] initWithFrame:CGRectMake(52, 1, 24, 24)];
    _star4 = [[UIImageView alloc] initWithFrame:CGRectMake(78, 1, 24, 24)];
    _star5 = [[UIImageView alloc] initWithFrame:CGRectMake(104, 1, 24, 24)];
    _star1.image = [UIImage imageNamed:@"star.png"];
    _star2.image = [UIImage imageNamed:@"star.png"];
    _star3.image = [UIImage imageNamed:@"star.png"];
    _star4.image = [UIImage imageNamed:@"star.png"];
    _star5.image = [UIImage imageNamed:@"star.png"];
    _star1.image = [_star1.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _star2.image = [_star2.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _star3.image = [_star3.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _star4.image = [_star4.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _star5.image = [_star5.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_star1 setTintColor:[UIColor lightGrayColor]];
    [_star2 setTintColor:[UIColor lightGrayColor]];
    [_star3 setTintColor:[UIColor lightGrayColor]];
    [_star4 setTintColor:[UIColor lightGrayColor]];
    [_star5 setTintColor:[UIColor lightGrayColor]];
    [self addSubview:_star1];
    [self addSubview:_star2];
    [self addSubview:_star3];
    [self addSubview:_star4];
    [self addSubview:_star5];
    _stars = [NSArray arrayWithObjects:_star1, _star2, _star3, _star4, _star5, nil];
}

- (void)setNumberOfStars:(NSNumber *)numberOfStars {
    _numberOfStars = numberOfStars;
    
    double hrd = [numberOfStars doubleValue];
    NSInteger floorHr = floor(hrd);
    hrd = hrd - floorHr;
    
    for (int j = 1; j <= 5; j++) {
        if (j <= [numberOfStars integerValue]) {
            [((UIImageView *)_stars[j-1]) setTintColor:kWotaColorOne()];
        }
    }
    
    if (hrd != 0 && floorHr >= 0 && floorHr < [_stars count]) {
        UIImageView *partialStar = _stars[floorHr];
        
        UIImage *ls = [UIImage imageNamed:@"star.png"];
        UIImageView *onaTop = [[UIImageView alloc] initWithImage:ls];
        onaTop.contentMode = UIViewContentModeLeft;
        onaTop.clipsToBounds = YES;
        onaTop.layer.masksToBounds = YES;
        [onaTop setTintColor:kWotaColorOne()];
        onaTop.frame = CGRectMake(0, 0, 12.4f, partialStar.frame.size.height);
        [partialStar addSubview:onaTop];
    }
}

@end
