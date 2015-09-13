//
//  BookViewController.h
//  ota-ios
//
//  Created by WAYNE SMALL on 3/28/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadDataProtocol.h"

@interface BookViewController : UIViewController <LoadDataProtocol>

@property (nonatomic, strong) NSUUID *affiliateConfirmationId;

@end
