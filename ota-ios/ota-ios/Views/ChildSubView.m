//
//  ChildSubView.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/29/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "ChildSubView.h"

@implementation ChildSubView

/****************************************************************
* I love this: https://www.youtube.com/watch?v=xP7YvdlnHfA
* The video explains how to setup this custom view to be used
* by another nib in Interface Builder... rather handy
*****************************************************************/

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        // 1. Load the interface from the .xib
        [[NSBundle mainBundle] loadNibNamed:@"ChildSubView" owner:self options:nil];
        
        // 2. Add as a subview
        [self addSubview:self.theViewOutlet];
    }
    return self;
}

- (IBAction)justPushIt:(id)sender {
}

@end
