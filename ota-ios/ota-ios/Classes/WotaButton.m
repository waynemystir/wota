//
//  WotaButton.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/23/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "WotaButton.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AppEnvironment.h"

@implementation WotaButton

+ (WotaButton *)wbWithFrame:(CGRect)frame {
    WotaButton *wb = [self buttonFromNib];
    wb.frame = frame;
    return wb;
}

+ (WotaButton *)buttonFromNib {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"WotaButton" owner:self options:nil];
    if ([views count] != 1) {
        return nil;
    }
    
    id wb = views[0];
    return (WotaButton *)wb;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
        [self drawButton];
        [self addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(touchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        [self addTarget:self action:@selector(touchUpOutside:) forControlEvents:UIControlEventTouchDragOutside];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return self;
}

- (void)drawButton
{
    // Get the root layer (any UIView subclass comes with one)
    CALayer *layer = self.layer;
    
    layer.cornerRadius = WOTA_CORNER_RADIUS;
    layer.borderWidth = 1;
    layer.borderColor = kWotaColorOne().CGColor;
}

- (void)touchDown:(WotaButton *)sender {
    sender.backgroundColor = kWotaColorOne();
    AudioServicesPlaySystemSound(0x450);
}

- (void)touchUpInside:(WotaButton *)sender {
    sender.backgroundColor = [UIColor whiteColor];
}

- (void)touchUpOutside:(WotaButton *)sender {
    sender.backgroundColor = [UIColor whiteColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
