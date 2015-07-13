//
//  BookViewController.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/28/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "BookViewController.h"
#import "EanHotelRoomReservationResponse.h"
#import "NavigationView.h"

@interface BookViewController () <NavigationDelegate>

@property (weak, nonatomic) IBOutlet UILabel *itineraryOutlet;

@end

@implementation BookViewController

- (id)init {
    self = [super initWithNibName:@"BookView" bundle:nil];
    return  self;
}

- (void)loadView {
    [super loadView];
    NavigationView *nv = [[NavigationView alloc] initWithDelegate:self];
    [self.view addSubview:nv];
    [self.view bringSubviewToFront:nv];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

#pragma mark LoadDataProtocol methods

- (void)requestStarted:(NSURLConnection *)connection {
    NSLog(@"%@.%@.:::%@", self.class, NSStringFromSelector(_cmd), [[[connection currentRequest] URL] absoluteString]);
}

- (void)requestFinished:(NSData *)responseData dataType:(LOAD_DATA_TYPE)dataType {
    
    if (dataType != LOAD_EAN_BOOK) {
        return;
    }
    
    NSString *respString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    EanHotelRoomReservationResponse *hrrr = [EanHotelRoomReservationResponse eanObjectFromApiResponseData:responseData];
    self.itineraryOutlet.text = [NSString stringWithFormat:@"Itin:%ld", (long)hrrr.itineraryId];
    NSLog(@"%@.%@:::%@", self.class, NSStringFromSelector(_cmd), respString);
}

#pragma mark NavigationDelegate methods

- (void)clickBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickTitle {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
