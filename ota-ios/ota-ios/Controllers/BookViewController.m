//
//  BookViewController.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/28/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "BookViewController.h"
#import "EanHotelRoomReservationResponse.h"

@interface BookViewController ()

@end

@implementation BookViewController

- (id)init {
    self = [super initWithNibName:@"BookView" bundle:nil];
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)requestStarted:(NSURL *)url {
    NSLog(@"%@.%@.:::%@", self.class, NSStringFromSelector(_cmd), url);
}

- (void)requestFinished:(NSData *)responseData {
    NSString *respString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    EanHotelRoomReservationResponse *hrrr = [EanHotelRoomReservationResponse roomReservationFromData:responseData];
    NSLog(@"%@.%@:::%@", self.class, NSStringFromSelector(_cmd), respString);
}

@end
