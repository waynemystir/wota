//
//  IpAddress.h
//  ota-ios
//
//  Created by WAYNE SMALL on 9/30/15.
//  Copyright © 2015 Trotter Travel LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IpAddress : NSObject

extern BOOL isValidIPv4_alt1(NSString *ipAdd);
extern BOOL isValidIPv4_alt2(NSString *ipAdd);
extern BOOL isValidIPv4_alt3(NSString *ipAdd);
extern BOOL isValidIPAddress(NSString *ipAdd);

@end
