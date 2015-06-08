//
//  GoogleMarkerView.m
//  ota-ios
//
//  Created by WAYNE SMALL on 6/8/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "GoogleMarkerView.h"

@implementation GoogleMarkerView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _nameLabel = [[UILabel alloc] initWithFrame:frame];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.textColor = [UIColor blackColor];
        [self addSubview:_nameLabel];
    }
    return self;
}

@end
