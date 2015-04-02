//
//  SelectRoomViewController.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/28/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "SelectRoomViewController.h"

@interface SelectRoomViewController ()

@end

@implementation SelectRoomViewController

- (id)init {
    self = [super initWithNibName:@"SelectRoomView" bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)requestFinished:(NSData *)responseData {
    NSLog(@"availresponse: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
}

@end
