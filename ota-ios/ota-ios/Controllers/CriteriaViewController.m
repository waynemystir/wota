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
#import "PlaceAutoCompleteTableViewCell.h"
#import "GoogleParser.h"
#import "GooglePlace.h"
#import "GooglePlaceDetail.h"
#import "MapViewController.h"
#import "HotelListingViewController.h"
#import "THDatePickerViewController.h"
#import "ChildViewController.h"
#import "AppEnvironment.h"
#import "WotaTappableView.h"
#import <MapKit/MapKit.h>

static int const kAutoCompleteMinimumNumberOfCharacters = 3;
static double const DEFAULT_RADIUS = 5.0;
static double const METERS_PER_MILE = 1609.344;

@interface CriteriaViewController () <UITextFieldDelegate, LoadDataProtocol, UITableViewDataSource, UITableViewDelegate, THDatePickerDelegate, MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *whereToTextFieldOutlet;
@property (weak, nonatomic) IBOutlet UILabel *whereToSecondLevel;

@property (nonatomic) BOOL isAutoCompleteTableViewExpanded;

//autoComplete is NO and placeDetails is YES
@property (nonatomic) BOOL autoCompleteOrPlaceDetails;

@property (weak, nonatomic) IBOutlet WotaTappableView *mapBtnContainer;
@property (nonatomic, strong) IBOutlet UIView *cupHolderOutlet;
@property (nonatomic, strong) IBOutlet UIButton *arrivalDateOutlet;
@property (nonatomic, strong) IBOutlet UIButton *returnDateOutlet;
@property (nonatomic, strong) IBOutlet UILabel *adultsLabel;
@property (nonatomic, strong) IBOutlet UIButton *addAdultOutlet;
@property (nonatomic, strong) IBOutlet UIButton *minusAdultOutlet;
@property (nonatomic, strong) IBOutlet UIButton *checkHotelsOutlet;
@property (nonatomic, strong) IBOutlet UIButton *kidsButton;

@property (nonatomic, strong) THDatePickerViewController *arrivalDatePicker;
@property (nonatomic, strong) THDatePickerViewController *returnDatePicker;
@property BOOL arrivalOrReturn; //arrival == NO and return == YES

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, assign) BOOL nextRegionChangeIsFromUserInteraction;

- (IBAction)justPushIt:(id)sender;

@end

@implementation CriteriaViewController {
    CLLocationManager *locationManager;
    NSArray *tableData;
    UITableView *autoCompleteTableView;
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
    [super viewDidLoad];
    
    //**********************************************************************
    // This is needed so that this view controller (or it's nav controller?)
    // doesn't make room at the top of the table view's scroll view (I guess
    // to account for the nav bar).
    //***********************************************************************
    self.automaticallyAdjustsScrollViewInsets = NO;
    //***********************************************************************
    
    // setup the map view
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 600, 320, 438)];
    _mapView.delegate = self;
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        _mapView.showsUserLocation = YES;
    }
    
    [self redrawMapViewAnimated:NO radius:DEFAULT_RADIUS];
    [self.view addSubview:_mapView];
    
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
    
//    self.tableData = [NSArray arrayWithObjects:@"Albequerque", @"Saschatchawan", @"New Orleans", @"Madison", nil];
    autoCompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 106, 320, 0)];
    autoCompleteTableView.backgroundColor = [UIColor whiteColor];
    autoCompleteTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    autoCompleteTableView.separatorColor = [UIColor clearColor];
    autoCompleteTableView.dataSource = self;
    autoCompleteTableView.delegate = self;
    autoCompleteTableView.sectionHeaderHeight = 0.0f;
    [self.view addSubview:autoCompleteTableView];
    
    tableData = [SelectionCriteria singleton].placesArray;
    [autoCompleteTableView reloadData];
    
    _whereToTextFieldOutlet.delegate = self;
    _whereToTextFieldOutlet.text = @"";//[SelectionCriteria singleton].whereToFirst;
    _whereToSecondLevel.text = @"";//[SelectionCriteria singleton].whereToSecond;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResume:) name:UIApplicationWillEnterForegroundNotification object:nil];
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
//    _mapView.showsUserLocation = NO;
}

- (void)appWillResume:(NSNotification *)notification {
    if (_mapView.frame.origin.y == 130) {
        _mapView.showsUserLocation = YES;
    }
}

- (void)redrawMapViewAnimated:(BOOL)animated radius:(double)radius {
    SelectionCriteria *sc = [SelectionCriteria singleton];
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = sc.latitude;
    zoomLocation.longitude= sc.longitude;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, radius*METERS_PER_MILE, radius*METERS_PER_MILE);
    [_mapView setRegion:viewRegion animated:animated];
}

- (void)geoCodingDawg {
    [[LoadGooglePlacesData sharedInstance] loadPlaceDetailsWithLatitude:_mapView.region.center.latitude longitude:_mapView.region.center.longitude completionBlock:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [SelectionCriteria singleton].googlePlaceDetail = [GooglePlaceDetail placeDetailFromGeoCodeData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            _whereToTextFieldOutlet.text = [SelectionCriteria singleton].whereToFirst;
            _whereToSecondLevel.text = [SelectionCriteria singleton].whereToSecond;
        });
    }];
}

#pragma mark CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
        return;
    }
    
    _mapView.showsUserLocation = YES;
    
    if ([[SelectionCriteria singleton] currentLocationIsSelectedPlace]) {
        [self redrawMapViewAnimated:YES radius:DEFAULT_RADIUS];
    }
    
//    [manager startUpdatingLocation];
}

#pragma mark MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (userLocation) {
        ((WotaPlace *) [SelectionCriteria singleton].placesArray.firstObject).latitude = userLocation.location.coordinate.latitude;
        ((WotaPlace *) [SelectionCriteria singleton].placesArray.firstObject).longitude = userLocation.location.coordinate.longitude;
        
        if ([[SelectionCriteria singleton] currentLocationIsSelectedPlace]) {
            [self redrawMapViewAnimated:YES radius:DEFAULT_RADIUS];
        }
        
//        _mapView.showsUserLocation = NO;
    }
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
        [self geoCodingDawg];
    }
}

#pragma mark UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (!_isAutoCompleteTableViewExpanded) {
        [self animateTableViewExpansion];
    }
    
    _whereToTextFieldOutlet.text = @"";
    _whereToSecondLevel.text = @"";
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    _autoCompleteOrPlaceDetails = NO;
    NSString *autoCompleteText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([autoCompleteText length] >= kAutoCompleteMinimumNumberOfCharacters) {
        [[LoadGooglePlacesData sharedInstance:self] autoCompleteSomePlaces:autoCompleteText];
    } else {
        return [self textFieldShouldClear:textField];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_whereToTextFieldOutlet resignFirstResponder];
    _whereToTextFieldOutlet.text = [SelectionCriteria singleton].whereToFirst;
    _whereToSecondLevel.text = [SelectionCriteria singleton].whereToSecond;
    [self animateTableViewCompression];
    
    return [self textFieldShouldClear:textField];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (tableData != [SelectionCriteria singleton].placesArray) {
        tableData = [SelectionCriteria singleton].placesArray;
        [autoCompleteTableView reloadData];
    }
    return YES;
}

#pragma mark Various events and such

- (IBAction)justPushIt:(id)sender {
    if (sender == self.checkHotelsOutlet) {
        if ([SelectionCriteria singleton].googlePlaceDetail) {
            [[SelectionCriteria singleton] savePlace:[SelectionCriteria singleton].googlePlaceDetail];
            tableData = [SelectionCriteria singleton].placesArray;
            [autoCompleteTableView reloadData];
        }
        [self letsFindHotels];
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

#pragma mark LoadDataProtocol methods

- (void)requestStarted:(NSURL *)url {
    NSLog(@"%@.%@ loading URL:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [url absoluteString]);
}

- (void)requestFinished:(NSData *)responseData {
    if (!_autoCompleteOrPlaceDetails) {
        tableData = [GoogleParser parseAutoCompleteResponse:responseData];
        [autoCompleteTableView reloadData];
    } else {
//        [SelectionCriteria singleton].googlePlaceDetail = [GooglePlaceDetail placeDetailFromData:responseData];
        [[SelectionCriteria singleton] savePlace:[GooglePlaceDetail placeDetailFromData:responseData]];
        tableData = [SelectionCriteria singleton].placesArray;
        [autoCompleteTableView reloadData];
        _whereToTextFieldOutlet.text = [SelectionCriteria singleton].whereToFirst;
        _whereToSecondLevel.text = [SelectionCriteria singleton].whereToSecond;
        [self redrawMapViewAnimated:YES radius:DEFAULT_RADIUS];
    }
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([tableData[indexPath.row] isKindOfClass:[NSString class]]) {
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"PowerebByGoogleCell" owner:self options:nil];
        UITableViewCell *poweredByGoogleCell = views.firstObject;
        return poweredByGoogleCell;
    }
    
    NSString *CellIdentifier = @"placeAutoCompleteCell";
    PlaceAutoCompleteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"PlaceAutoCompleteTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    
    WotaPlace *place = [tableData objectAtIndex:indexPath.row];
    cell.outletPlaceName.text = place.placeName;
    cell.placeId = place.placeId;
    
    return cell;
}

#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableData[indexPath.row] isKindOfClass:[NSString class]]) {
        return;
    }
    
    PlaceAutoCompleteTableViewCell * cell = (PlaceAutoCompleteTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if ([tableData[indexPath.row] isKindOfClass:[GooglePlace class]]) {
        // TODO: I'm worried that we are setting the "where to" value here but that the
        // Google place detail values aren't set until the "loadPlaceDetails" returns.
        // The user could potentially click "Find Hotels" before the Google place details
        // are returned. So we could have two potential problems from this. First, the call
        // to LoadEanData.loadHotelsWithLatitude:longitude: could return data for the wrong
        // place. And second, we could have mismatched data in SelectionCriteria between
        // whereTo and googlePlaceDetail.
        _autoCompleteOrPlaceDetails = YES;
        [[LoadGooglePlacesData sharedInstance:self] loadPlaceDetails:cell.placeId];
        tableData = [SelectionCriteria singleton].placesArray;
        [autoCompleteTableView reloadData];
        [_whereToTextFieldOutlet resignFirstResponder];
        [self animateTableViewCompression];
    } else if ([tableData[indexPath.row] isKindOfClass:[WotaPlace class]]) {
        tableData = [SelectionCriteria singleton].placesArray;
        [autoCompleteTableView reloadData];
        [_whereToTextFieldOutlet resignFirstResponder];
        [SelectionCriteria singleton].googlePlaceDetail = nil;
        [SelectionCriteria singleton].selectedPlace = tableData[indexPath.row];
        _whereToTextFieldOutlet.text = [SelectionCriteria singleton].whereToFirst;
        _whereToSecondLevel.text = [SelectionCriteria singleton].whereToSecond;
        [self animateTableViewCompression];
        [self redrawMapViewAnimated:YES radius:DEFAULT_RADIUS];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark Some animation methods

- (void)loadOrDropDaMapView {
    __weak UIView *mv = _mapView;
    
    if (_mapView.frame.origin.y == 600) {
        
        _mapView.showsUserLocation = YES;
        
        [UIView animateWithDuration:0.6 animations:^{
            mv.frame = CGRectMake(0, 130, 320, 438);
        } completion:^(BOOL finished) {
            ;
        }];
        
    } else {
        
//        _mapView.showsUserLocation = NO;
        
        [UIView animateWithDuration:0.6 animations:^{
            mv.frame = CGRectMake(0, 600, 320, 438);
        } completion:^(BOOL finished) {
            ;
        }];
        
    }
}

- (void)animateTableViewExpansion {
    __weak UIView *actv = autoCompleteTableView;
    self.isAutoCompleteTableViewExpanded = YES;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect acp = actv.frame;
        actv.frame = CGRectMake(acp.origin.x, acp.origin.y, acp.size.width, 267.0f);
    } completion:^(BOOL finished) {
    }];
}

- (void)animateTableViewCompression {
    __weak UIView *actv = autoCompleteTableView;
    self.isAutoCompleteTableViewExpanded = NO;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect acp = actv.frame;
        actv.frame = CGRectMake(acp.origin.x, acp.origin.y, acp.size.width, 0.0f);
    } completion:^(BOOL finished) {
    }];
}

#pragma mark Various Date Picker methods

- (void)presentTheDatePicker {
    
    THDatePickerViewController *dp = nil;
    
    if (!_arrivalOrReturn) {
        [self setupTheArrivalDatePicker];
        dp = _arrivalDatePicker;
        dp.date = [SelectionCriteria singleton].arrivalDate;
        dp.minDate = [NSDate date];
        dp.maxDate = kAddDays(500, [NSDate date]);
    } else {
        [self setupTheReturnDatePicker];
        dp = _returnDatePicker;
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
    if(_arrivalDatePicker)
        return;
    
    _arrivalDatePicker = [THDatePickerViewController datePicker];
    _arrivalDatePicker.delegate = self;
    [_arrivalDatePicker setAllowClearDate:NO];
    [_arrivalDatePicker setClearAsToday:NO];
    [_arrivalDatePicker setAutoCloseOnSelectDate:YES];
    [_arrivalDatePicker setAllowSelectionOfSelectedDate:YES];
    [_arrivalDatePicker setDisableHistorySelection:YES];
    [_arrivalDatePicker setDisableFutureSelection:NO];
    [_arrivalDatePicker setSelectedBackgroundColor:kWotaColorOne()];
    [_arrivalDatePicker setCurrentDateColor:kWotaColorOne()];
    
    _arrivalDatePicker.arrivalOrDepartureString = @"Check-in Date";
    [_arrivalDatePicker setDateHasItemsCallback:nil];
}

- (void)setupTheReturnDatePicker {
    if(_returnDatePicker)
        return;
    
    _returnDatePicker = [THDatePickerViewController datePicker];
    _returnDatePicker.delegate = self;
    [_returnDatePicker setAllowClearDate:NO];
    [_returnDatePicker setClearAsToday:NO];
    [_returnDatePicker setAutoCloseOnSelectDate:YES];
    [_returnDatePicker setAllowSelectionOfSelectedDate:YES];
    [_returnDatePicker setDisableHistorySelection:YES];
    [_returnDatePicker setDisableFutureSelection:NO];
    [_returnDatePicker setSelectedBackgroundColor:kWotaColorOne()];
    [_returnDatePicker setCurrentDateColor:kWotaColorOne()];
    
    _returnDatePicker.arrivalOrDepartureString = @"Check-out Date";
    [_returnDatePicker setDateHasItemsCallback:nil];
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
