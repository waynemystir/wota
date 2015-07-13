//
//  NetworkProblemResponder.h
//  ota-ios
//
//  Created by WAYNE SMALL on 7/11/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NetworkProblemResponder : NSObject

+ (void)launchWithSuperView:(UIView *)superView
                headerTitle:(NSString *)headerTitle
              messageString:(NSString *)messageString
         completionCallback:(void (^)(void))completionCallback;

@end
