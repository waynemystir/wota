//
//  AppDelegate.h
//  ota-ios
//
//  Created by WAYNE SMALL on 3/24/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)loadDaSpinner;
- (void)dropDaSpinnerAlreadyWithForce:(BOOL)force;

+ (NSString *)externalIP;

@end

