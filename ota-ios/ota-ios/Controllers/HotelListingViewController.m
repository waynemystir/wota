//
//  HotelListingViewController.m
//  ean-ota-ios
//
//  Created by WAYNE SMALL on 3/21/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "HotelListingViewController.h"
#import "EanHotelListResponse.h"
#import "EanHotelListHotelSummary.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "HotelInfoViewController.h"
#import "LoadEanData.h"
#import "AppEnvironment.h"
#import "AppDelegate.h"
#import "SelectionCriteria.h"
#import "ChildTraveler.h"
#import "NavigationView.h"
#import "HLTableViewCell.h"

@interface HotelListingViewController () <UITableViewDataSource, UITableViewDelegate, NavigationDelegate>

@property (nonatomic) BOOL alreadyDroppedSpinner;
@property (weak, nonatomic) IBOutlet UITableView *tableViewHotelList;
@property (nonatomic, strong) NSArray *hotelData;
@property (nonatomic, strong) EanHotelListHotelSummary *selectedHotel;

@end

@implementation HotelListingViewController

- (id)init {
    self = [super initWithNibName:@"HotelListingView" bundle:nil];
    return self;
}

- (void)loadView {
    [super loadView];
    
    NavigationView *nv = [[NavigationView alloc] initWithDelegate:self];
    [self.view addSubview:nv];
    
    AppDelegate *ad = [[UIApplication sharedApplication] delegate];
    [ad loadDaSpinner];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //**********************************************************************
    // This is needed so that this view controller (or it's nav controller?)
    // doesn't make room at the top of the table view's scroll view (I guess
    // to account for the nav bar).
    //***********************************************************************
    self.automaticallyAdjustsScrollViewInsets = NO;
    //***********************************************************************
    
    self.tableViewHotelList.dataSource = self;
    self.tableViewHotelList.delegate = self;
//    [self.tableViewHotelList registerNib:[UINib nibWithNibName:@"HotelListingTableViewCell" bundle:nil] forCellReuseIdentifier:@"hlTblViewCell"];
//    [self.tableViewHotelList registerClass:[HotelTableViewCell class] forCellReuseIdentifier:@"hotelListCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)dropDaSpinnerAlready {
    if (_alreadyDroppedSpinner) {
        return;
    }
    _alreadyDroppedSpinner = YES;
    
    AppDelegate *ad = [[UIApplication sharedApplication] delegate];
    [ad dropDaSpinnerAlready];
}

#pragma mark NavigationDelegate methods

- (void)clickBack {
    [self dropDaSpinnerAlready];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickTitle {
    
}

#pragma mark LoadDataProtocol methods

- (void)requestStarted:(NSURL *)url {
    NSLog(@"%@.%@ finding hotels with URL:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [url absoluteString]);
}

- (void)requestFinished:(NSData *)responseData {
    NSArray *hotelList = [EanHotelListResponse eanObjectFromApiResponseData:responseData].hotelList;
    
    if (hotelList != nil) {
        self.hotelData = hotelList;
        [self.tableViewHotelList reloadData];
    }
    
    [self dropDaSpinnerAlready];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.hotelData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"CellIdentifier";
    EanHotelListHotelSummary *hotel = [EanHotelListHotelSummary hotelFromObject:[self.hotelData objectAtIndex:indexPath.row]];
    HLTableViewCell *cell = [[HLTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier hotelRating:hotel.hotelRating];
    
    NSString *imageUrlString = [@"http://images.travelnow.com" stringByAppendingString:hotel.thumbNailUrlEnhanced];
    [cell.thumbImageView setImageWithURL:[NSURL URLWithString:imageUrlString] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        // TODO: placeholder image
        // TODO: if nothing comes back, replace hotel.thumbNailUrlEnhanced with hotel.thumbNailUrl and try again
        ;
    }];
    
    cell.hotelNameLabel.text = hotel.hotelNameFormatted;
    NSNumberFormatter *pf = kPriceRoundOffFormatter(hotel.rateCurrencyCode);
    cell.roomRateLabel.text = [pf stringFromNumber:hotel.lowRate];//[NSNumber numberWithLong:3339993339]
    cell.cityLabel.text = hotel.city;
    
    return cell;
}

#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 96.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EanHotelListHotelSummary *hotel = [EanHotelListHotelSummary hotelFromObject:[self.hotelData objectAtIndex:indexPath.row]];
    HotelInfoViewController *hvc = [[HotelInfoViewController alloc] initWithHotel:hotel];
    [[LoadEanData sharedInstance:hvc] loadHotelDetailsWithId:[hotel.hotelId stringValue]];
    [self.navigationController pushViewController:hvc animated:YES];
}

@end
