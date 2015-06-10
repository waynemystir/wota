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
#import <MapKit/MapKit.h>

#define METERS_PER_MILE 1609.344

NSTimeInterval const kFlipAnimationDuration = 0.7;

@interface HotelListingViewController () <UITableViewDataSource, UITableViewDelegate, NavigationDelegate>

@property (nonatomic) BOOL alreadyDroppedSpinner;
@property (strong, nonatomic) UITableView *hotelsTableView;
@property (nonatomic, strong) NSArray *hotelData;
@property (weak, nonatomic) IBOutlet UIImageView *wmapImageView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) MKMapView *mkMapView;

@end

@implementation HotelListingViewController {
    
    BOOL tableOrMap;
}

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
    
    _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, 320, 459)];
    _containerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_containerView];
    
    _mkMapView = [[MKMapView alloc] initWithFrame:_containerView.bounds];
    SelectionCriteria *sc = [SelectionCriteria singleton];
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = sc.googlePlaceDetail.latitude;
    zoomLocation.longitude= sc.googlePlaceDetail.longitude;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 2.5*METERS_PER_MILE, 2.5*METERS_PER_MILE);
    [_mkMapView setRegion:viewRegion];
    [_containerView addSubview:_mkMapView];
    
    _hotelsTableView = [[UITableView alloc] initWithFrame:_containerView.bounds];
    _hotelsTableView.dataSource = self;
    _hotelsTableView.delegate = self;
    _hotelsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _hotelsTableView.separatorColor = [UIColor clearColor];
    [_containerView addSubview:_hotelsTableView];
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(transitionBetweenTableAndMap)];
    tgr.numberOfTapsRequired = 1;
    tgr.numberOfTouchesRequired = 1;
    _wmapImageView.userInteractionEnabled = YES;
    [_wmapImageView addGestureRecognizer:tgr];
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

#pragma mark flipping animation

- (void)transitionBetweenTableAndMap {
    if (tableOrMap) {
        [UIView transitionFromView:_mkMapView
                            toView:_hotelsTableView
                          duration:0.8
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        completion:^(BOOL finished) {
                            tableOrMap = NO;
                        }];
    } else {
        [UIView transitionFromView:_hotelsTableView
                            toView:_mkMapView
                          duration:0.8
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        completion:^(BOOL finished) {
                            tableOrMap = YES;
                        }];
    }
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
        [self.hotelsTableView reloadData];
    }
    
    [self dropDaSpinnerAlready];
    
    for (int j = 0; j < [_hotelData count]; j++) {
        EanHotelListHotelSummary *hotel = [EanHotelListHotelSummary hotelFromObject:[self.hotelData objectAtIndex:j]];
        MKPointAnnotation *newAnnotation = [[MKPointAnnotation alloc] init];
        newAnnotation.coordinate = CLLocationCoordinate2DMake(hotel.latitude, hotel.longitude);
        newAnnotation.title = hotel.hotelName;
        [_mkMapView addAnnotation:newAnnotation];
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
