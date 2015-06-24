//
//  CriteriaViewController.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/24/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "CriteriaViewController.h"
#import "SelectionCriteria.h"
#import "ChildTraveler.h"
#import "LoadGooglePlacesData.h"
#import "MapViewController.h"
#import "HotelListingViewController.h"
#import "THDatePickerViewController.h"
#import "ChildViewController.h"
#import "AppEnvironment.h"
#import "WotaTappableView.h"
#import <MapKit/MapKit.h>

static double const METERS_PER_MILE = 1609.344;

@interface CriteriaViewController () <THDatePickerDelegate, MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet WotaTappableView *mapBtnContainer;
@property (nonatomic, weak) IBOutlet UIView *cupHolderOutlet;
@property (nonatomic, weak) IBOutlet UIButton *arrivalDateOutlet;
@property (nonatomic, weak) IBOutlet UIButton *returnDateOutlet;
@property (nonatomic, weak) IBOutlet UILabel *adultsLabel;
@property (nonatomic, weak) IBOutlet UIButton *addAdultOutlet;
@property (nonatomic, weak) IBOutlet UIButton *minusAdultOutlet;
@property (nonatomic, weak) IBOutlet UIButton *checkHotelsOutlet;
@property (nonatomic, weak) IBOutlet UIButton *kidsButton;

@property (nonatomic) BOOL userLocationHasUpdated;
@property (nonatomic) BOOL arrivalOrReturn; //arrival == NO and return == YES
@property (nonatomic, assign) BOOL nextRegionChangeIsFromUserInteraction;

- (IBAction)justPushIt:(id)sender;

@end

@implementation CriteriaViewController {
    CLLocationManager *locationManager;
    MKMapView *mkMapView;
    THDatePickerViewController *arrivalDatePicker;
    THDatePickerViewController *returnDatePicker;
}

#pragma mark Lifecycle methods

- (id)init {
    if (self = [super initWithNibName:@"CriteriaView" bundle:nil]) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        locationManager.delegate = self;
        
        if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
            [locationManager requestWhenInUseAuthorization];
        }
    }
    return self;
}

- (void)viewDidLoad {
    //**********************************************************************
    // This is needed so that this view controller (or it's nav controller?)
    // doesn't make room at the top of the table view's scroll view (I guess
    // to account for the nav bar).
    //***********************************************************************
    self.automaticallyAdjustsScrollViewInsets = NO;
    //***********************************************************************
    
    // setup the map view
    mkMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 600, 320, 438)];
    mkMapView.delegate = self;
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        mkMapView.showsUserLocation = YES;
    }
    
    [self redrawMapViewAnimated:NO radius:DEFAULT_RADIUS];
    [self.view addSubview:mkMapView];
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadOrDropDaMapView)];
    tgr.numberOfTapsRequired = 1;
    tgr.numberOfTouchesRequired = 1;
    _mapBtnContainer.userInteractionEnabled = YES;
    [_mapBtnContainer addGestureRecognizer:tgr];
    
    [self setNumberOfAdultsLabel:0];
    [self setNumberOfKidsButtonLabel];
    
    self.arrivalOrReturn = NO;
    [self refreshDisplayedReturnDate];
    [self refreshDisplayedArrivalDate];
    
    self.placesTableViewZeroFrame = CGRectMake(0, 106, 320, 0);
    self.placesTableViewExpandedFrame = CGRectMake(0, 106, 320, 247);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResume:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark Various map methods

- (void)appWillResignActive:(NSNotification *)notification {
//    mapView.showsUserLocation = NO;
}

- (void)appWillResume:(NSNotification *)notification {
    if (mkMapView.frame.origin.y == 130) {
        mkMapView.showsUserLocation = YES;
    }
}

- (void)redrawMapViewAnimated:(BOOL)animated radius:(double)radius {
    SelectionCriteria *sc = [SelectionCriteria singleton];
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = sc.latitude;
    zoomLocation.longitude= sc.longitude;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, radius*METERS_PER_MILE, radius*METERS_PER_MILE);
    [mkMapView setRegion:viewRegion animated:animated];
}

- (void)reverseGeoCodingDawg {
    [[LoadGooglePlacesData sharedInstance] loadPlaceDetailsWithLatitude:mkMapView.region.center.latitude longitude:mkMapView.region.center.longitude completionBlock:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [SelectionCriteria singleton].googlePlaceDetail = [GooglePlaceDetail placeDetailFromGeoCodeData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.whereToTextField.text = [SelectionCriteria singleton].whereToFirst;
            self.whereToSecondLevel.text = [SelectionCriteria singleton].whereToSecond;
        });
    }];
}

#pragma mark CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
        mkMapView.showsUserLocation = NO;
    } else {
        mkMapView.showsUserLocation = YES;
    }
    
//    [manager startUpdatingLocation];
}

#pragma mark MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (userLocation) {
        ((WotaPlace *) [SelectionCriteria singleton].placesArray.firstObject).latitude = userLocation.location.coordinate.latitude;
        ((WotaPlace *) [SelectionCriteria singleton].placesArray.firstObject).longitude = userLocation.location.coordinate.longitude;
        
        if (!_userLocationHasUpdated && [[SelectionCriteria singleton] currentLocationIsSelectedPlace] && ![SelectionCriteria singleton].googlePlaceDetail) {
            [self redrawMapViewAnimated:YES radius:DEFAULT_RADIUS];
        }
        
//        mapView.showsUserLocation = NO;
    }
    
    _userLocationHasUpdated = YES;
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    UIView* view = mapView.subviews.firstObject;
    
    // Curtesy of http://b2cloud.com.au/tutorial/mkmapview-determining-whether-region-change-is-from-user-interaction/
    //	Look through gesture recognizers to determine
    //	whether this region change is from user interaction
    for(UIGestureRecognizer* recognizer in view.gestureRecognizers) {
        //	The user caused of this...
        if(recognizer.state == UIGestureRecognizerStateBegan
           || recognizer.state == UIGestureRecognizerStateEnded) {
            _nextRegionChangeIsFromUserInteraction = YES;
            break;
        }
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if(_nextRegionChangeIsFromUserInteraction) {
        _nextRegionChangeIsFromUserInteraction = NO;
        [self reverseGeoCodingDawg];
    }
}

#pragma mark Various events and such

- (IBAction)justPushIt:(id)sender {
    if (sender == self.checkHotelsOutlet) {
        [self letsFindHotels];
        if ([SelectionCriteria singleton].googlePlaceDetail) {
            [[SelectionCriteria singleton] savePlace:[SelectionCriteria singleton].googlePlaceDetail];
        }
        self.placesTableData = [SelectionCriteria singleton].placesArray;
        [self.placesTableView reloadData];
    } else if (sender == self.arrivalDateOutlet) {
        self.arrivalOrReturn = NO;
        [self presentTheDatePicker];
    } else if (sender == self.returnDateOutlet) {
        self.arrivalOrReturn = YES;
        [self presentTheDatePicker];
    } else if (sender == self.minusAdultOutlet) {
        [self setNumberOfAdultsLabel:-1];
    } else if (sender == self.addAdultOutlet) {
        [self setNumberOfAdultsLabel:1];
    } else if (sender == self.kidsButton) {
        [self presentKidsSelector];
    } else {
        NSLog(@"Dude we've got a problem");
    }
}

- (void)letsFindHotels {
    SelectionCriteria *sc = [SelectionCriteria singleton];
    
    HotelListingViewController *hvc = [HotelListingViewController new];
    [[LoadEanData sharedInstance:hvc] loadHotelsWithLatitude:sc.latitude
                                                   longitude:sc.longitude
                                                 arrivalDate:sc.arrivalDateEanString
                                                  returnDate:sc.returnDateEanString
                                                searchRadius:@15];
    
    [self.navigationController pushViewController:hvc animated:YES];
}

- (void)setNumberOfAdultsLabel:(NSInteger)change {
    SelectionCriteria *sc = [SelectionCriteria singleton];
    
    if (sc.numberOfAdults > 1 || change > 0) {
        sc.numberOfAdults += change;
    }
    
    if (sc.numberOfAdults <= 1) {
        _minusAdultOutlet.enabled = NO;
    } else if (sc.numberOfAdults > 1) {
        _minusAdultOutlet.enabled = YES;
    }
    
    if (sc.numberOfAdults > 10) {
        // TODO: disable add button
    }
    
    NSString *plural = sc.numberOfAdults == 1 ? @"" : @"s";
    _adultsLabel.text = [NSString stringWithFormat:@"%lu Adult%@", (unsigned long)sc.numberOfAdults, plural];
}

- (void)presentKidsSelector {
    ChildViewController *kids = [ChildViewController new];
    [self presentSemiViewController:kids withOptions:@{
                                                       KNSemiModalOptionKeys.pushParentBack    : @(NO),
                                                       KNSemiModalOptionKeys.animationDuration : @(0.4),
                                                       KNSemiModalOptionKeys.shadowOpacity     : @(0.3),
                                                       } completion:^{
                                                           NSLog(@"");
                                                       } dismissBlock:^{
                                                           NSLog(@"");
                                                           [self setNumberOfKidsButtonLabel];
                                                       }];
}

- (void)setNumberOfKidsButtonLabel {
    NSUInteger numberOfKids = [ChildTraveler numberOfKids];
    NSString *plural = numberOfKids == 1 ? @"Child" : @"Children";
    id numbKids = numberOfKids == 0 ? @"Add" : [NSString stringWithFormat:@"%lu", (unsigned long) numberOfKids];
    NSString *buttonText = [NSString stringWithFormat:@"%@ %@", numbKids, plural];
    [self.kidsButton setTitle:buttonText forState:UIControlStateNormal];
}

#pragma mark Some animation methods

- (void)loadOrDropDaMapView {
    if (self.isPlacesTableViewExpanded) {
        
        [self.whereToTextField endEditing:YES];
        [self animateTableViewCompression];
        [self loadMapView];
        
    } else if (mkMapView.frame.origin.y == 600) {
        
        [self loadMapView];
        
    } else {
        
        [self dropMapView];
        
    }
}

- (void)loadMapView {
    if (self.placesTableData != [SelectionCriteria singleton].placesArray) {
        self.placesTableData = [SelectionCriteria singleton].placesArray;
        [self.placesTableView reloadData];
    }
    self.whereToTextField.text = [SelectionCriteria singleton].whereToFirst;
    self.whereToSecondLevel.text = [SelectionCriteria singleton].whereToSecond;
    __weak UIView *mv = mkMapView;
    [UIView animateWithDuration:0.6 animations:^{
        mv.frame = CGRectMake(0, 130, 320, 438);
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)dropMapView {
    __weak UIView *mv = mkMapView;
    [UIView animateWithDuration:0.6 animations:^{
        mv.frame = CGRectMake(0, 600, 320, 438);
    } completion:^(BOOL finished) {
        ;
    }];
}

#pragma mark Various Date Picker methods

- (void)presentTheDatePicker {
    
    THDatePickerViewController *dp = nil;
    
    if (!_arrivalOrReturn) {
        [self setupTheArrivalDatePicker];
        dp = arrivalDatePicker;
        dp.date = [SelectionCriteria singleton].arrivalDate;
        dp.minDate = [NSDate date];
        dp.maxDate = kAddDays(500, [NSDate date]);
    } else {
        [self setupTheReturnDatePicker];
        dp = returnDatePicker;
        dp.date = [SelectionCriteria singleton].returnDate;
        dp.minDate = kAddDays(1, [SelectionCriteria singleton].arrivalDate);
        dp.maxDate = kAddDays(28, [SelectionCriteria singleton].arrivalDate);
    }
    
    [dp forceRedraw];
    
    [self presentSemiViewController:dp withOptions:@{
                                                     KNSemiModalOptionKeys.pushParentBack    : @(NO),
                                                     KNSemiModalOptionKeys.animationDuration : @(0.4),
                                                     KNSemiModalOptionKeys.shadowOpacity     : @(0.3),
                                                     }];
}

- (void)setupTheArrivalDatePicker {
    if(arrivalDatePicker)
        return;
    
    arrivalDatePicker = [THDatePickerViewController datePicker];
    arrivalDatePicker.delegate = self;
    [arrivalDatePicker setAllowClearDate:NO];
    [arrivalDatePicker setClearAsToday:NO];
    [arrivalDatePicker setAutoCloseOnSelectDate:YES];
    [arrivalDatePicker setAllowSelectionOfSelectedDate:YES];
    [arrivalDatePicker setDisableHistorySelection:YES];
    [arrivalDatePicker setDisableFutureSelection:NO];
    [arrivalDatePicker setSelectedBackgroundColor:kWotaColorOne()];
    [arrivalDatePicker setCurrentDateColor:kWotaColorOne()];
    
    arrivalDatePicker.arrivalOrDepartureString = @"Check-in Date";
    [arrivalDatePicker setDateHasItemsCallback:nil];
}

- (void)setupTheReturnDatePicker {
    if(returnDatePicker)
        return;
    
    returnDatePicker = [THDatePickerViewController datePicker];
    returnDatePicker.delegate = self;
    [returnDatePicker setAllowClearDate:NO];
    [returnDatePicker setClearAsToday:NO];
    [returnDatePicker setAutoCloseOnSelectDate:YES];
    [returnDatePicker setAllowSelectionOfSelectedDate:YES];
    [returnDatePicker setDisableHistorySelection:YES];
    [returnDatePicker setDisableFutureSelection:NO];
    [returnDatePicker setSelectedBackgroundColor:kWotaColorOne()];
    [returnDatePicker setCurrentDateColor:kWotaColorOne()];
    
    returnDatePicker.arrivalOrDepartureString = @"Check-out Date";
    [returnDatePicker setDateHasItemsCallback:nil];
}



-(void)refreshDisplayedArrivalDate {
    SelectionCriteria *sc = [SelectionCriteria singleton];
    if (sc.arrivalDate == nil) {
        sc.arrivalDate = kAddDays(3, [NSDate date]);
    }
    
    [_arrivalDateOutlet setTitle:[kPrettyDateFormatter() stringFromDate:sc.arrivalDate] forState:UIControlStateNormal];
    
    NSDate *arrivalDatePlus28 = kAddDays(28, sc.arrivalDate);
    
    if (nil == sc.returnDate
            || [sc.arrivalDate compare:sc.returnDate] == NSOrderedDescending
            || [sc.arrivalDate compare:sc.returnDate] == NSOrderedSame
            || [sc.returnDate compare:arrivalDatePlus28] == NSOrderedDescending) {
        sc.returnDate = kAddDays(1, sc.arrivalDate);
        [self refreshDisplayedReturnDate];
    }
}

-(void)refreshDisplayedReturnDate {
    SelectionCriteria *sc = [SelectionCriteria singleton];
    if (sc.returnDate == nil) {
        sc.returnDate = kAddDays(3, sc.arrivalDate);
    }
    
    [_returnDateOutlet setTitle:[kPrettyDateFormatter() stringFromDate:sc.returnDate] forState:UIControlStateNormal];
}

#pragma mark THDatePickerDelegate methods

- (void)datePickerDonePressed:(THDatePickerViewController *)datePicker {
    if (!_arrivalOrReturn) {
        [SelectionCriteria singleton].arrivalDate = datePicker.date;
        [self refreshDisplayedArrivalDate];
    } else {
        [SelectionCriteria singleton].returnDate = datePicker.date;
        [self refreshDisplayedReturnDate];
    }
    
    //[self.datePicker slideDownAndOut];
    [self dismissSemiModalView];
}

- (void)datePickerCancelPressed:(THDatePickerViewController *)datePicker {
    //[self.datePicker slideDownAndOut];
    [self dismissSemiModalView];
}

- (void)datePicker:(THDatePickerViewController *)datePicker selectedDate:(NSDate *)selectedDate {
    NSLog(@"Date selected: %@",[kPrettyDateFormatter() stringFromDate:selectedDate]);
}

@end
