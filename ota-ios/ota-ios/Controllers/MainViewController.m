//
//  ViewController.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/24/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "MainViewController.h"
#import "CriteriaViewController.h"

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UIButton *locationButtonOutlet;

- (IBAction)justPushIt:(id)sender;

@end

@implementation MainViewController

- (id)init {
    self = [super initWithNibName:@"MainView" bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (IBAction)justPushIt:(id)sender {
    if (sender == self.locationButtonOutlet) {
        [self letsLocate];
    }
}

- (void)letsLocate {
    CriteriaViewController *lvc = [CriteriaViewController new];
    [self.navigationController pushViewController:lvc animated:YES];
}

@end
