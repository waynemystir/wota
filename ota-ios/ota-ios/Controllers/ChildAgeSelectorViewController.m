//
//  ChildAgeSelectorViewController.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/30/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "ChildAgeSelectorViewController.h"

@interface ChildAgeSelectorViewController ()

@end

@implementation ChildAgeSelectorViewController

- (void)viewWillAppear:(BOOL)animated {
    self.view.frame = CGRectMake(0, 0, 320, 320);
    self.view.backgroundColor = [UIColor redColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, 100, 40)];
    lbl.text = @"picker view here";
    lbl.textColor = [UIColor whiteColor];
    lbl.backgroundColor = [UIColor blackColor];
    [self.view addSubview:lbl];
}

@end
