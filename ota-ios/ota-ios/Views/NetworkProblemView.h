//
//  NetworkProblemView.h
//  ota-ios
//
//  Created by WAYNE SMALL on 7/12/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NetworkProblemView : UIView

@property (nonatomic, copy) void (^completionCallback) ();

@end
