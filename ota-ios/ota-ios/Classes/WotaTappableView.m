//
//  WotaTappableView.m
//  ota-ios
//
//  Created by WAYNE SMALL on 5/4/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "WotaTappableView.h"
#import "AppEnvironment.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation WotaTappableView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupThisView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupThisView];
    }
    return self;
}

- (void)setupThisView {
    _tapColor = _borderColor = kWotaColorOne();
    self.layer.borderColor = kWotaColorOne().CGColor;
    self.layer.borderWidth = 1.0f;
    self.layer.cornerRadius = WOTA_CORNER_RADIUS;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    AudioServicesPlaySystemSound(0x450);
    self.backgroundColor = _tapColor;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.backgroundColor = _untapColor;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.backgroundColor = _tapColor;
}

- (void)setBorderColor:(UIColor *)borderColor {
    self.layer.borderColor = borderColor.CGColor;
    _borderColor = borderColor;
}

@end
