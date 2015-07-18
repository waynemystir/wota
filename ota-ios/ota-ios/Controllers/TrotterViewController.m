//
//  TrotterViewController.m
//  ota-ios
//
//  Created by WAYNE SMALL on 7/17/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "TrotterViewController.h"
#import "LoadGooglePlacesData.h"
#import "LoadEanData.h"
#import <MapKit/MapKit.h>
#import "AppEnvironment.h"
#import "AppDelegate.h"
#import "SelectionCriteria.h"
#import "GoogleParser.h"
#import "NetworkProblemResponder.h"
#import "PlaceAutoCompleteTableViewCell.h"
#import "GooglePlace.h"
#import "THDatePickerViewController.h"
#import "WotaButton.h"
#import "WotaTappableView.h"
#import "ChildViewController.h"
#import "HotelsTableViewDelegateImplementation.h"
#import "EanHotelListResponse.h"
#import "EanHotelListHotelSummary.h"
#import "WotaMapAnnotatioin.h"
#import "BackCancelView.h"

typedef NS_ENUM(NSUInteger, VIEW_STATE) {
    VIEW_STATE_PRE_HOTEL,
    VIEW_STATE_HOTELS,
    VIEW_STATE_MAP
};

static int const kTrvAutoCompleteMinimumNumberOfCharacters = 4;
double const TRV_DEFAULT_RADIUS = 5.0;
static double const TRV_METERS_PER_MILE = 1609.344;
NSTimeInterval const kTrvFlipAnimationDuration = 0.75;
NSTimeInterval const kTrvSearchModeAnimationDuration = 0.36;

@interface TrotterViewController () <CLLocationManagerDelegate, LoadDataProtocol, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, THDatePickerDelegate, MKMapViewDelegate>

@property (nonatomic) VIEW_STATE viewState;
@property (nonatomic, strong) NSMutableArray *placesTableData;
@property (nonatomic, strong) UITableView *placesTableView;
@property (nonatomic, readonly) CGRect placesTableViewZeroFrame;
@property (nonatomic, readonly) CGRect placesTableViewExpandedFrame;
@property (nonatomic) BOOL isPlacesTableViewExpanded;
@property (nonatomic) NSTimeInterval animationDuraton;
//@property (nonatomic, strong) MKMapView *mkMapView;
@property (nonatomic) CLLocationCoordinate2D zoomLocation;
@property (nonatomic) CLLocationDistance mapRadiusInMeters;
@property (nonatomic) CLLocationDistance mapRadiusInMiles;
@property (nonatomic) BOOL notMyFirstRodeo;
@property (nonatomic) BOOL redrawMapOnSelection;
@property (nonatomic) BOOL useMapRadiusForSearch;
@property (nonatomic) BOOL loadingGooglePlaceDetails;
@property (nonatomic, strong) NSString *tmpSelectedCellPlaceName;
@property (nonatomic, strong) NSMutableArray *openConnections;

@property (nonatomic) BOOL arrivalOrReturn; //arrival == NO and return == YES
@property (nonatomic) BOOL criteriaOrHotelSearchMode;

@property (nonatomic, strong) HotelsTableViewDelegateImplementation *hotelTableViewDelegate;

@property (nonatomic) BOOL userLocationHasUpdated;
@property (nonatomic, assign) BOOL nextRegionChangeIsFromUserInteraction;
@property (nonatomic) double listMaxLatitudeDelta;
@property (nonatomic) double listMaxLongitudeDelta;

// Outlets

@property (weak, nonatomic) IBOutlet UIView *whereToContainer;
@property (weak, nonatomic) IBOutlet UITextField *whereToTextField;
@property (weak, nonatomic) IBOutlet UILabel *whereToSecondLevel;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet MKMapView *mkMapView;
@property (weak, nonatomic) IBOutlet UIView *hotelsTableViewContainer;
@property (weak, nonatomic) IBOutlet UITableView *hotelsTableView;
@property (weak, nonatomic) IBOutlet WotaTappableView *wmapContainer;
@property (weak, nonatomic) IBOutlet UIView *cupHolder;
@property (weak, nonatomic) IBOutlet WotaButton *arrivalDateOutlet;
@property (weak, nonatomic) IBOutlet WotaButton *returnDateOutlet;
@property (weak, nonatomic) IBOutlet UILabel *adultsLabel;
@property (weak, nonatomic) IBOutlet WotaButton *addAdultOutlet;
@property (weak, nonatomic) IBOutlet WotaButton *minusAdultOutlet;
@property (weak, nonatomic) IBOutlet WotaButton *kidsButton;
@property (weak, nonatomic) IBOutlet WotaButton *checkHotelsOutlet;
@property (weak, nonatomic) IBOutlet UIView *backContainer;
@property (weak, nonatomic) IBOutlet UIView *footerContainer;
@property (weak, nonatomic) IBOutlet UIView *overlay;
@property (weak, nonatomic) IBOutlet UIView *filterContainer;

- (IBAction)justPushIt:(id)sender;

@end

@implementation TrotterViewController {
    CLLocationManager *locationManager;
    THDatePickerViewController *arrivalDatePicker;
    THDatePickerViewController *returnDatePicker;
    BOOL filterViewUp;
}

#pragma mark Lifecycle methods

- (id)init {
    if (self = [super initWithNibName:@"TrotterView" bundle:nil]) {
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
    
    self.viewState = VIEW_STATE_PRE_HOTEL;
    
    //**********************************************************************
    // This is needed so that this view controller (or it's nav controller?)
    // doesn't make room at the top of the table view's scroll view (I guess
    // to account for the nav bar).
    //***********************************************************************
    self.automaticallyAdjustsScrollViewInsets = NO;
    //***********************************************************************
    
    self.mkMapView.delegate = self;
    
    self.placesTableView = [[UITableView alloc] initWithFrame:self.placesTableViewZeroFrame];
    self.placesTableView.backgroundColor = [UIColor whiteColor];
    self.placesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.placesTableView.separatorColor = [UIColor clearColor];
    self.placesTableView.dataSource = self;
    self.placesTableView.delegate = self;
    self.placesTableView.sectionHeaderHeight = 0.0f;
//    self.placesTableViewZeroFrame = CGRectMake(0, 98, 320, 0);
//    self.placesTableViewExpandedFrame = CGRectMake(0, 98, 320, 247);
    [self.view addSubview:self.placesTableView];
    
    self.placesTableData = [SelectionCriteria singleton].placesArray;
    [self.placesTableView reloadData];
    
    _hotelTableViewDelegate = [[HotelsTableViewDelegateImplementation alloc] init];
    
    _hotelsTableView.dataSource = _hotelTableViewDelegate;
    _hotelsTableView.delegate = _hotelTableViewDelegate;
    _hotelsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _hotelsTableView.separatorColor = [UIColor clearColor];
    _hotelsTableView.delaysContentTouches = NO;
    
    [self setupTheFilterTableView];
    
    self.whereToTextField.delegate = self;
    [self resetWhereToTfAppearance];
    self.whereToTextField.text = @"";//[SelectionCriteria singleton].whereToFirst;
    self.whereToSecondLevel.text = @"";//[SelectionCriteria singleton].whereToSecond;
    
    self.openConnections = [NSMutableArray array];
    
    [self setNumberOfAdultsLabel:0];
    [self setNumberOfKidsButtonLabel];
    
    self.arrivalOrReturn = NO;
    [self refreshDisplayedArrivalDate];
    [self refreshDisplayedReturnDate];
    
    UITapGestureRecognizer *fgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickFilterButton)];
    fgr.numberOfTapsRequired = 1;
    fgr.numberOfTouchesRequired = 1;
    fgr.cancelsTouchesInView = NO;
    self.filterContainer.userInteractionEnabled = YES;
    [self.filterContainer addGestureRecognizer:fgr];
    
    UITapGestureRecognizer *bgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickBack:)];
    bgr.numberOfTapsRequired = 1;
    bgr.numberOfTouchesRequired = 1;
    self.backContainer.userInteractionEnabled = YES;
    [self.backContainer addGestureRecognizer:bgr];
    
    BackCancelView *bcv = [[BackCancelView alloc] initWithFrame:CGRectMake(0, 0, 28, 36)];
    bcv.transform = CGAffineTransformMakeScale(0.7f, 0.7f);
    [self.backContainer addSubview:bcv];
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadMapOrCriteriaView)];
    tgr.numberOfTapsRequired = 1;
    tgr.numberOfTouchesRequired = 1;
    self.wmapContainer.userInteractionEnabled = YES;
    [self.wmapContainer addGestureRecognizer:tgr];
    
    UITapGestureRecognizer *ogr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dropFilterOrSortView)];
    ogr.numberOfTapsRequired = 1;
    ogr.numberOfTouchesRequired = 1;
    _overlay.userInteractionEnabled = YES;
    [_overlay addGestureRecognizer:ogr];
    _overlay.alpha = 0.0f;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onHotelDataFiltered) name:kNotificationHotelDataFiltered object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onHotelDataSorted) name:kNotificationHotelDataSorted object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResume:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self redrawMapViewAnimated:YES radius:[SelectionCriteria singleton].zoomRadius];
    
    self.footerContainer.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
    
    // TODO: Does this belong in SearchViewController?
//    if (self.notMyFirstRodeo) {
//        self.whereToTextField.text = [SelectionCriteria singleton].whereToFirst;
//        self.whereToSecondLevel.text = [SelectionCriteria singleton].whereToSecond;
//        [self redrawMapViewAnimated:NO radius:[SelectionCriteria singleton].zoomRadius];
//    }
    
    [super viewWillAppear:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationHotelDataFiltered object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationHotelDataSorted object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)dropDaSpinnerAlready {
    // just overriding an unimplemented parent method
}

//- (void)requestFinished:(NSData *)responseData dataType:(LOAD_DATA_TYPE)dataType {
//    [super requestFinished:responseData dataType:dataType];
//    if (dataType == LOAD_GOOGLE_PLACES && self.hvc) {
//        [self itKeepsTheWaterOffOurHeads:NO];
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Various map methods

- (void)appWillResignActive:(NSNotification *)notification {
    //    mapView.showsUserLocation = NO;
}

- (void)appWillResume:(NSNotification *)notification {
    if (self.mkMapView.frame.origin.y == 130) {
        self.mkMapView.showsUserLocation = YES;
    }
}

- (void)reverseGeoCodingDawg {
    [[LoadGooglePlacesData sharedInstance] loadPlaceDetailsWithLatitude:self.mkMapView.region.center.latitude longitude:self.mkMapView.region.center.longitude completionBlock:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [SelectionCriteria singleton].googlePlaceDetail = [GooglePlaceDetail placeDetailFromGeoCodeData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.whereToTextField.text = [SelectionCriteria singleton].whereToFirst;
            self.whereToSecondLevel.text = [SelectionCriteria singleton].whereToSecond;
        });
    }];
}

#pragma mark UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (!_isPlacesTableViewExpanded) {
        [self animateTableViewExpansion];
    }
    
    self.whereToTextField.text = @"";
    self.whereToSecondLevel.text = @"";
    
    self.whereToTextField.layer.cornerRadius = WOTA_CORNER_RADIUS;
    self.whereToTextField.layer.borderColor = kWotaColorOne().CGColor;
    self.whereToTextField.layer.borderWidth = 1.0f;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *autoCompleteText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([autoCompleteText length] >= kTrvAutoCompleteMinimumNumberOfCharacters) {
        if (self.placesTableData == [SelectionCriteria singleton].placesArray) {
            self.placesTableData = [NSMutableArray array];
            [self.placesTableView reloadData];
        }
        [self.openConnections makeObjectsPerformSelector:@selector(cancel)];
        [self.openConnections removeAllObjects];
        [[LoadGooglePlacesData sharedInstance:self] autoCompleteSomePlaces:autoCompleteText];
    } else {
        return [self textFieldShouldClear:textField];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.whereToTextField resignFirstResponder];
    self.whereToTextField.text = [SelectionCriteria singleton].whereToFirst;
    self.whereToSecondLevel.text = [SelectionCriteria singleton].whereToSecond;
    [self animateTableViewCompression];
    
    return [self textFieldShouldClear:textField];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (self.placesTableData != [SelectionCriteria singleton].placesArray) {
        self.placesTableData = [SelectionCriteria singleton].placesArray;
        [self.placesTableView reloadData];
    }
    [self.openConnections makeObjectsPerformSelector:@selector(cancel)];
    [self.openConnections removeAllObjects];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self resetWhereToTfAppearance];
}

#pragma mark LoadDataProtocol methods

- (void)requestStarted:(NSURLConnection *)connection {
    [self.openConnections addObject:connection];
    NSLog(@"%@.%@ loading URL:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [[[connection currentRequest] URL] absoluteString]);
}

- (void)requestFinished:(NSData *)responseData dataType:(LOAD_DATA_TYPE)dataType {
    switch (dataType) {
        case LOAD_GOOGLE_AUTOCOMPLETE: {
            NSArray *wes = [GoogleParser parseAutoCompleteResponse:responseData];
            if (wes) {
                self.placesTableData = [NSMutableArray arrayWithArray:wes];
                [self.placesTableView reloadData];
            } else {
                //                self.placesTableData = [NSMutableArray arrayWithObject:self.whereToTextField.text];
            }
            break;
        }
            
        case LOAD_GOOGLE_PLACES: {
            self.loadingGooglePlaceDetails = NO;
            [SelectionCriteria singleton].googlePlaceDetail = [GooglePlaceDetail placeDetailFromData:responseData];
            self.useMapRadiusForSearch = NO;
            //            [[SelectionCriteria singleton] savePlace:[GooglePlaceDetail placeDetailFromData:responseData]];
            self.placesTableData = [SelectionCriteria singleton].placesArray;
            [self.placesTableView reloadData];
            //            [self.placesTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            self.whereToTextField.text = [SelectionCriteria singleton].whereToFirst;
            self.whereToSecondLevel.text = [SelectionCriteria singleton].whereToSecond;
            if (self.redrawMapOnSelection) {
                [self redrawMapViewAnimated:YES radius:[SelectionCriteria singleton].googlePlaceDetail.zoomRadius];
            }
            break;
        }
            
        case LOAD_EAN_HOTELS_LIST: {
            EanHotelListResponse *ehlr = [EanHotelListResponse eanObjectFromApiResponseData:responseData];
            
            if (ehlr.hotelList.count == 0) {
                [self handleNoHotels];
                return;
            }
            
            _hotelTableViewDelegate.hotelData = ehlr.hotelList;
            [self showOrHideTvControls];
            [_hotelsTableView reloadData];
            [_hotelsTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            
            UITextField *tf = (UITextField *) [_hotelsTableView.tableHeaderView viewWithTag:41414141];
            tf.text = @"";
            
            _listMaxLatitudeDelta = ehlr.maxLatitudeDelta;
            _listMaxLongitudeDelta = ehlr.maxLongitudeDelta;
            
            [self redrawMapAnnotationsAndRegion:YES];
            [self setupTheFilterView];
//            [self setupTheSortView];
            
//            __weak NavigationView *nv = (NavigationView *) [self.view viewWithTag:kNavigationViewTag];
//            nv.whereToLabel.text = [SelectionCriteria singleton].whereToFirst;
            
            [self dropDaSpinnerAlready];
        }
            
        default:
            break;
    }
}

- (void)requestTimedOut {
    self.loadingGooglePlaceDetails = NO;
    [self dropDaSpinnerAlready];
    __weak typeof(self) wes = self;
    [NetworkProblemResponder launchWithSuperView:self.view headerTitle:nil messageString:nil completionCallback:^{
        [wes.navigationController popViewControllerAnimated:YES];
        [wes animateTableViewCompression];
    }];
}

- (void)requestFailedOffline {
    self.loadingGooglePlaceDetails = NO;
    [self dropDaSpinnerAlready];
    __weak typeof(self) wes = self;
    [NetworkProblemResponder launchWithSuperView:self.view headerTitle:@"Network Error" messageString:@"The network could not be reached. Please check your connection and try again." completionCallback:^{
        [wes.navigationController popViewControllerAnimated:YES];
        [wes animateTableViewCompression];
    }];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.placesTableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.placesTableData[indexPath.row] isKindOfClass:[NSString class]]) {
        if ([self.placesTableData[indexPath.row] isEqualToString:@"poweredByGoogle"]) {
            NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"PowerebByGoogleCell" owner:self options:nil];
            UITableViewCell *poweredByGoogleCell = views.firstObject;
            return poweredByGoogleCell;
        } else if (!stringIsEmpty(self.placesTableData[indexPath.row])) {
            NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"NoPredictionsCell" owner:self options:nil];
            UITableViewCell *bsCell = views.firstObject;
            UIView *lc = [bsCell.contentView viewWithTag:987123];
            UILabel *wes = (UILabel *)[lc viewWithTag:123987];
            wes.text = self.placesTableData[indexPath.row];
            return bsCell;
        }
    }
    
    NSString *CellIdentifier = @"placeAutoCompleteCell";
    PlaceAutoCompleteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"PlaceAutoCompleteTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    
    WotaPlace *place = [self.placesTableData objectAtIndex:indexPath.row];
    cell.outletPlaceName.text = [place isKindOfClass:[GooglePlace class]] ? place.placeName : place.formattedWhereTo;
    cell.placeId = place.placeId;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row != 0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([[SelectionCriteria singleton].selectedPlace.placeId isEqualToString:((WotaPlace *)[self.placesTableData objectAtIndex:indexPath.row]).placeId]) {
            [SelectionCriteria singleton].selectedPlace = [SelectionCriteria singleton].placesArray.firstObject;
        }
        
        if ([[SelectionCriteria singleton].googlePlaceDetail.placeId isEqualToString:((WotaPlace *)[self.placesTableData objectAtIndex:indexPath.row]).placeId]) {
            [SelectionCriteria singleton].googlePlaceDetail = nil;
        }
        
        [self.placesTableData removeObjectAtIndex:indexPath.row];
        [[SelectionCriteria singleton] save];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.placesTableData[indexPath.row] isKindOfClass:[NSString class]]) {
        return;
    }
    
    PlaceAutoCompleteTableViewCell * cell = (PlaceAutoCompleteTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if ([self.placesTableData[indexPath.row] isKindOfClass:[GooglePlace class]]) {
        self.loadingGooglePlaceDetails = YES;
        self.whereToTextField.text = self.tmpSelectedCellPlaceName = [cell.outletPlaceName.text componentsSeparatedByString:@","].firstObject;
        [[LoadGooglePlacesData sharedInstance:self] loadPlaceDetails:cell.placeId];
        self.placesTableData = [SelectionCriteria singleton].placesArray;
        [self.placesTableView reloadData];
        [self.whereToTextField resignFirstResponder];
        [self animateTableViewCompression];
        self.useMapRadiusForSearch = NO;
    } else if ([self.placesTableData[indexPath.row] isKindOfClass:[WotaPlace class]]) {
        self.placesTableData = [SelectionCriteria singleton].placesArray;
        [self.placesTableView reloadData];
        [self.whereToTextField resignFirstResponder];
        [SelectionCriteria singleton].googlePlaceDetail = nil;
        [SelectionCriteria singleton].selectedPlace = self.placesTableData[indexPath.row];
        self.whereToTextField.text = [SelectionCriteria singleton].whereToFirst;
        self.whereToSecondLevel.text = [SelectionCriteria singleton].whereToSecond;
        [self animateTableViewCompression];
        if (self.redrawMapOnSelection) {
            [self redrawMapViewAnimated:YES radius:[SelectionCriteria singleton].selectedPlace.zoomRadius];
        }
        self.useMapRadiusForSearch = NO;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark Some animation methods

- (void)animateTableViewExpansion {
    __weak UIView *actv = self.placesTableView;
    [self.view bringSubviewToFront:actv];
    self.isPlacesTableViewExpanded = YES;
    [UIView animateWithDuration:self.animationDuraton animations:^{
        actv.frame = self.placesTableViewExpandedFrame;
    } completion:^(BOOL finished) {
    }];
}

- (void)animateTableViewCompression {
    __weak UIView *actv = self.placesTableView;
    self.isPlacesTableViewExpanded = NO;
    [UIView animateWithDuration:self.animationDuraton animations:^{
        actv.frame = self.placesTableViewZeroFrame;
    } completion:^(BOOL finished) {
    }];
}

- (void)transitionToMapView {
    
//    if (self.isPlacesTableViewExpanded) {
//        
//        [self.whereToTextField endEditing:YES];
//        [self animateTableViewCompression];
//        
//    }
    
    UIView *cv = [self currentViewFromState];
    [UIView transitionFromView:cv
                        toView:self.mkMapView
                      duration:kTrvFlipAnimationDuration
                       options:UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionAllowAnimatedContent
                    completion:^(BOOL finished) {
                        self.viewState = VIEW_STATE_MAP;
                    }];

}

- (void)transiTionToCriteriaView {
    UIView *cv = [self currentViewFromState];
    [UIView transitionFromView:cv
                        toView:self.cupHolder
                      duration:kTrvFlipAnimationDuration
                       options:UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionAllowAnimatedContent
                    completion:^(BOOL finished) {
                        self.viewState = VIEW_STATE_PRE_HOTEL;
                    }];
}

- (void)transitionToTableView {
    UIView *cv = [self currentViewFromState];
    [self.containerView bringSubviewToFront:self.hotelsTableViewContainer];
    [UIView transitionFromView:cv
                        toView:self.hotelsTableViewContainer
                      duration:kTrvFlipAnimationDuration
                       options:UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionAllowAnimatedContent
                    completion:^(BOOL finished) {
                        self.viewState = VIEW_STATE_HOTELS;
                    }];
}

- (void)transitionToHotelSearchMode {
    self.criteriaOrHotelSearchMode = YES;
//    self.placesTableViewZeroFrame = CGRectMake(0, 58, 320, 0);
//    self.placesTableViewExpandedFrame = CGRectMake(0, 58, 320, 247);
    
    [UIView animateWithDuration:kTrvFlipAnimationDuration animations:^{
        self.whereToContainer.frame = CGRectMake(0, 28, 320, 40);
        self.whereToTextField.frame = CGRectMake(32, 0, 243, 30);
        self.whereToSecondLevel.frame = CGRectMake(39, 1, 232, 21);
        self.backContainer.frame = CGRectMake(0, -3, 33, 33);
        self.footerContainer.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)transitionToCriteriaMode {
    self.criteriaOrHotelSearchMode = NO;
    [self animateTableViewCompression];
    
    [UIView animateWithDuration:kTrvFlipAnimationDuration animations:^{
        self.whereToContainer.frame = CGRectMake(0, 68, 320, 50);
        self.whereToTextField.frame = CGRectMake(6, 0, 270, 30);
        self.whereToSecondLevel.frame = CGRectMake(13, 29, 295, 21);
        self.backContainer.frame = CGRectMake(2, -3, 33, 33);
        self.footerContainer.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
    } completion:^(BOOL finished) {
        ;
    }];
}

#pragma mark Various methods likely called by sublclasses

- (void)redrawMapAnnotationsAndRegion:(BOOL)redrawRegion {
    if (redrawRegion) {
        double spanLat = _listMaxLatitudeDelta*2.50;
        double spanLon = _listMaxLongitudeDelta*2.50;
        MKCoordinateSpan span = MKCoordinateSpanMake(spanLat, spanLon);
        MKCoordinateRegion viewRegion = MKCoordinateRegionMake(self.zoomLocation, span);
        
        [self.mkMapView setRegion:viewRegion animated:self.viewState == VIEW_STATE_MAP];
        [self.mkMapView setNeedsDisplay];
    }
    
    [self removeAllPinsButUserLocation];
    
    for (int j = 0; j < [_hotelTableViewDelegate.currentHotelData count]; j++) {
        EanHotelListHotelSummary *hotel = [_hotelTableViewDelegate.currentHotelData objectAtIndex:j];
        WotaMapAnnotatioin *annotation = [[WotaMapAnnotatioin alloc] init];
        annotation.coordinate = CLLocationCoordinate2DMake(hotel.latitude, hotel.longitude);
        NSString *imageUrlString = [@"http://images.travelnow.com" stringByAppendingString:hotel.thumbNailUrlEnhanced];
        annotation.imageUrl = imageUrlString;
        
        annotation.rowNUmber = j;
        annotation.title = hotel.hotelNameFormatted;
        NSNumberFormatter *cf = kPriceRoundOffFormatter(hotel.rateCurrencyCode);
        annotation.subtitle = [NSString stringWithFormat:@"From %@/night", [cf stringFromNumber:hotel.lowRate]];
        [self.mkMapView addAnnotation:annotation];
    }
}

- (void)removeAllPinsButUserLocation {
    id userLocation = [self.mkMapView userLocation];
    NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[self.mkMapView annotations]];
    if (userLocation != nil) {
        [pins removeObject:userLocation];
    }
    
    [self.mkMapView removeAnnotations:pins];
}

- (void)redrawMapViewAnimated:(BOOL)animated radius:(double)radius {
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.zoomLocation, 1.6*radius*TRV_METERS_PER_MILE, 1.6*radius*TRV_METERS_PER_MILE);
    [self.mkMapView setRegion:viewRegion animated:animated];
}

- (CLLocationCoordinate2D)zoomLocation {
    SelectionCriteria *sc = [SelectionCriteria singleton];
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = sc.latitude;
    zoomLocation.longitude= sc.longitude;
    return zoomLocation;
}

- (void)letsFindHotelsWithSearchRadius:(double)searchRadius {
    
    searchRadius = searchRadius * 0.92;
    searchRadius = fmax(searchRadius, 1);
    searchRadius = fmin(searchRadius, 50);
    int sri = ceil(searchRadius);
    
    SelectionCriteria *sc = [SelectionCriteria singleton];
    
    [[LoadEanData sharedInstance:self] loadHotelsWithLatitude:sc.latitude
                                                   longitude:sc.longitude
                                                 arrivalDate:sc.arrivalDateEanString
                                                  returnDate:sc.returnDateEanString
                                                searchRadius:[NSNumber numberWithInt:sri]
                                               withProximity:sc.isLodging];
    
    self.criteriaOrHotelSearchMode = YES;
    
    if ([SelectionCriteria singleton].googlePlaceDetail) {
        [[SelectionCriteria singleton] savePlace:[SelectionCriteria singleton].googlePlaceDetail];
    }
    
    self.placesTableData = [SelectionCriteria singleton].placesArray;
    [self.placesTableView reloadData];
    
    if (self.viewState == VIEW_STATE_PRE_HOTEL) {
        // do something here to slide criteria cupholder off screen and hotel listing on screen
    } else {
        AppDelegate *ad = [[UIApplication sharedApplication] delegate];
        [ad loadDaSpinner];
    }
}

- (CLLocationDistance)mapRadiusInMeters {
    // init center location from center coordinate
    CLLocation *centerLocation = [[CLLocation alloc] initWithLatitude:self.mkMapView.centerCoordinate.latitude
                                                            longitude:self.mkMapView.centerCoordinate.longitude];
    
    double topCenterLat = centerLocation.coordinate.latitude-self.mkMapView.region.span.latitudeDelta/2.;
    CLLocation *topCenterLocation = [[CLLocation alloc] initWithLatitude:topCenterLat
                                                               longitude:centerLocation.coordinate.longitude];
    
    CLLocationDistance distance = [centerLocation distanceFromLocation:topCenterLocation];
    return distance;
}

- (CLLocationDistance)mapRadiusInMiles {
    return self.mapRadiusInMeters / TRV_METERS_PER_MILE;
}

#pragma mark Getters

- (NSTimeInterval)animationDuraton {
    if (_animationDuraton == 0.0) {
        return 0.3;
    }
    
    return _animationDuraton;
}

- (CGRect)placesTableViewZeroFrame {
    return self.criteriaOrHotelSearchMode ? CGRectMake(0, 58, 320, 0) : CGRectMake(0, 98, 320, 0);
}

- (CGRect)placesTableViewExpandedFrame {
    return self.criteriaOrHotelSearchMode ? CGRectMake(0, 58, 320, 294) : CGRectMake(0, 98, 320, 254);
}

#pragma mark Various events and such

- (void)clickBack:(id)sender {
    [self transitionToCriteriaMode];
    [self transiTionToCriteriaView];
}

- (void)loadMapOrCriteriaView {
    switch (self.viewState) {
        case VIEW_STATE_PRE_HOTEL: {
            [self transitionToMapView];
            break;
        }
            
        case VIEW_STATE_MAP: {
            if (self.criteriaOrHotelSearchMode) {
                [self transitionToTableView];
            } else {
                [self transiTionToCriteriaView];
            }
            break;
        }
            
        case VIEW_STATE_HOTELS: {
            [self transitionToMapView];
            break;
        }
            
        default:
            break;
    }
}

- (void)itKeepsTheWaterOffOurHeads:(BOOL)pushVC {
    if (self.useMapRadiusForSearch) {
        [SelectionCriteria singleton].zoomRadius = self.mapRadiusInMiles;
    }
    
    [self letsFindHotelsWithSearchRadius:[SelectionCriteria singleton].zoomRadius];
    
//    self.hvc = nil;
}

- (IBAction)justPushIt:(id)sender {
    if (sender == self.checkHotelsOutlet) {
        
        [self transitionToHotelSearchMode];
        [self transitionToTableView];
        
        if (!self.loadingGooglePlaceDetails) {
            
//            self.hvc = [[HotelListingViewController alloc] initWithProvisionalTitle:[SelectionCriteria singleton].whereToFirst];
            [self itKeepsTheWaterOffOurHeads:YES];
            
        } else {
            
            NSString *wes = !stringIsEmpty(self.tmpSelectedCellPlaceName) ? self.tmpSelectedCellPlaceName : self.whereToTextField.text;
//            self.hvc = [[HotelListingViewController alloc] initWithProvisionalTitle:wes];
//            [self.navigationController pushViewController:self.hvc animated:YES];
            
        }
        
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

- (void)onHotelDataFiltered {
    [_hotelsTableView reloadData];
    [self redrawMapAnnotationsAndRegion:NO];
}

//- (void)letsSortYo:(UITapGestureRecognizer *)tgr {
//    [self.hotelTableViewDelegate letsSortYo:tgr];
//    [self dropSortView];
//}

- (void)onHotelDataSorted {
    [_hotelsTableView reloadData];
    [self redrawMapAnnotationsAndRegion:NO];
}

- (void)dropFilterOrSortView {
    
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
    if (sc.arrivalDate == nil
        || [kTimelessDate([NSDate date]) compare:kTimelessDate(sc.arrivalDate)] == NSOrderedDescending) {
        sc.arrivalDate = [NSDate date];
    }
    
    [_arrivalDateOutlet setTitle:[kPrettyDateFormatter() stringFromDate:sc.arrivalDate] forState:UIControlStateNormal];
    
    NSDate *tla = kTimelessDate(sc.arrivalDate);
    NSDate *arrivalDatePlus28 = kTimelessDate(kAddDays(28, sc.arrivalDate));
    
    if (nil == sc.returnDate
        || [tla compare:kTimelessDate(sc.returnDate)] == NSOrderedDescending
        || [tla compare:kTimelessDate(sc.returnDate)] == NSOrderedSame
        || [kTimelessDate(sc.returnDate) compare:arrivalDatePlus28] == NSOrderedDescending) {
        
        sc.returnDate = kAddDays(1, sc.arrivalDate);
        [_returnDateOutlet setTitle:[kPrettyDateFormatter() stringFromDate:sc.returnDate] forState:UIControlStateNormal];
    }
}

-(void)refreshDisplayedReturnDate {
    SelectionCriteria *sc = [SelectionCriteria singleton];
    NSDate *tlc = kTimelessDate([NSDate date]);
    if (nil == sc.returnDate
        || [tlc compare:kTimelessDate(sc.returnDate)] == NSOrderedDescending
        || [tlc compare:kTimelessDate(sc.returnDate)] == NSOrderedSame) {
        
        if (nil == sc.arrivalDate
            || [tlc compare:kTimelessDate(sc.arrivalDate)] == NSOrderedDescending) {
            sc.arrivalDate = [NSDate date];
            [_arrivalDateOutlet setTitle:[kPrettyDateFormatter() stringFromDate:sc.arrivalDate] forState:UIControlStateNormal];
        }
        
        sc.returnDate = kAddDays(1, sc.arrivalDate);
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

#pragma mark No hotels

- (void)handleNoHotels {
    [self dropDaSpinnerAlready];
    [self showOrHideTvControls];
    
    NSArray *vs = [[NSBundle mainBundle] loadNibNamed:@"NoHotelsView" owner:self options:nil];
    __block UIView *nhv = vs.firstObject;
    nhv.frame = CGRectMake(15, 210, 290, 165);
    nhv.layer.cornerRadius = WOTA_CORNER_RADIUS;
    nhv.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
    WotaButton *ok = (WotaButton *)[nhv viewWithTag:471395];
    [ok addTarget:self action:@selector(okToNoHotels:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nhv];
    
    UIView *ov = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    ov.tag = 14942484;
    ov.backgroundColor = [UIColor blackColor];
    ov.alpha = 0.0;
    ov.userInteractionEnabled = YES;
    [self.view addSubview:ov];
    
    [self.view bringSubviewToFront:ov];
    [self.view bringSubviewToFront:nhv];
    [UIView animateWithDuration:0.2 animations:^{
        nhv.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        ov.alpha = 0.7f;
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)okToNoHotels:(WotaButton *)wb {
    __weak UIView *nhv = wb.superview;
    __weak UIView *ov = [self.view viewWithTag:14942484];
    [UIView animateWithDuration:0.2 animations:^{
        nhv.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
        ov.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [nhv removeFromSuperview];
        [ov removeFromSuperview];
    }];
}

- (void)showOrHideTvControls {
    if (self.hotelTableViewDelegate.hotelData.count == 0) {
        self.hotelsTableView.tableHeaderView.hidden = YES;
//        self.wmapIvContainer.hidden = YES;
//        self.searchMapBtn.hidden = YES;
//        self.pricesAvgLabel.hidden = YES;
//        self.sortFilterContainer.hidden = YES;
    } else {
        self.hotelsTableView.tableHeaderView.hidden = NO;
//        self.wmapIvContainer.hidden = NO;
//        self.searchMapBtn.hidden = NO;
//        self.pricesAvgLabel.hidden = NO;
//        self.sortFilterContainer.hidden = NO;
    }
}

#pragma mark Helpers

- (void)setupTheFilterTableView {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"HotelNameFilterView" owner:self options:nil];
    UIView *filterView = views.firstObject;
    UITextField *tf = (UITextField *) [filterView viewWithTag:41414141];
    tf.delegate = _hotelTableViewDelegate;
    
    UIImage *im = [[UIImage imageNamed:@"search.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *iv = [[UIImageView alloc] initWithImage:im];
    iv.tintColor = [UIColor blackColor];
    iv.contentMode = UIViewContentModeScaleAspectFit;
    iv.frame = CGRectMake(10, 8, 14, 14);
    
    UIView *ivc = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 26, 30)];
    ivc.backgroundColor = [UIColor clearColor];
    [ivc addSubview:iv];
    
//    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickFilterButton)];
//    tgr.numberOfTapsRequired = 1;
//    tgr.numberOfTouchesRequired = 1;
//    tgr.cancelsTouchesInView = NO;
//    WotaTappableView *filterContainer = (WotaTappableView *) [filterView viewWithTag:1239871];
//    filterContainer.tapColor = kWotaColorOne();
//    filterContainer.untapColor = [UIColor clearColor];
//    filterContainer.userInteractionEnabled = YES;
//    [filterContainer addGestureRecognizer:tgr];
    
    UIView *separator = [[UILabel alloc] initWithFrame:CGRectMake(0, 43.5f, 320, 0.5f)];
    separator.backgroundColor = [UIColor blackColor];
    [filterView addSubview:separator];
    
    [tf setLeftViewMode:UITextFieldViewModeAlways];
    tf.leftView = ivc;
    
    _hotelsTableView.tableHeaderView = filterView;
}

- (void)setupTheFilterView {
    UIView *fv = [self.view viewWithTag:91929394];
    UIView *starsContainer = nil;
    
    if (!fv) {
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"FilterView" owner:self options:nil];
        fv = views.firstObject;
        fv.frame = CGRectMake(0, 600, 320, 300);
        [self.view addSubview:fv];
        
        UIButton *db = (WotaButton *) [fv viewWithTag:16171819];
        [db addTarget:self action:@selector(dropFilterView) forControlEvents:UIControlEventTouchUpInside];
        
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dropFilterOrSortView)];
        tgr.numberOfTapsRequired = 1;
        tgr.numberOfTouchesRequired = 1;
        _overlay.userInteractionEnabled = YES;
        [_overlay addGestureRecognizer:tgr];
        
        starsContainer = [fv viewWithTag:4300];
        
        UITapGestureRecognizer *tgr0 = [[UITapGestureRecognizer alloc] initWithTarget:self.hotelTableViewDelegate action:@selector(starClicked:)];
        tgr0.numberOfTapsRequired = 1;
        tgr0.numberOfTouchesRequired = 1;
        [[starsContainer viewWithTag:4299] addGestureRecognizer:tgr0];
        
        UITapGestureRecognizer *tgr1 = [[UITapGestureRecognizer alloc] initWithTarget:self.hotelTableViewDelegate action:@selector(starClicked:)];
        tgr1.numberOfTapsRequired = 1;
        tgr1.numberOfTouchesRequired = 1;
        [[starsContainer viewWithTag:4301] addGestureRecognizer:tgr1];
        
        UITapGestureRecognizer *tgr2 = [[UITapGestureRecognizer alloc] initWithTarget:self.hotelTableViewDelegate action:@selector(starClicked:)];
        tgr2.numberOfTapsRequired = 1;
        tgr2.numberOfTouchesRequired = 1;
        [[starsContainer viewWithTag:4302] addGestureRecognizer:tgr2];
        
        UITapGestureRecognizer *tgr3 = [[UITapGestureRecognizer alloc] initWithTarget:self.hotelTableViewDelegate action:@selector(starClicked:)];
        tgr3.numberOfTapsRequired = 1;
        tgr3.numberOfTouchesRequired = 1;
        [[starsContainer viewWithTag:4303] addGestureRecognizer:tgr3];
        
        UITapGestureRecognizer *tgr4 = [[UITapGestureRecognizer alloc] initWithTarget:self.hotelTableViewDelegate action:@selector(starClicked:)];
        tgr4.numberOfTapsRequired = 1;
        tgr4.numberOfTouchesRequired = 1;
        [[starsContainer viewWithTag:4304] addGestureRecognizer:tgr4];
        
        UITapGestureRecognizer *tgr5 = [[UITapGestureRecognizer alloc] initWithTarget:self.hotelTableViewDelegate action:@selector(starClicked:)];
        tgr5.numberOfTapsRequired = 1;
        tgr5.numberOfTouchesRequired = 1;
        [[starsContainer viewWithTag:4305] addGestureRecognizer:tgr5];
    }
    
    RangeSlider *oldPs = (RangeSlider *) [fv viewWithTag:39383736];
    if (oldPs) {
        [oldPs removeFromSuperview];
    }
    
    RangeSlider *ps = [[RangeSlider alloc] initWithFrame:CGRectMake(20, 119, 280, 40)];
    ps.tag = 39383736;
    [fv addSubview:ps];
    [ps addTarget:self.hotelTableViewDelegate action:@selector(priceSliderChanged:) forControlEvents:UIControlEventValueChanged];
    
    starsContainer = [fv viewWithTag:4300];
    ((UILabel *) [starsContainer viewWithTag:4299]).textColor = kWotaColorOne();
    ((UIView *) [starsContainer viewWithTag:4301].subviews.firstObject).tintColor = [UIColor grayColor];
    ((UIView *) [starsContainer viewWithTag:4302].subviews.firstObject).tintColor = [UIColor grayColor];
    ((UIView *) [starsContainer viewWithTag:4303].subviews.firstObject).tintColor = [UIColor grayColor];
    ((UIView *) [starsContainer viewWithTag:4304].subviews.firstObject).tintColor = [UIColor grayColor];
    ((UIView *) [starsContainer viewWithTag:4305].subviews.firstObject).tintColor = [UIColor grayColor];
    
    [self updateFilterViewNumbers:fv];
}

- (void)clickFilterButton {
    [self loadFilterView];
    [self.view endEditing:YES];
}

- (void)loadFilterView {
    __weak UIView *fv = [self.view viewWithTag:91929394];
    [self updateFilterViewNumbers:fv];
    [self.view bringSubviewToFront:_overlay];
    [self.view bringSubviewToFront:fv];
    self.hotelTableViewDelegate.inFilterModePriorToLoadingFilterView = self.hotelTableViewDelegate.inFilterMode;
    filterViewUp = YES;
    [UIView animateWithDuration:kTrvSearchModeAnimationDuration animations:^{
        _overlay.alpha = 0.7f;
        fv.frame = CGRectMake(0, 268, 320, 300);
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)dropFilterView {
    [self.hotelTableViewDelegate letsFilter];
    __weak UIView *fv = [self.view viewWithTag:91929394];
    filterViewUp = NO;
    [UIView animateWithDuration:kTrvSearchModeAnimationDuration animations:^{
        _overlay.alpha = 0.0f;
        fv.frame = CGRectMake(0, 600, 320, 300);
    } completion:^(BOOL finished) {
        [self.view sendSubviewToBack:_overlay];
        [self.view sendSubviewToBack:fv];
    }];
}

- (void)updateFilterViewNumbers:(UIView *)fv {
    RangeSlider *ps = (RangeSlider *) [fv viewWithTag:39383736];
    [self.hotelTableViewDelegate priceSliderChanged:ps];
}
    

- (void)resetWhereToTfAppearance {
    self.whereToTextField.layer.cornerRadius = 6.0f;
    self.whereToTextField.layer.borderColor = UIColorFromRGB(0xbbbbbb).CGColor;
    self.whereToTextField.layer.borderWidth = 0.7f;
}

- (UIView *)currentViewFromState {
    switch (self.viewState) {
        case VIEW_STATE_PRE_HOTEL:
            return self.cupHolder;
            
        case VIEW_STATE_HOTELS:
            return self.hotelsTableViewContainer;
            
        case VIEW_STATE_MAP:
            return self.mkMapView;
            
        default:
            return nil;
    }
}

#pragma mark CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.mkMapView.showsUserLocation = NO;
    } else {
        self.mkMapView.showsUserLocation = YES;
    }
    
    //    [manager startUpdatingLocation];
}

#pragma mark MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (userLocation) {
        ((WotaPlace *) [SelectionCriteria singleton].placesArray.firstObject).latitude = userLocation.location.coordinate.latitude;
        ((WotaPlace *) [SelectionCriteria singleton].placesArray.firstObject).longitude = userLocation.location.coordinate.longitude;
        
        if (!_userLocationHasUpdated && [[SelectionCriteria singleton] currentLocationIsSelectedPlace] && ![SelectionCriteria singleton].googlePlaceDetail) {
            [self redrawMapViewAnimated:YES radius:[SelectionCriteria singleton].zoomRadius];
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
        self.useMapRadiusForSearch = YES;
        [self reverseGeoCodingDawg];
    }
}

@end
