//
//  StarBoard.m
//  ota-ios
//
//  Created by WAYNE SMALL on 6/6/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "StarBoard.h"
#import "AppEnvironment.h"

@interface StarBoard ()

@property (nonatomic, strong) UILabel *negatoryLabel;
@property (weak, nonatomic) IBOutlet UIView *toplevelSubView;
@property (nonatomic, weak) IBOutlet UIImageView *star1;
@property (nonatomic, weak) IBOutlet UIImageView *star2;
@property (nonatomic, weak) IBOutlet UIImageView *star3;
@property (nonatomic, weak) IBOutlet UIImageView *star4;
@property (nonatomic, weak) IBOutlet UIImageView *star5;
//@property (nonatomic, strong) UIImageView *star1;
//@property (nonatomic, strong) UIImageView *star2;
//@property (nonatomic, strong) UIImageView *star3;
//@property (nonatomic, strong) UIImageView *star4;
//@property (nonatomic, strong) UIImageView *star5;
@property (nonatomic, strong) NSArray *stars;

@end

@implementation StarBoard

+ (UIImage *)starBoardImageForHotelListWithRating:(NSNumber *)rating {
    
    float r  = [rating floatValue];
    
    if (r < 0.25) return [self sb00];
    else if (r >= 0.25 && r < 0.75) return [self sb05];
    else if (r >= 0.75 && r < 1.25) return [self sb10];
    else if (r >= 1.25 && r < 1.75) return [self sb15];
    else if (r >= 1.75 && r < 2.25) return [self sb20];
    else if (r >= 2.25 && r < 2.75) return [self sb25];
    else if (r >= 2.75 && r < 3.25) return [self sb30];
    else if (r >= 3.25 && r < 3.75) return [self sb35];
    else if (r >= 3.75 && r < 4.25) return [self sb40];
    else if (r >= 4.25 && r < 4.75) return [self sb45];
    else if (r >= 4.75 && r < 5.25) return [self sb50];
    else return [self sb00];
    
}

+ (CGRect)hotelTvCellFrame {
    static CGRect _f;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _f = CGRectMake(98, 35, 129, 26);
    });
    
    return _f;
}

+ (UIImage *)sb00 {
    static UIImage *_sb00 = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sb00 = [self starBoardImageWithFrame:[self hotelTvCellFrame] rating:@(0.0)];
    });
    
    return _sb00;
}

+ (UIImage *)sb05 {
    static UIImage *_sb05 = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sb05 = [self starBoardImageWithFrame:[self hotelTvCellFrame] rating:@(0.5)];
    });
    
    return _sb05;
}

+ (UIImage *)sb10 {
    static UIImage *_sb10 = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sb10 = [self starBoardImageWithFrame:[self hotelTvCellFrame] rating:@(1.0)];
    });
    
    return _sb10;
}

+ (UIImage *)sb15 {
    static UIImage *_sb15 = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sb15 = [self starBoardImageWithFrame:[self hotelTvCellFrame] rating:@(1.5)];
    });
    
    return _sb15;
}

+ (UIImage *)sb20 {
    static UIImage *_sb20 = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sb20 = [self starBoardImageWithFrame:[self hotelTvCellFrame] rating:@(2.0)];
    });
    
    return _sb20;
}

+ (UIImage *)sb25 {
    static UIImage *_sb25 = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sb25 = [self starBoardImageWithFrame:[self hotelTvCellFrame] rating:@(2.5)];
    });
    
    return _sb25;
}

+ (UIImage *)sb30 {
    static UIImage *_sb30 = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sb30 = [self starBoardImageWithFrame:[self hotelTvCellFrame] rating:@(3.0)];
    });
    
    return _sb30;
}

+ (UIImage *)sb35 {
    static UIImage *_sb35 = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sb35 = [self starBoardImageWithFrame:[self hotelTvCellFrame] rating:@(3.5)];
    });
    
    return _sb35;
}

+ (UIImage *)sb40 {
    static UIImage *_sb40 = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sb40 = [self starBoardImageWithFrame:[self hotelTvCellFrame] rating:@(4.0)];
    });
    
    return _sb40;
}

+ (UIImage *)sb45 {
    static UIImage *_sb45 = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sb45 = [self starBoardImageWithFrame:[self hotelTvCellFrame] rating:@(4.5)];
    });
    
    return _sb45;
}

+ (UIImage *)sb50 {
    static UIImage *_sb50 = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sb50 = [self starBoardImageWithFrame:[self hotelTvCellFrame] rating:@(5.0)];
    });
    
    return _sb50;
}

+ (UIImage *)starBoardImageWithFrame:(CGRect)frame rating:(NSNumber *)rating {
    StarBoard *starBoard = [[StarBoard alloc] initWithFrame:frame];
    starBoard.numberOfStars = rating;
    CGAffineTransform t = CGAffineTransformMakeScale(1.31f, 1.31f);
    t = CGAffineTransformTranslate(t, -21, 0);
    starBoard.transform = t;
    return [self imageFromView:starBoard];
}

+ (UIImage *) imageFromView:(UIView *)view {
    UIGraphicsBeginImageContext(view.frame.size);
    [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenshot;
}

- (id)initWithFrame:(CGRect)frame {
    if (self= [super initWithFrame:frame]) {
        [[NSBundle mainBundle] loadNibNamed:@"StarBoard" owner:self options:nil];
        [self addSubview:self.toplevelSubView];
        self.frame = frame;
        [self prepStarboard];
    }
    
    return self;
}

- (void)prepStarboard {
    [_star1 setTintColor:[UIColor lightGrayColor]];
    [_star2 setTintColor:[UIColor lightGrayColor]];
    [_star3 setTintColor:[UIColor lightGrayColor]];
    [_star4 setTintColor:[UIColor lightGrayColor]];
    [_star5 setTintColor:[UIColor lightGrayColor]];
    _stars = [NSArray arrayWithObjects:_star1, _star2, _star3, _star4, _star5, nil];
}

//- (id)initWithFrame:(CGRect)frame {
//    if (self = [super initWithFrame:frame]) {
//        [self initDaStars];
//    }
//    return self;
//}
//
//- (void)initDaStars {
//    _star1 = [[UIImageView alloc] initWithFrame:CGRectMake(1, 1, 24, 24)];
//    _star2 = [[UIImageView alloc] initWithFrame:CGRectMake(26, 1, 24, 24)];
//    _star3 = [[UIImageView alloc] initWithFrame:CGRectMake(52, 1, 24, 24)];
//    _star4 = [[UIImageView alloc] initWithFrame:CGRectMake(78, 1, 24, 24)];
//    _star5 = [[UIImageView alloc] initWithFrame:CGRectMake(104, 1, 24, 24)];
//    _star1.image = [UIImage imageNamed:@"star.png"];
//    _star2.image = [UIImage imageNamed:@"star.png"];
//    _star3.image = [UIImage imageNamed:@"star.png"];
//    _star4.image = [UIImage imageNamed:@"star.png"];
//    _star5.image = [UIImage imageNamed:@"star.png"];
//    _star1.image = [_star1.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    _star2.image = [_star2.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    _star3.image = [_star3.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    _star4.image = [_star4.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    _star5.image = [_star5.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    [_star1 setTintColor:[UIColor lightGrayColor]];
//    [_star2 setTintColor:[UIColor lightGrayColor]];
//    [_star3 setTintColor:[UIColor lightGrayColor]];
//    [_star4 setTintColor:[UIColor lightGrayColor]];
//    [_star5 setTintColor:[UIColor lightGrayColor]];
//    [self addSubview:_star1];
//    [self addSubview:_star2];
//    [self addSubview:_star3];
//    [self addSubview:_star4];
//    [self addSubview:_star5];
//    _stars = [NSArray arrayWithObjects:_star1, _star2, _star3, _star4, _star5, nil];
//}

- (void)initNegatory {
    _negatoryLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _negatoryLabel.backgroundColor = [UIColor whiteColor];
    _negatoryLabel.text = @"Not Rated";
    _negatoryLabel.textColor = [UIColor blackColor];
    _negatoryLabel.textAlignment = NSTextAlignmentLeft;
    _negatoryLabel.font = [UIFont systemFontOfSize:18.0f];
}

- (void)setNumberOfStars:(NSNumber *)numberOfStars {
    _numberOfStars = numberOfStars;
    double hrd = [numberOfStars doubleValue];
    
    if (hrd == 0) {
        [self initNegatory];
        [self addSubview:_negatoryLabel];
        [self bringSubviewToFront:_negatoryLabel];
        for (UIView *star in _stars) {
            [star removeFromSuperview];
        }
        return;
    }
    
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
