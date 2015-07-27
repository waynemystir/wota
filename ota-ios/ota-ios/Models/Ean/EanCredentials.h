//
//  EanCredentials.h
//  ota-ios
//
//  Created by WAYNE SMALL on 7/20/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <UIKit/UIKit.h>

/******
 * The bulk of this class really belongs on a server.
 *
 * The purpose of this class to provide a fully enabled set of credentials. As
 * EAN can disable credentials, this class iterates through credential sets to
 * find an enabled set of credentials and exposes the enabled CID, apiKey, and
 * sharedSecret. The iteration is fired off when the Objective-C runtime is
 * fired up, via this class' load method.
 *****/

@interface EanCredentials : NSObject

+ (void)waitForEnabledCredentialIterations:(void (^)(BOOL success))completionHandler;
+ (NSString *)CID;
+ (NSString *)apiKey;
+ (NSString *)sharedSecret;

@end
