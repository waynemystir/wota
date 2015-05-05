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

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _tapColor = kWotaColorOne();
    }
    return self;
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

@end
