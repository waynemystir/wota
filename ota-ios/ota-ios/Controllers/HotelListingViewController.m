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
#import "HotelTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "HotelInfoViewController.h"
#import "LoadEanData.h"
#import "AppEnvironment.h"
#import "SelectionCriteria.h"
#import "ChildTraveler.h"
#import "NavigationView.h"

@interface HotelListingViewController () <UITableViewDataSource, UITableViewDelegate, NavigationDelegate>

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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

#pragma mark NavigationDelegate methods

- (void)clickBack {
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
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.hotelData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"hotelListCell";
    HotelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"HotelTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    
    EanHotelListHotelSummary *hotel = [EanHotelListHotelSummary hotelFromObject:[self.hotelData objectAtIndex:indexPath.row]];
    NSString *imageUrlString = [@"http://images.travelnow.com" stringByAppendingString:hotel.thumbNailUrl];    
//    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    //this will start the image loading in bg
//    dispatch_async(concurrentQueue, ^{
//        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: imageUrlString]];
//        
//        //this will set the image when loading is finished
//        dispatch_async(dispatch_get_main_queue(), ^{
//            cell.thumbImageViewOutlet.image = [UIImage imageWithData:imageData];
//        });
//    });
    
    [cell.thumbImageViewOutlet setImageWithURL:[NSURL URLWithString:imageUrlString]];
    
    cell.hotelId = hotel.hotelId;
    cell.latitude = hotel.latitude;
    cell.longitude = hotel.longitude;
    cell.hotelNameLabelOutlet.text = hotel.hotelName;
    NSNumberFormatter *pf = kPriceRoundOffFormatter(hotel.rateCurrencyCode);
    cell.roomRateLabelOutlet.text = [pf stringFromNumber:hotel.lowRate];
    cell.highRateOutlet.text = [pf stringFromNumber:hotel.highRate];
    cell.tripAdvisorRatingLabelOutlet.text = [hotel.tripAdvisorRating stringValue];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UILabel *sd = [[UILabel alloc] initWithFrame:CGRectMake(340, 10, 180, 75)];
        sd.lineBreakMode = NSLineBreakByWordWrapping;
        sd.numberOfLines = 3;
        sd.text = hotel.shortDescription;
        [cell addSubview:sd];
    }
    
    return cell;
}

#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 96.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HotelTableViewCell *cell = (HotelTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    EanHotelListHotelSummary *hotel = [EanHotelListHotelSummary hotelFromObject:[self.hotelData objectAtIndex:indexPath.row]];
    HotelInfoViewController *hvc = [[HotelInfoViewController alloc] initWithHotel:hotel];
    [[LoadEanData sharedInstance:hvc] loadHotelDetailsWithId:cell.hotelId];
    [self.navigationController pushViewController:hvc animated:YES];
}

@end
