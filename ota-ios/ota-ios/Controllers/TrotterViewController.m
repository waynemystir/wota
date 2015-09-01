//
//  TrotterViewController.m
//  ota-ios
//
//  Created by WAYNE SMALL on 7/17/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
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
#import "WotaButton.h"
#import "WotaTappableView.h"
#import "HotelsTableViewDelegateImplementation.h"
#import "EanHotelListResponse.h"
#import "EanHotelListHotelSummary.h"
#import "WotaMapAnnotatioin.h"
#import "BackCancelViewSmaller.h"
#import "BackCancelViewLarger.h"
#import "WotaMKPinAnnotationView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "HotelInfoViewController.h"
#import "TrotterCalendarPicker.h"
#import "ChildView.h"

typedef NS_ENUM(NSUInteger, VIEW_STATE) {
    VIEW_STATE_CRITERIA,
    VIEW_STATE_HOTELS,
    VIEW_STATE_MAP
};

static int const kTrvAutoCompleteMinimumNumberOfCharacters = 4;
double const TRV_DEFAULT_RADIUS = 5.0;
static double const TRV_METERS_PER_MILE = 1609.344;
NSTimeInterval const kTrvFlipAnimationDuration = 0.75;
NSTimeInterval const kTrvSearchModeAnimationDuration = 0.36;

@interface TrotterViewController () <CLLocationManagerDelegate, LoadDataProtocol, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, MKMapViewDelegate, ChildViewDelegate, TrotterCalendarPickerDelegate>

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
@property (nonatomic) BOOL aboutToRedrawMapViewRegion;
@property (nonatomic) BOOL currentlyRedrawingMapViewRegion;
@property (nonatomic) BOOL useMapRadiusForSearch;
@property (nonatomic) BOOL loadingGooglePlaceDetails;
@property (nonatomic, strong) NSString *tmpSelectedCellPlaceName;
@property (nonatomic, strong) NSMutableArray *openConnections;
@property (nonatomic, strong) UIView *containerViewSpinnerContainer;
@property (nonatomic) BOOL  spinnerIsSwirling;

@property (nonatomic, copy) void (^redrawMapAnnotationCompletion)(void);

@property (nonatomic) BOOL arrivalOrReturn; //arrival == NO and return == YES
@property (nonatomic) BOOL criteriaOrHotelSearchMode;

@property (nonatomic) BOOL requestAlreadyJustFailed;

@property (nonatomic, strong) HotelsTableViewDelegateImplementation *hotelTableViewDelegate;

@property (nonatomic) BOOL clickedSearchWhileAutoCompleting;
@property (nonatomic) BOOL clickedSearchWhileReverseGeocoding;
@property (nonatomic) BOOL userLocationHasUpdated;
@property (nonatomic, assign) BOOL nextRegionChangeIsFromBackButton;
@property (nonatomic, assign) BOOL nextRegionChangeIsFromUserInteraction;
@property (nonatomic) double listMaxLatitudeDelta;
@property (nonatomic) double listMaxLongitudeDelta;

@property (nonatomic, weak) UIView *currentWmapView;

#pragma mark Outlets

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
@property (weak, nonatomic) IBOutlet UIView *sortMapSearchContainer;
@property (weak, nonatomic) IBOutlet UIView *travelersContainer;
@property (weak, nonatomic) IBOutlet UILabel *tcAdultsLabel;
@property (weak, nonatomic) IBOutlet UIView *openingWhereTo;
@property (weak, nonatomic) IBOutlet UILabel *labelWhereYouGoing;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewOpeningSearch;
@property (weak, nonatomic) IBOutlet UIView *openingWmapContainer;
@property (weak, nonatomic) IBOutlet UIImageView *wmapMap;
@property (weak, nonatomic) IBOutlet BackCancelViewSmaller *wmapCancel;
@property (weak, nonatomic) IBOutlet UIImageView *wmapHamburger;
@property (weak, nonatomic) IBOutlet UIView *wmapClicker;
@property (weak, nonatomic) IBOutlet UIButton *footerDatesBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *autoCompleteSpinner;
@property (weak, nonatomic) IBOutlet UIView *mapViewContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mapSpinner;
@property (weak, nonatomic) IBOutlet UIView *mapMapSearch;
@property (weak, nonatomic) IBOutlet UIImageView *sortMapSearch;
@property (weak, nonatomic) IBOutlet UIImageView *sortImageView;
@property (weak, nonatomic) IBOutlet UIView *mapBackContainer;

#pragma mark IBActions

- (IBAction)justPushIt:(id)sender;
- (IBAction)clickKidsButton:(id)sender;
- (IBAction)findHotelsClicked:(id)sender;

@end

@implementation TrotterViewController {
    CLLocationManager *locationManager;
    BOOL filterViewUp;
    BOOL restoringWhereTo;
    BOOL restoredWhereToAlready;
    BOOL daDateChanged;
    TrotterCalendarPicker *checkInDatePicker;
    TrotterCalendarPicker *checkOutDatePicker;
    BOOL datePickerUp;
}

#pragma mark Lifecycle methods

- (id)init {
    if (self = [super initWithNibName:@"TrotterView" bundle:nil]) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        locationManager.delegate = self;
        
        if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
            [SelectionCriteria singleton].currentLocationIsSet = NO;
            [locationManager requestWhenInUseAuthorization];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewState = VIEW_STATE_CRITERIA;
    
    //**********************************************************************
    // This is needed so that this view controller (or it's nav controller?)
    // doesn't make room at the top of the table view's scroll view (I guess
    // to account for the nav bar).
    //***********************************************************************
    self.automaticallyAdjustsScrollViewInsets = NO;
    //***********************************************************************
    
    self.mkMapView.delegate = self;
    
    self.containerViewSpinnerContainer = [[UIView alloc] initWithFrame:self.view.bounds];
    self.containerViewSpinnerContainer.backgroundColor = [UIColor blackColor];
    self.containerViewSpinnerContainer.alpha = 0.0f;
    [self.view addSubview:self.containerViewSpinnerContainer];
    [self.view sendSubviewToBack:self.containerViewSpinnerContainer];
    
    UIActivityIndicatorView *theSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                                           UIActivityIndicatorViewStyleWhiteLarge];
    theSpinner.tag = 717171;
    theSpinner.center = self.containerViewSpinnerContainer.center;
    theSpinner.alpha = 0.0f;
    [self.containerViewSpinnerContainer addSubview:theSpinner];
    [self.containerViewSpinnerContainer bringSubviewToFront:theSpinner];
    
    self.autoCompleteSpinner.hidden = YES;
    
    self.placesTableView = [[UITableView alloc] initWithFrame:self.placesTableViewZeroFrame style:UITableViewStylePlain];
    self.placesTableView.backgroundColor = [UIColor whiteColor];
    self.placesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.placesTableView.separatorColor = [UIColor clearColor];
    self.placesTableView.dataSource = self;
    self.placesTableView.delegate = self;
    self.placesTableView.sectionHeaderHeight = 0.0f;
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
    
    [self setupDaTravelersView];
    
    [self setNumberOfAdultsLabel:0];
    [self setNumberOfKidsButtonLabel];
    
    [self setupDaDatePickers];
    
    self.arrivalOrReturn = NO;
    [self refreshDisplayedArrivalDate];
    [self refreshDisplayedReturnDate];
    
    UITapGestureRecognizer *fgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickFilterButton)];
    fgr.numberOfTapsRequired = 1;
    fgr.numberOfTouchesRequired = 1;
    fgr.cancelsTouchesInView = NO;
    self.filterContainer.userInteractionEnabled = YES;
    [self.filterContainer addGestureRecognizer:fgr];
    
    UITapGestureRecognizer *sgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickSortButton)];
    sgr.numberOfTapsRequired = 1;
    sgr.numberOfTouchesRequired = 1;
    sgr.cancelsTouchesInView = NO;
    self.sortMapSearchContainer.userInteractionEnabled = YES;
    [self.sortMapSearchContainer addGestureRecognizer:sgr];
    
    self.sortImageView.hidden = YES;
    
    UITapGestureRecognizer *bgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickBack:)];
    bgr.numberOfTapsRequired = 1;
    bgr.numberOfTouchesRequired = 1;
    self.backContainer.userInteractionEnabled = NO;
    [self.backContainer addGestureRecognizer:bgr];
    
    BackCancelViewSmaller *bcv = [[BackCancelViewSmaller alloc] initWithFrame:CGRectMake(0, 0, 28, 36)];
    [self.backContainer addSubview:bcv];
    
    UITapGestureRecognizer *ttgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickWmapClicker)];
    ttgr.numberOfTapsRequired = 1;
    ttgr.numberOfTouchesRequired = 1;
    self.wmapClicker.userInteractionEnabled = NO;
    [self.wmapClicker addGestureRecognizer:ttgr];
    
    UITapGestureRecognizer *ogr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dropFilterOrSortView)];
    ogr.numberOfTapsRequired = 1;
    ogr.numberOfTouchesRequired = 1;
    _overlay.userInteractionEnabled = YES;
    [_overlay addGestureRecognizer:ogr];
    _overlay.alpha = 0.0f;
    
    UITapGestureRecognizer *tcgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTravelersContainer)];
    tcgr.numberOfTapsRequired = 1;
    tcgr.numberOfTouchesRequired = 1;
    [self.travelersContainer addGestureRecognizer:tcgr];
    
    UITapGestureRecognizer *mmgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(findHotelsClicked:)];
    mmgr.numberOfTapsRequired = 1;
    mmgr.numberOfTouchesRequired = 1;
    self.mapMapSearch.userInteractionEnabled = YES;
    [self.mapMapSearch addGestureRecognizer:mmgr];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onHotelDataFiltered) name:kNotificationHotelDataFiltered object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onHotelDataSorted) name:kNotificationHotelDataSorted object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResume:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self redrawMapViewAnimated:YES radius:[SelectionCriteria singleton].zoomRadius];
    
    self.mapSpinner.hidden = YES;
    
    self.footerContainer.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, 50), 0.1f, 0.001f);
    
    UITapGestureRecognizer *wtgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(restoreWhereTo:)];
    wtgr.numberOfTapsRequired = 1;
    wtgr.numberOfTouchesRequired = 1;
    [self.openingWhereTo addGestureRecognizer:wtgr];
    
    UITapGestureRecognizer *wmgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(restoreWhereTo:)];
    wmgr.numberOfTouchesRequired = 1;
    wmgr.numberOfTapsRequired = 1;
    [self.openingWmapContainer addGestureRecognizer:wmgr];
    
    BackCancelViewSmaller *wmapBcv = [[BackCancelViewSmaller alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    self.wmapCancel = wmapBcv;
    [self.wmapCancel animateToCancel:0.001];
    self.wmapCancel.hidden = YES;
    [self.wmapContainer addSubview:self.wmapCancel];
    
    self.wmapHamburger.hidden = YES;
    self.currentWmapView = self.wmapMap;
    
    BackCancelViewLarger *mapBack = [[BackCancelViewLarger alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
    [self.mapBackContainer addSubview:mapBack];
    self.mapBackContainer.hidden = YES;
    
    UITapGestureRecognizer *mbgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickMapBack:)];
    mbgr.numberOfTapsRequired = 1;
    mbgr.numberOfTouchesRequired = 1;
    self.mapBackContainer.userInteractionEnabled = YES;
    [self.mapBackContainer addGestureRecognizer:mbgr];
    
    self.footerDatesBtn.titleLabel.minimumScaleFactor = 0.6f;
    self.footerDatesBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    [self highlightWhereTo];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    NSLog(@"%@.%@", self.class, NSStringFromSelector(_cmd));
}

#pragma mark Highlight/Restore Where To

- (void)highlightWhereTo {
    self.whereToTextField.hidden = YES;
    self.openingWhereTo.layer.cornerRadius = WOTA_CORNER_RADIUS;
    self.openingWhereTo.layer.borderColor = kWotaColorOne().CGColor;
    self.openingWhereTo.layer.borderWidth = 1.5f;
    self.openingWmapContainer.layer.cornerRadius = WOTA_CORNER_RADIUS;
    self.openingWmapContainer.layer.borderColor = kWotaColorOne().CGColor;
    self.openingWmapContainer.layer.borderWidth = 1.5f;
}

- (void)restoreWhereTo:(UITapGestureRecognizer *)tgr {
    
    if (restoredWhereToAlready) {
        return;
    }
    
    restoredWhereToAlready = YES;
    restoringWhereTo = YES;
    __weak typeof(self) wes = self;
    wes.wmapClicker.userInteractionEnabled = YES;
    
    if (tgr.view == self.openingWhereTo) {
        [wes.whereToTextField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.001];
        [wes transitionToWmapCancel];
    } else if (tgr.view == self.openingWmapContainer) {
        [wes transitionToMapView];
        [wes transitionToWmapHamburger];
        wes.whereToTextField.text = [SelectionCriteria singleton].whereToFirst;
        wes.whereToSecondLevel.text = [SelectionCriteria singleton].whereToSecond;
        wes.labelWhereYouGoing.text = [SelectionCriteria singleton].whereToFirst;
    } else if (!tgr) {
        [wes transitionToWmapMap];
        wes.whereToTextField.text = [SelectionCriteria singleton].whereToFirst;
        wes.whereToSecondLevel.text = [SelectionCriteria singleton].whereToSecond;
        wes.labelWhereYouGoing.text = [SelectionCriteria singleton].whereToFirst;
    }
    
    [UIView animateWithDuration:0.23 animations:^{
        wes.openingWhereTo.frame = CGRectMake(6, 16, 270, 30);
        wes.imageViewOpeningSearch.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
        wes.labelWhereYouGoing.frame = CGRectMake(6, 0, 270, 30);
        wes.labelWhereYouGoing.textColor = [UIColor lightGrayColor];
        wes.labelWhereYouGoing.font = [UIFont systemFontOfSize:17.0f];
        
        wes.openingWmapContainer.frame = CGRectMake(283, 16, 30, 30);
    } completion:^(BOOL finished) {
        restoringWhereTo = NO;
        wes.whereToTextField.hidden = NO;
        wes.openingWhereTo.hidden = YES;
        wes.openingWmapContainer.hidden = YES;
    }];
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
//    if (!self.criteriaOrHotelSearchMode) {
    [self nukeConnectionsAndSpinners:NO];
//    }
    self.loadingGooglePlaceDetails = YES;
    [[LoadGooglePlacesData sharedInstance:self] loadPlaceDetailsWithLatitude:self.mkMapView.region.center.latitude longitude:self.mkMapView.region.center.longitude];
//    if (!self.criteriaOrHotelSearchMode) {
        self.mapSpinner.hidden = NO;
        [self.mapSpinner startAnimating];
//    }
}

#pragma mark UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
//    [self nukeConnectionsAndSpinners:NO];
    [self clickMapBack:nil];
    self.containerView.userInteractionEnabled = YES;
    
    if (!_isPlacesTableViewExpanded) {
        [self animateTableViewExpansion];
    }
    
    [self.view bringSubviewToFront:self.wmapClicker];
    
    self.whereToTextField.text = @"";
    self.whereToSecondLevel.text = @"";
    
    self.whereToTextField.layer.cornerRadius = WOTA_CORNER_RADIUS;
    self.whereToTextField.layer.borderColor = kWotaColorOne().CGColor;
    self.whereToTextField.layer.borderWidth = 1.0f;
    
    self.clickedSearchWhileAutoCompleting = NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self.view bringSubviewToFront:self.wmapClicker];
    [self nukeConnectionsAndSpinners:NO];
    NSString *autoCompleteText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([autoCompleteText length] >= kTrvAutoCompleteMinimumNumberOfCharacters) {
        if (self.placesTableData == [SelectionCriteria singleton].placesArray) {
            self.placesTableData = [NSMutableArray array];
            [self.placesTableView reloadData];
        }
        [[LoadGooglePlacesData sharedInstance:self] autoCompleteSomePlaces:autoCompleteText];
        self.autoCompleteSpinner.hidden = NO;
        [self.autoCompleteSpinner startAnimating];
    } else {
        return [self textFieldShouldClear:textField];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view bringSubviewToFront:self.wmapClicker];
    [self animateTableViewCompression];
    
    if (self.placesTableData.count > 0) {
        [self nukeConnectionsAndSpinners:NO];
        self.whereToTextField.text = [SelectionCriteria singleton].whereToFirst;
        self.whereToSecondLevel.text = [SelectionCriteria singleton].whereToSecond;
        
        if (self.placesTableData == [SelectionCriteria singleton].placesArray) {
            if (self.placesTableData.count >= 2) {
                [self trotterDidSelectRowAtIndexPathRow:1];
            } else if (self.placesTableData.count >= 1) {
                [self trotterDidSelectRowAtIndexPathRow:0];
            } else {
                // This can't actually occur since Current Location is always there, yes
                // even if the user denied location services.
            }
        } else {
            [self trotterDidSelectRowAtIndexPathRow:0];
        }
    } else {
        self.clickedSearchWhileAutoCompleting = !self.autoCompleteSpinner.hidden;
        if (self.criteriaOrHotelSearchMode) {
            [self loadDaSpinner];
        }
    }
    
    [self.whereToTextField resignFirstResponder];
    if (self.placesTableData != [SelectionCriteria singleton].placesArray) {
        self.placesTableData = [SelectionCriteria singleton].placesArray;
        [self.placesTableView reloadData];
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self.view bringSubviewToFront:self.wmapClicker];
    if (self.placesTableData != [SelectionCriteria singleton].placesArray) {
        self.placesTableData = [SelectionCriteria singleton].placesArray;
        [self.placesTableView reloadData];
    }
    self.autoCompleteSpinner.hidden = YES;
    [self.autoCompleteSpinner stopAnimating];
    [self nukeConnectionsAndSpinners:NO];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self nukeConnectionsAndSpinners:NO];
    [self.view bringSubviewToFront:self.wmapClicker];
    [self resetWhereToTfAppearance];
}

#pragma mark LoadDataProtocol methods

- (void)requestStarted:(NSURLConnection *)connection {
    [self.openConnections addObject:connection];
    TrotterLog(@"%@.%@ loading URL:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [[[connection currentRequest] URL] absoluteString]);
}

- (void)requestFinished:(NSData *)responseData dataType:(LOAD_DATA_TYPE)dataType {
    switch (dataType) {
        case LOAD_GOOGLE_AUTOCOMPLETE: {
            self.checkHotelsOutlet.enabled = NO;
            self.mapMapSearch.userInteractionEnabled = NO;
            self.mapMapSearch.alpha = 0.3f;
            self.sortMapSearchContainer.alpha = 0.2f;
            self.sortMapSearchContainer.userInteractionEnabled = NO;
            NSArray *wes = [GoogleParser parseAutoCompleteResponse:responseData];
            if (wes) {
                self.placesTableData = [NSMutableArray arrayWithArray:wes];
                [self.placesTableView reloadData];
            } else {
//                self.placesTableData = [NSMutableArray arrayWithObject:self.whereToTextField.text];
            }
            BOOL enableFindHotels = YES;
            if (self.clickedSearchWhileAutoCompleting) {
                self.clickedSearchWhileAutoCompleting = NO;
                if (wes.count > 1) {
                    [self trotterDidSelectRowAtIndexPathRow:0];
                } else {
                    [self nukeConnectionsAndSpinners:NO];
                    enableFindHotels = NO;
                    self.mapMapSearch.userInteractionEnabled = NO;
                    self.mapMapSearch.alpha = 0.3f;
                    self.sortMapSearchContainer.alpha = 0.2f;
                    self.sortMapSearchContainer.userInteractionEnabled = NO;
                    NSString *w = [NSString stringWithFormat:@"No places were found for \"%@\". Please try again.", self.whereToTextField.text];
                    [self loadNoWhateverView:@"No Places Found" text:w];
                    [self dropDaSpinnerAlready];
                }
            }
            if (enableFindHotels) {
                self.checkHotelsOutlet.enabled = YES;
                self.mapMapSearch.userInteractionEnabled = YES;
                self.mapMapSearch.alpha = 1.0f;
                [self enableOrDisableSortMapSearchContainer];
                self.autoCompleteSpinner.hidden = YES;
                [self.autoCompleteSpinner stopAnimating];
            } else {
                self.checkHotelsOutlet.enabled = NO;
                self.mapMapSearch.userInteractionEnabled = NO;
                self.mapMapSearch.alpha = 0.3f;
                self.sortMapSearchContainer.alpha = 0.2f;
                self.sortMapSearchContainer.userInteractionEnabled = NO;
            }
            break;
        }
            
        case LOAD_GOOGLE_PLACES: {
            SelectionCriteria *sc = [SelectionCriteria singleton];
            sc.googlePlaceDetail = [GooglePlaceDetail placeDetailFromData:responseData];
            self.loadingGooglePlaceDetails = NO;
            self.useMapRadiusForSearch = NO;
//            [[SelectionCriteria singleton] savePlace:[GooglePlaceDetail placeDetailFromData:responseData]];
            self.placesTableData = [SelectionCriteria singleton].placesArray;
            [self.placesTableView reloadData];
//            [self.placesTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            self.whereToTextField.text = [SelectionCriteria singleton].whereToFirst;
            self.whereToSecondLevel.text = [SelectionCriteria singleton].whereToSecond;
            
            if (![sc.googlePlaceDetail.placeId isEqualToString:sc.selectedPlace.placeId]
                    || sc.googlePlaceDetail.zoomRadius != sc.selectedPlace.zoomRadius) {
                [self redrawMapViewAnimated:YES radius:sc.googlePlaceDetail.zoomRadius];
            } else {
                [self removeAllPinsButUserLocation];
            }
            
            if (self.criteriaOrHotelSearchMode) {
                if (!stringIsEmpty([SelectionCriteria singleton].whereToFirst)) {
                    [self itKeepsTheRainOffOurHeads];
                }
            } else {
                [self dropDaSpinnerAlready];
            }
            
            break;
        }
            
        case LOAD_GOOGLE_REVERSE_GEOCODE: {
            __weak typeof(self) wes = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [SelectionCriteria singleton].googlePlaceDetail = [GooglePlaceDetail placeDetailFromGeoCodeData:responseData];
                wes.loadingGooglePlaceDetails = NO;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    wes.mapSpinner.hidden = YES;
                    [wes.mapSpinner stopAnimating];
                    
                    if (!self.isPlacesTableViewExpanded) {
                        wes.whereToTextField.text = [SelectionCriteria singleton].whereToFirst;
                        wes.whereToSecondLevel.text = [SelectionCriteria singleton].whereToSecond;
                    }
                    
                    if (wes.clickedSearchWhileReverseGeocoding) {
                        self.clickedSearchWhileReverseGeocoding = NO;
                        if (stringIsEmpty([SelectionCriteria singleton].whereTo)) {
                            [wes showOrHideTvControls];
                            self.sortMapSearchContainer.alpha = 0.2f;
                            self.sortMapSearchContainer.userInteractionEnabled = NO;
                            [wes nukeConnectionsAndSpinners:NO];
                        } else {
                            [wes itKeepsTheRainOffOurHeads];
                        }
                    } else {
                        [wes nukeConnectionsAndSpinners:NO];
                    }
                    
                    if (stringIsEmpty([SelectionCriteria singleton].whereToFirst)) {
                        self.sortMapSearchContainer.alpha = 0.2f;
                        self.sortMapSearchContainer.userInteractionEnabled = NO;
                        self.mapMapSearch.hidden = YES;
                        self.checkHotelsOutlet.enabled = self.footerDatesBtn.enabled = NO;
                    } else {
                        self.mapMapSearch.hidden = NO;
                        self.checkHotelsOutlet.enabled = self.footerDatesBtn.enabled = YES;
                    }
                });
                
            });
            break;
        }
            
        case LOAD_EAN_HOTELS_LIST: {
            __weak typeof(self) wes = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                EanHotelListResponse *ehlr = [EanHotelListResponse eanObjectFromApiResponseData:responseData];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    wes.hotelTableViewDelegate.hotelData = ehlr.hotelList;
                    [wes showOrHideTvControls];
                    [wes.hotelsTableView reloadData];
                    [wes.hotelsTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
                    
                    wes.listMaxLatitudeDelta = ehlr.maxLatitudeDelta;
                    wes.listMaxLongitudeDelta = ehlr.maxLongitudeDelta;
                    
                    if (ehlr.hotelList.count == 0) {
                        [wes handleNoHotels];
                        [wes tydieUpAfterHotelListReturned];
                    } else {
                        [wes redrawMapAnnotationsWithCompletion:^{
                            [wes tydieUpAfterHotelListReturned];
                        }];
                        
                        if (self.spinnerIsSwirling) {
                            [wes performSelector:@selector(tydieUpAfterHotelListReturned) withObject:nil afterDelay:0.4];
                        }
                    }
                });
            });
            
        }
            
        default:
            break;
    }
}

- (void)tydieUpAfterHotelListReturned {
    [self setupTheFilterView];
    [self setupTheSortView];
    [self dropDaSpinnerAlready];
}

- (void)requestTimedOut {
    self.loadingGooglePlaceDetails = NO;
    if (self.requestAlreadyJustFailed) {
        return;
    }
    self.requestAlreadyJustFailed = YES;
    [self nukeEmAll];
    __weak typeof(self) wes = self;
    [wes animateTableViewCompression];
    [NetworkProblemResponder launchWithSuperView:self.view headerTitle:nil messageString:nil completionCallback:^{
        wes.requestAlreadyJustFailed = NO;
        if (self.placesTableData != [SelectionCriteria singleton].placesArray) {
            self.placesTableData = [SelectionCriteria singleton].placesArray;
            [self.placesTableView reloadData];
        }
    }];
}

- (void)requestFailedOffline {
    self.loadingGooglePlaceDetails = NO;
    if (self.requestAlreadyJustFailed) {
        return;
    }
    self.requestAlreadyJustFailed = YES;
    [self nukeEmAll];
    __weak typeof(self) wes = self;
    [wes animateTableViewCompression];
    [NetworkProblemResponder launchWithSuperView:self.view headerTitle:@"Network Error" messageString:@"The network could not be reached. Please check your connection and try again." completionCallback:^{
        wes.requestAlreadyJustFailed = NO;
        if (self.placesTableData != [SelectionCriteria singleton].placesArray) {
            self.placesTableData = [SelectionCriteria singleton].placesArray;
            [self.placesTableView reloadData];
        }
    }];
}

- (void)requestFailedCredentials {
    self.loadingGooglePlaceDetails = NO;
    if (self.requestAlreadyJustFailed) {
        return;
    }
    self.requestAlreadyJustFailed = YES;
    [self nukeEmAll];
    __weak typeof(self) wes = self;
    [wes animateTableViewCompression];
    [NetworkProblemResponder launchWithSuperView:self.view headerTitle:@"System Error" messageString:@"Sorry for the inconvenience. We are experiencing a technical issue. Please try again shortly." completionCallback:^{
        wes.requestAlreadyJustFailed = NO;
        if (self.placesTableData != [SelectionCriteria singleton].placesArray) {
            self.placesTableData = [SelectionCriteria singleton].placesArray;
            [self.placesTableView reloadData];
        }
    }];
}

#pragma mark Nuke Em

- (void)nukeConnectionsAndSpinners:(BOOL)withForce {
    self.loadingGooglePlaceDetails = NO;
    if (self.clickedSearchWhileAutoCompleting && !withForce) {
        return;
    }
    
    [self dropDaSpinnerAlready];
    self.mapSpinner.hidden = YES;
    [self.mapSpinner stopAnimating];
    [self.openConnections makeObjectsPerformSelector:@selector(cancel)];
    [self.openConnections removeAllObjects];
}

- (void)nukeEmAll {
    [self clickMapBack:nil];
    self.autoCompleteSpinner.hidden = YES;
    [self.autoCompleteSpinner stopAnimating];
    self.clickedSearchWhileAutoCompleting = NO;
    self.clickedSearchWhileReverseGeocoding = NO;
    self.containerView.userInteractionEnabled = YES;
    self.whereToTextField.text = [SelectionCriteria singleton].whereToFirst;
    self.whereToSecondLevel.text = [SelectionCriteria singleton].whereToSecond;
    [self showOrHideTvControls];
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
    [self trotterDidSelectRowAtIndexPathRow:indexPath.row];
}

- (void)trotterDidSelectRowAtIndexPathRow:(NSInteger)indexPathRow {
    if ([self.placesTableData[indexPathRow] isKindOfClass:[NSString class]]) {
        return;
    }
    
    if ([self.placesTableData[indexPathRow] isKindOfClass:[GooglePlace class]]) {
        self.mapBackContainer.hidden = YES;
        GooglePlace *gp = self.placesTableData[indexPathRow];
        self.loadingGooglePlaceDetails = YES;
        self.whereToTextField.text = self.tmpSelectedCellPlaceName = [gp.placeName componentsSeparatedByString:@","].firstObject;
        [self.whereToTextField resignFirstResponder];
        [[LoadGooglePlacesData sharedInstance:self] loadPlaceDetails:gp.placeId];
        self.placesTableData = [SelectionCriteria singleton].placesArray;
        [self.placesTableView reloadData];
        [self animateTableViewCompression];
        if (self.criteriaOrHotelSearchMode) {
            [self loadDaSpinner];
        }
        self.useMapRadiusForSearch = NO;
    } else if ([self.placesTableData[indexPathRow] isKindOfClass:[WotaPlace class]]) {
        self.placesTableData = [SelectionCriteria singleton].placesArray;
        [self.placesTableView reloadData];
        [self.whereToTextField resignFirstResponder];
//        [SelectionCriteria singleton].googlePlaceDetail = nil;
        
        BOOL weveGotLocationIssues = indexPathRow == 0 && ![SelectionCriteria singleton].currentLocationIsSet;
        if (weveGotLocationIssues) {
            [self loadLocationNotAvailableView];
        } else if ([SelectionCriteria singleton].selectedPlace != self.placesTableData[indexPathRow]
                || [SelectionCriteria singleton].googlePlaceDetail) {
            [SelectionCriteria singleton].googlePlaceDetail = nil;
            [SelectionCriteria singleton].selectedPlace = self.placesTableData[indexPathRow];
            [self redrawMapViewAnimated:YES radius:[SelectionCriteria singleton].selectedPlace.zoomRadius];
        }/*else if (self.mkMapView.region.center.latitude != [SelectionCriteria singleton].latitude
                   || self.mkMapView.region.center.longitude != [SelectionCriteria singleton].longitude) {
            [self redrawMapViewAnimated:YES radius:[SelectionCriteria singleton].selectedPlace.zoomRadius];
        }*/ else {
            [self removeAllPinsButUserLocation];
        }
        
        self.whereToTextField.text = [SelectionCriteria singleton].whereToFirst;
        self.whereToSecondLevel.text = [SelectionCriteria singleton].whereToSecond;
        [self animateTableViewCompression];
        
        self.useMapRadiusForSearch = NO;
        
        if (self.criteriaOrHotelSearchMode && !weveGotLocationIssues) {
            self.mapBackContainer.hidden = YES;
            [self itKeepsTheRainOffOurHeads];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.5f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    return [[UIView alloc] initWithFrame:CGRectZero];
    
    UIView *topSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0.5f)];
    topSeparator.backgroundColor = UIColorFromRGB(0xbbbbbb);
    [self.placesTableView addSubview:topSeparator];
    return topSeparator;
}

#pragma mark Some animation methods

- (void)animateTableViewExpansion {
    __weak UIView *actv = self.placesTableView;
    [self.view bringSubviewToFront:actv];
//    if (restoringWhereTo) {
        [self.view bringSubviewToFront:self.whereToContainer];
//    }
    
    [self transitionToWmapCancel];
    
    self.isPlacesTableViewExpanded = YES;
    [UIView animateWithDuration:self.animationDuraton animations:^{
        actv.frame = self.placesTableViewExpandedFrame;
    } completion:^(BOOL finished) {
    }];
}

- (void)animateTableViewCompression {
    
//    self.autoCompleteSpinner.hidden = YES;
//    [self.autoCompleteSpinner stopAnimating];
    
    switch (self.viewState) {
        case VIEW_STATE_CRITERIA: {
            [self transitionToWmapMap];
            break;
        }
            
        case VIEW_STATE_MAP: {
            [self transitionToWmapHamburger];
            break;
        }
            
        case VIEW_STATE_HOTELS: {
            [self transitionToWmapMap];
            break;
        }
            
        default:
            break;
    }
    
    __weak typeof(self) wes = self;
    __weak UIView *actv = self.placesTableView;
    [wes.view bringSubviewToFront:actv];
    self.isPlacesTableViewExpanded = NO;
    
    [UIView animateWithDuration:self.animationDuraton animations:^{
        actv.frame = self.placesTableViewZeroFrame;
    } completion:^(BOOL finished) {
        [wes.view sendSubviewToBack:actv];
    }];
}

- (void)transitionToMapView {
    
    [self.view endEditing:YES];
    
    __weak typeof(self) wes = self;
    __weak UIView *cv = [self currentViewFromState];
    __weak UIView *sv = [self currentSortOrMapSearchViewFromState];
    
    [UIView transitionFromView:cv
                        toView:wes.mapViewContainer
                      duration:kTrvFlipAnimationDuration
                       options:UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionAllowAnimatedContent
                    completion:^(BOOL finished) {
                        wes.viewState = VIEW_STATE_MAP;
                    }];
    
    [UIView transitionFromView:sv
                        toView:wes.sortMapSearch
                      duration:kTrvFlipAnimationDuration
                       options:UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionAllowAnimatedContent completion:^(BOOL finished) {
                           ;
                       }];
    
    if (stringIsEmpty([SelectionCriteria singleton].whereToFirst)) {
        self.sortMapSearchContainer.alpha = 0.2f;
        self.sortMapSearchContainer.userInteractionEnabled = NO;
    } else {
        self.sortMapSearchContainer.alpha = 1.0f;
        self.sortMapSearchContainer.userInteractionEnabled = YES;
    }
}

- (void)transiTionToCriteriaView {
    
    __weak typeof(self) wes = self;
    __weak UIView *cv = [self currentViewFromState];
    __weak UIView *sv = [self currentSortOrMapSearchViewFromState];
    
    [UIView transitionFromView:cv
                        toView:wes.cupHolder
                      duration:kTrvFlipAnimationDuration
                       options:UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionAllowAnimatedContent
                    completion:^(BOOL finished) {
                        wes.viewState = VIEW_STATE_CRITERIA;
                    }];
    
    [UIView transitionFromView:sv
                        toView:wes.sortMapSearch
                      duration:kTrvFlipAnimationDuration
                       options:UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionAllowAnimatedContent completion:^(BOOL finished) {
                           ;
                       }];
}

- (void)transitionToTableView {
    
    __weak typeof(self) wes = self;
    __weak UIView *cv = [self currentViewFromState];
    [self.containerView bringSubviewToFront:self.hotelsTableViewContainer];
    __weak UIView *sv = [self currentSortOrMapSearchViewFromState];
    
    [UIView transitionFromView:cv
                        toView:wes.hotelsTableViewContainer
                      duration:kTrvFlipAnimationDuration
                       options:UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionAllowAnimatedContent
                    completion:^(BOOL finished) {
                        wes.viewState = VIEW_STATE_HOTELS;
                    }];
    
    [UIView transitionFromView:sv
                        toView:wes.sortImageView
                      duration:kTrvFlipAnimationDuration
                       options:UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionAllowAnimatedContent completion:^(BOOL finished) {
                           ;
                       }];
    
    if (self.hotelTableViewDelegate.hotelData.count == 0) {
        self.sortMapSearchContainer.alpha = 0.2f;
        self.sortMapSearchContainer.userInteractionEnabled = NO;
    } else {
        self.sortMapSearchContainer.alpha = 1.0f;
        self.sortMapSearchContainer.userInteractionEnabled = YES;
    }
}

- (void)transitionToHotelSearchMode {
    
    self.criteriaOrHotelSearchMode = YES;
    self.backContainer.userInteractionEnabled = YES;
    self.wmapClicker.userInteractionEnabled = NO;
    __weak typeof(self) wes = self;
    
    [self restoreWhereTo:nil];
    
    [UIView animateWithDuration:kTrvFlipAnimationDuration animations:^{
        wes.containerView.frame = wes.containerViewFrame;
        wes.whereToContainer.frame = CGRectMake(0, 20, 320, 49);
        wes.autoCompleteSpinner.frame = CGRectMake(224, 19, 20, 20);
        wes.whereToTextField.frame = CGRectMake(32, 14, 244, 30);
        wes.whereToSecondLevel.frame = CGRectMake(39, 15, 232, 21);
        wes.wmapContainer.frame = CGRectMake(283, 14, 30, 30);
        wes.wmapClicker.frame = CGRectMake(273, 20, 48, 66);
        wes.backContainer.frame = CGRectMake(0, 11, 33, 33);
        wes.footerContainer.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        wes.mapMapSearch.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
    } completion:^(BOOL finished) {
        wes.mapMapSearch.hidden = YES;
        if (!wes.spinnerIsSwirling) {
            wes.wmapClicker.userInteractionEnabled = YES;
        }
    }];
}

- (void)transitionToCriteriaMode {
    
    self.criteriaOrHotelSearchMode = NO;
    self.backContainer.userInteractionEnabled = NO;
    __weak typeof(self) wes = self;
    wes.mapMapSearch.hidden = stringIsEmpty([SelectionCriteria singleton].whereToFirst);
    wes.mapMapSearch.userInteractionEnabled = YES;
    wes.mapMapSearch.alpha = 1.0f;
    
    [UIView animateWithDuration:kTrvFlipAnimationDuration animations:^{
        wes.containerView.frame = wes.containerViewFrame;
        wes.whereToContainer.frame = CGRectMake(0, 52, 320, 66);
        wes.autoCompleteSpinner.frame = CGRectMake(224, 21, 20, 20);
        wes.whereToTextField.frame = CGRectMake(6, 16, 270, 30);
        wes.whereToSecondLevel.frame = CGRectMake(13, 45, 295, 21);
        wes.wmapContainer.frame = CGRectMake(283, 16, 30, 30);
        wes.wmapClicker.frame = CGRectMake(273, 52, 48, 66);
        wes.backContainer.frame = CGRectMake(2, 13, 33, 33);
        wes.footerContainer.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, 50), 0.1f, 0.001f);
        wes.mapMapSearch.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    } completion:^(BOOL finished) {
        [wes.view bringSubviewToFront:wes.wmapClicker];
        [wes removeAllPinsButUserLocation];
    }];
}

- (void)transitionToWmapHamburger {
    
    UIView *wayne = self.currentWmapView;
    self.currentWmapView = self.wmapHamburger;
    
    if (wayne == self.wmapHamburger) {
        return;
    }
    
    __weak typeof(self) wes = self;
    
    [UIView transitionFromView:wayne
                        toView:wes.wmapHamburger
                      duration:kTrvFlipAnimationDuration
                       options:UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionAllowAnimatedContent
                    completion:^(BOOL finished) {
                        [wes.whereToContainer bringSubviewToFront:wes.wmapClicker];
                    }];
}

- (void)transitionToWmapCancel {
    
    UIView *wayne = self.currentWmapView;
    self.currentWmapView = self.wmapCancel;
    
    if (wayne == self.wmapCancel) {
        return;
    }
    
    __weak typeof(self) wes = self;
    
    [UIView transitionFromView:wayne
                        toView:wes.wmapCancel
                      duration:kTrvFlipAnimationDuration
                       options:UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionAllowAnimatedContent
                    completion:^(BOOL finished) {
                        [wes.whereToContainer bringSubviewToFront:wes.wmapClicker];
                    }];
}

- (void)transitionToWmapMap {
    
    UIView *wayne = self.currentWmapView;
    self.currentWmapView = self.wmapMap;
    
    if (wayne == self.wmapMap) {
        return;
    }
    
    __weak typeof(self) wes = self;
    
    [UIView transitionFromView:wayne
                        toView:wes.wmapMap
                      duration:kTrvFlipAnimationDuration
                       options:UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionAllowAnimatedContent
                    completion:^(BOOL finished) {
                        [wes.whereToContainer bringSubviewToFront:wes.wmapClicker];
                    }];
}

- (void)loadNoWhateverView:(NSString *)title text:(NSString *)text {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"NoHotelsView" owner:self options:nil];
    __block UIView *nhv = views.firstObject;
    nhv.frame = CGRectMake(15, 210, 290, 165);
    nhv.layer.cornerRadius = WOTA_CORNER_RADIUS;
    nhv.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
    
    WotaButton *ok = (WotaButton *)[nhv viewWithTag:471395];
    [ok addTarget:self action:@selector(okToNoHotels:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nhv];
    
    UILabel *tt = (UILabel *)[nhv viewWithTag:428642];
    UILabel *tx = (UILabel *)[nhv viewWithTag:971379];
    tt.text = title ? : tt.text;
    tx.text = text ? : tx.text;
    
    UIView *ov = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    ov.tag = 14942484;
    ov.backgroundColor = [UIColor blackColor];
    ov.alpha = 0.0;
    ov.userInteractionEnabled = YES;
    [self.view addSubview:ov];
    
    [self.view bringSubviewToFront:ov];
    [self.view bringSubviewToFront:nhv];
    __weak typeof(self) wes = self;
    [UIView animateWithDuration:0.2 animations:^{
        nhv.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        ov.alpha = 0.7f;
    } completion:^(BOOL finished) {
        [wes performSelector:@selector(dropDaSpinnerAlready) withObject:nil afterDelay:0.1];
        [wes performSelector:@selector(dropDaSpinnerAlready) withObject:nil afterDelay:0.2];
    }];
}

- (void)loadLocationNotAvailableView {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"LocationNotAvailableView" owner:self options:nil];
    UIView *lnav = views.firstObject;
    lnav.frame = CGRectMake(15, 210, 290, 197);
    lnav.layer.cornerRadius = WOTA_CORNER_RADIUS;
    lnav.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
    
    WotaButton *okb = (WotaButton *)[lnav viewWithTag:471395];
    [okb addTarget:self action:@selector(dropLocationNotAvailableView:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:lnav];
    
    UIView *ov = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    ov.tag = 14942484;
    ov.backgroundColor = [UIColor blackColor];
    ov.alpha = 0.0;
    ov.userInteractionEnabled = YES;
    [self.view addSubview:ov];
    
    [self.view bringSubviewToFront:ov];
    [self.view bringSubviewToFront:lnav];
//    __weak typeof(self) wes = self;
    [UIView animateWithDuration:0.2 animations:^{
        lnav.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        ov.alpha = 0.7f;
    } completion:^(BOOL finished) {
//        [wes performSelector:@selector(dropDaSpinnerAlready) withObject:nil afterDelay:0.1];
//        [wes performSelector:@selector(dropDaSpinnerAlready) withObject:nil afterDelay:0.2];
    }];
}

- (void)dropLocationNotAvailableView:(WotaButton *)wb {
    __weak UIView *lnav = wb.superview;
    __weak UIView *ov = [self.view viewWithTag:14942484];
    [UIView animateWithDuration:0.2 animations:^{
        lnav.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
        ov.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [lnav removeFromSuperview];
        [ov removeFromSuperview];
    }];
}

#pragma mark Various methods likely called by sublclasses

//- (void)redrawMapAnnotationsAndRegion:(BOOL)redrawRegion {
//    if (redrawRegion) {
//        double spanLat = _listMaxLatitudeDelta*2.50;
//        double spanLon = _listMaxLongitudeDelta*2.50;
//        MKCoordinateSpan span = MKCoordinateSpanMake(spanLat, spanLon);
//        MKCoordinateRegion viewRegion = MKCoordinateRegionMake(self.zoomLocation, span);
//        
//        [self.mkMapView setRegion:viewRegion animated:self.viewState == VIEW_STATE_MAP];
//        [self.mkMapView setNeedsDisplay];
//    }
//    
//    [self removeAllPinsButUserLocation];
//    
//    for (int j = 0; j < [_hotelTableViewDelegate.currentHotelData count]; j++) {
//        EanHotelListHotelSummary *hotel = [_hotelTableViewDelegate.currentHotelData objectAtIndex:j];
//        WotaMapAnnotatioin *annotation = [[WotaMapAnnotatioin alloc] init];
//        annotation.coordinate = CLLocationCoordinate2DMake(hotel.latitude, hotel.longitude);
//        NSString *imageUrlString = [@"http://images.travelnow.com" stringByAppendingString:hotel.thumbNailUrlEnhanced];
//        annotation.imageUrl = imageUrlString;
//        
//        annotation.rowNUmber = j;
//        annotation.title = hotel.hotelNameFormatted;
//        NSNumberFormatter *cf = kPriceRoundOffFormatter(hotel.rateCurrencyCode);
//        annotation.subtitle = [NSString stringWithFormat:@"From %@/night", [cf stringFromNumber:hotel.lowRate]];
//        [self.mkMapView addAnnotation:annotation];
//    }
//}

- (void)redrawMapAnnotationsWithCompletion:(void (^)(void))completion {
    [self removeAllPinsButUserLocation];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
//            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mkMapView addAnnotation:annotation];
//            });
        }
//    });
    
    if (!self.currentlyRedrawingMapViewRegion && completion) {
        completion();
    } else {
        self.redrawMapAnnotationCompletion = completion;
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
    self.currentlyRedrawingMapViewRegion = YES;
    [self removeAllPinsButUserLocation];
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
}

- (void)loadDaSpinner {
    if (self.spinnerIsSwirling) {
        return;
    }
    
    self.spinnerIsSwirling = YES;
    [self.view sendSubviewToBack:self.wmapClicker];
    [self.view bringSubviewToFront:self.containerViewSpinnerContainer];
    __weak UIView *sc = self.containerViewSpinnerContainer;
    __weak UIActivityIndicatorView *sp = (UIActivityIndicatorView *)[sc viewWithTag:717171];
    [sp startAnimating];
    
    [UIView animateWithDuration:0.2 animations:^{
        sc.alpha = 0.8f;
        sp.alpha = 1.0f;
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)dropDaSpinnerAlready {
    if (!self.spinnerIsSwirling) {
        return;
    }
    
    self.spinnerIsSwirling = NO;
    __weak UIView *sc = self.containerViewSpinnerContainer;
    __weak UIActivityIndicatorView *sp = (UIActivityIndicatorView *)[sc viewWithTag:717171];
    __weak typeof(self) wes = self;
    wes.wmapClicker.userInteractionEnabled = YES;
    [wes.view bringSubviewToFront:wes.wmapClicker];
    
    [UIView animateWithDuration:0.2 animations:^{
        sc.alpha = 0.0f;
        sp.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [wes.view sendSubviewToBack:sc];
        [sp stopAnimating];
    }];
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

- (CGRect)containerViewFrame {
    return self.criteriaOrHotelSearchMode ? CGRectMake(0, 74, 320, 450) : CGRectMake(0, 118, 320, 450);
}

- (CGRect)placesTableViewZeroFrame {
    return self.criteriaOrHotelSearchMode ? CGRectMake(0, 64, 320, 0) : CGRectMake(0, 98, 320, 0);
}

- (CGRect)placesTableViewExpandedFrame {
    return self.criteriaOrHotelSearchMode ? CGRectMake(0, 64, 320, 288) : CGRectMake(0, 98, 320, 254);
}

#pragma mark Various events and such

- (void)clickBack:(id)sender {
    [self transiTionToCriteriaView];
    self.viewState = VIEW_STATE_CRITERIA;
    [self transitionToCriteriaMode];
    
    self.mapBackContainer.hidden = YES;
    [self.view endEditing:YES];
    [self animateTableViewCompression];
    self.whereToTextField.text = [SelectionCriteria singleton].whereToFirst;
    self.whereToSecondLevel.text = [SelectionCriteria singleton].whereToSecond;
    if (self.placesTableData != [SelectionCriteria singleton].placesArray) {
        self.placesTableData = [SelectionCriteria singleton].placesArray;
        [self.placesTableView reloadData];
    }
    [self nukeConnectionsAndSpinners:YES];
}

- (void)clickWmapClicker {
    if (self.isPlacesTableViewExpanded) {
        [self.view endEditing:YES];
        [self animateTableViewCompression];
        self.autoCompleteSpinner.hidden = YES;
        [self.autoCompleteSpinner stopAnimating];
        self.whereToTextField.text = [SelectionCriteria singleton].whereToFirst;
        self.whereToSecondLevel.text = [SelectionCriteria singleton].whereToSecond;
        if (self.placesTableData != [SelectionCriteria singleton].placesArray) {
            self.placesTableData = [SelectionCriteria singleton].placesArray;
            [self.placesTableView reloadData];
        }
        [self nukeConnectionsAndSpinners:NO];
        return;
    }
    
    switch (self.viewState) {
        case VIEW_STATE_CRITERIA: {
            [self transitionToMapView];
            [self transitionToWmapHamburger];
            break;
        }
            
        case VIEW_STATE_MAP: {
            if (self.criteriaOrHotelSearchMode) {
                [self transitionToTableView];
            } else {
                [self transiTionToCriteriaView];
            }
            [self transitionToWmapMap];
            break;
        }
            
        case VIEW_STATE_HOTELS: {
            [self transitionToMapView];
            [self transitionToWmapHamburger];
            break;
        }
            
        default:
            break;
    }
}

- (void)clickMapBack:(UITapGestureRecognizer *)sender {
    [self nukeConnectionsAndSpinners:YES];
    
    if (self.mapBackContainer.hidden && !self.aboutToRedrawMapViewRegion) {
        return;
    }
    
    self.mapBackContainer.hidden = YES;
    self.mapMapSearch.userInteractionEnabled = NO;
    self.mapMapSearch.alpha = 0.3f;
    self.sortMapSearchContainer.alpha = 0.2f;
    self.sortMapSearchContainer.userInteractionEnabled = NO;
    
    self.containerView.userInteractionEnabled = NO;
    SelectionCriteria *sc = [SelectionCriteria singleton];
    sc.googlePlaceDetail = nil;
    self.whereToTextField.text = sc.whereToFirst;
    self.whereToSecondLevel.text = sc.whereToSecond;
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = sc.latitude;
    zoomLocation.longitude= sc.longitude;
    
    self.currentlyRedrawingMapViewRegion = YES;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 1.6*sc.zoomRadius*TRV_METERS_PER_MILE, 1.6*sc.zoomRadius*TRV_METERS_PER_MILE);
    self.nextRegionChangeIsFromBackButton = YES;
    [self.mkMapView setRegion:viewRegion animated:YES];
}

- (void)itKeepsTheRainOffOurHeads {
    if (stringIsEmpty([SelectionCriteria singleton].whereToFirst)) {
        [self nukeConnectionsAndSpinners:NO];
        return;
    }
    
    if (self.useMapRadiusForSearch) {
        [SelectionCriteria singleton].zoomRadius = self.mapRadiusInMiles;
    }
    
    [self loadDaSpinner];
    UITextField *tf = (UITextField *) [_hotelsTableView.tableHeaderView viewWithTag:41414141];
    tf.text = @"";
    self.hotelTableViewDelegate.hotelData = [NSArray array];
    [self.hotelsTableView reloadData];
    self.mapBackContainer.hidden = YES;
    [self letsFindHotelsWithSearchRadius:[SelectionCriteria singleton].zoomRadius];
}

- (IBAction)justPushIt:(id)sender {
    if (sender == self.arrivalDateOutlet) {
        self.arrivalOrReturn = NO;
        [self loadDatePicker];
    } else if (sender == self.footerDatesBtn) {
        self.arrivalOrReturn = NO;
        [self loadDatePicker];
    } else if (sender == self.returnDateOutlet) {
        self.arrivalOrReturn = YES;
        [self loadDatePicker];
    } else {
        TrotterLog(@"Dude we've got a problem");
    }
}

- (IBAction)clickKidsButton:(id)sender {
    [self presentKidsSelector];
}

- (IBAction)findHotelsClicked:(id)sender {
    if (!self.autoCompleteSpinner.hidden) {
        self.clickedSearchWhileAutoCompleting = YES;
        [self loadDaSpinner];
        UITextField *tf = (UITextField *) [_hotelsTableView.tableHeaderView viewWithTag:41414141];
        tf.text = @"";
        self.hotelTableViewDelegate.hotelData = [NSArray array];
        [self.hotelsTableView reloadData];
    } else if (!self.loadingGooglePlaceDetails) {
        if ([SelectionCriteria singleton].currentLocationIsSelectedPlace
            && ![SelectionCriteria singleton].currentLocationIsSet
            && ![SelectionCriteria singleton].googlePlaceDetail) {
            [self loadLocationNotAvailableView];
        } else if (!stringIsEmpty([SelectionCriteria singleton].whereToFirst)) {
            [self itKeepsTheRainOffOurHeads];
        } else {
            self.hotelTableViewDelegate.hotelData = [NSArray array];
            [self.hotelsTableView reloadData];
        }
    } else {
        self.clickedSearchWhileReverseGeocoding = YES;
        [self loadDaSpinner];
        UITextField *tf = (UITextField *) [_hotelsTableView.tableHeaderView viewWithTag:41414141];
        tf.text = @"";
        self.hotelTableViewDelegate.hotelData = [NSArray array];
        [self.hotelsTableView reloadData];
    }
    
    [self transitionToHotelSearchMode];
    if ([sender isKindOfClass:[WotaButton class]]) {
        [self transitionToTableView];
    }
}

- (IBAction)clickMinusBtn:(id)sender {
    [self setNumberOfAdultsLabel:-1];
}

- (IBAction)clickPlusBtn:(id)sender {
    [self setNumberOfAdultsLabel:1];
}

- (void)setNumberOfAdultsLabel:(NSInteger)change {
    SelectionCriteria *sc = [SelectionCriteria singleton];
    
    if (sc.numberOfAdults > 1 || change > 0) {
        sc.numberOfAdults += change;
    }
    
    UIView *travelersView = [self.view viewWithTag:434147];
    WotaButton *tcMinusBtn = (WotaButton *)[travelersView viewWithTag:191901];
    
    if (sc.numberOfAdults <= 1) {
        _minusAdultOutlet.enabled = tcMinusBtn.enabled = NO;
    } else if (sc.numberOfAdults > 1) {
        _minusAdultOutlet.enabled = tcMinusBtn.enabled = YES;
    }
    
    if (sc.numberOfAdults > 10) {
        // TODO: disable add button
    }
    
    NSString *plural = sc.numberOfAdults == 1 ? @"" : @"s";
    NSString *wes = [NSString stringWithFormat:@"%lu Adult%@", (unsigned long)sc.numberOfAdults, plural];
    _adultsLabel.text = wes;
    _tcAdultsLabel.text = [NSString stringWithFormat:@"%lu", ((unsigned long)sc.numberOfAdults + (unsigned long)[ChildTraveler numberOfKids])];
    
    UILabel *tvAdultsLabel = (UILabel *)[travelersView viewWithTag:191902];
    tvAdultsLabel.text = wes;
}

- (void)presentKidsSelector {
//    if (!childView) {
//        childView = [ChildView childViewFromNib];
//        childView.childViewDelegate = self;
//        [self.view addSubview:childView];
//    }
//    [childView loadChildView];
    
    ChildView *cv = [ChildView childViewFromNib];
    cv.childViewDelegate = self;
    [self.view addSubview:cv];
    [cv loadChildView];
}

- (void)setNumberOfKidsButtonLabel {
    NSUInteger numberOfKids = [ChildTraveler numberOfKids];
    NSString *plural = numberOfKids == 1 ? @"Child" : @"Children";
    id numbKids = numberOfKids == 0 ? @"Add" : [NSString stringWithFormat:@"%lu", (unsigned long) numberOfKids];
    NSString *buttonText = [NSString stringWithFormat:@"%@ %@", numbKids, plural];
    [self.kidsButton setTitle:buttonText forState:UIControlStateNormal];
    
    UIView *travelersView = [self.view viewWithTag:434147];
    WotaButton *akb = (WotaButton *)[travelersView viewWithTag:191904];
    [akb setTitle:buttonText forState:UIControlStateNormal];
    
    _tcAdultsLabel.text = [NSString stringWithFormat:@"%lu", ((unsigned long)[SelectionCriteria singleton].numberOfAdults + (unsigned long)[ChildTraveler numberOfKids])];
}

- (void)onHotelDataFiltered {
    [_hotelsTableView reloadData];
    [_hotelsTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self redrawMapAnnotationsWithCompletion:nil];
}

- (void)letsSortYo:(UITapGestureRecognizer *)tgr {
    [self.hotelTableViewDelegate letsSortYo:tgr];
    [self dropSortView];
}

- (void)onHotelDataSorted {
    [_hotelsTableView reloadData];
    [_hotelsTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self redrawMapAnnotationsWithCompletion:nil];
}

#pragma mark Various Date Picker methods

- (void)setupDaDatePickers {
    checkInDatePicker = [TrotterCalendarPicker calendarFromNib];
    checkOutDatePicker = [TrotterCalendarPicker calendarFromNib];
    checkInDatePicker.arrivalOrDepartureString = @"Check-in Date";
    checkOutDatePicker.arrivalOrDepartureString = @"Check-out Date";
    [self.view addSubview:checkInDatePicker];
    [self.view addSubview:checkOutDatePicker];
    
    checkInDatePicker.calendarDelegate = self;
    [checkInDatePicker setAllowClearDate:NO];
    [checkInDatePicker setClearAsToday:NO];
    [checkInDatePicker setAutoCloseOnSelectDate:YES];
    [checkInDatePicker setAllowSelectionOfSelectedDate:YES];
    [checkInDatePicker setDisableHistorySelection:YES];
    [checkInDatePicker setDisableFutureSelection:NO];
    [checkInDatePicker setSelectedBackgroundColor:kWotaColorOne()];
    [checkInDatePicker setCurrentDateColor:kWotaColorOne()];
    
    checkOutDatePicker.calendarDelegate = self;
    [checkOutDatePicker setAllowClearDate:NO];
    [checkOutDatePicker setClearAsToday:NO];
    [checkOutDatePicker setAutoCloseOnSelectDate:YES];
    [checkOutDatePicker setAllowSelectionOfSelectedDate:YES];
    [checkOutDatePicker setDisableHistorySelection:YES];
    [checkOutDatePicker setDisableFutureSelection:NO];
    [checkOutDatePicker setSelectedBackgroundColor:kWotaColorOne()];
    [checkOutDatePicker setCurrentDateColor:kWotaColorOne()];
}

- (void)loadDatePicker {
    __weak TrotterCalendarPicker *tcp = nil;
    
    if (!_arrivalOrReturn) {
        tcp = checkInDatePicker;
        tcp.dwaDate = [SelectionCriteria singleton].arrivalDate;
        tcp.minDate = [NSDate date];
        tcp.maxDate = kAddDays(500, [NSDate date]);
    } else {
        tcp = checkOutDatePicker;
        tcp.dwaDate = [SelectionCriteria singleton].returnDate;
        tcp.minDate = kAddDays(1, [SelectionCriteria singleton].arrivalDate);
        tcp.maxDate = kAddDays(28, [SelectionCriteria singleton].arrivalDate);
    }
    
    [tcp redraw];
    [tcp loadDatePicker];
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
    
    NSString *sdArr = [kShortDateFormatter() stringFromDate:sc.arrivalDate];
    NSString *sdRet = [kShortDateFormatter() stringFromDate:sc.returnDate];
    [_footerDatesBtn setTitle:[NSString stringWithFormat:@"%@ - %@", sdArr, sdRet] forState:UIControlStateNormal];
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
    
    NSString *sdArr = [kShortDateFormatter() stringFromDate:sc.arrivalDate];
    NSString *sdRet = [kShortDateFormatter() stringFromDate:sc.returnDate];
    [_footerDatesBtn setTitle:[NSString stringWithFormat:@"%@ - %@", sdArr, sdRet] forState:UIControlStateNormal];
}

#pragma mark TrotterCalendarPickerDelegate Methods

- (void)calendarPickerCancelled {
    
}

- (void)calendarPickerDidSelectDate:(NSDate *)selectedDate {
    daDateChanged = YES;
    if (!_arrivalOrReturn) {
        [SelectionCriteria singleton].arrivalDate = selectedDate;
        [self refreshDisplayedArrivalDate];
    } else {
        [SelectionCriteria singleton].returnDate = selectedDate;
        [self refreshDisplayedReturnDate];
    }
    
    TrotterLog(@"Date selected: %@",[kPrettyDateFormatter() stringFromDate:selectedDate]);
}

- (void)calendarPickerDonePressed {
    
}

- (void)calendarPickerDidHide {
    if (!self.criteriaOrHotelSearchMode) {
        daDateChanged = NO;
    } else if (!_arrivalOrReturn) {
        _arrivalOrReturn = YES;
        [self loadDatePicker];
    } else if (daDateChanged) {
        daDateChanged = NO;
        if ([SelectionCriteria singleton].currentLocationIsSelectedPlace
            && ![SelectionCriteria singleton].currentLocationIsSet) {
            [self loadLocationNotAvailableView];
        } else {
            [self removeAllPinsButUserLocation];
            [self findHotelsClicked:nil];
            self.mapBackContainer.hidden = YES;
        }
    }
}

#pragma mark ChildViewDelegate methods

- (void)childViewCancelled {
    [self setNumberOfKidsButtonLabel];
}

- (void)childViewDonePressed {
    [self setNumberOfKidsButtonLabel];
}

- (void)didHideChildView:(ChildView *)childView {
    [childView removeFromSuperview];
}

#pragma mark No hotels

- (void)handleNoHotels {
    [self dropDaSpinnerAlready];
    [self showOrHideTvControls];
    [self loadNoWhateverView:nil text:nil];
}

- (void)okToNoHotels:(WotaButton *)wb {
    self.checkHotelsOutlet.enabled = YES;
    self.mapMapSearch.userInteractionEnabled = YES;
    self.mapMapSearch.alpha = 1.0f;
    [self enableOrDisableSortMapSearchContainer];
    self.checkHotelsOutlet.enabled = self.footerDatesBtn.enabled = YES;
    self.autoCompleteSpinner.hidden = YES;
    [self.autoCompleteSpinner stopAnimating];
    __weak UIView *nhv = wb.superview;
    __weak UIView *ov = [self.view viewWithTag:14942484];
    [UIView animateWithDuration:0.2 animations:^{
        nhv.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
        ov.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [nhv removeFromSuperview];
        [ov removeFromSuperview];
    }];
    
    UILabel *tt = (UILabel *)[nhv viewWithTag:428642];
    if ([tt.text isEqualToString:@"No Places Found"]) {
        self.whereToTextField.text = [SelectionCriteria singleton].whereToFirst;
        self.whereToSecondLevel.text = [SelectionCriteria singleton].whereToSecond;
        if (self.placesTableData != [SelectionCriteria singleton].placesArray) {
            self.placesTableData = [SelectionCriteria singleton].placesArray;
            [self.placesTableView reloadData];
        }
    }
}

- (void)showOrHideTvControls {
    if (self.hotelTableViewDelegate.hotelData.count == 0) {
        self.hotelsTableView.tableHeaderView.hidden = YES;
        self.filterContainer.alpha = 0.2f;
        self.filterContainer.userInteractionEnabled = NO;
    } else {
        self.hotelsTableView.tableHeaderView.hidden = NO;
        self.filterContainer.alpha = 1.0f;
        self.filterContainer.userInteractionEnabled = YES;
    }
    self.checkHotelsOutlet.enabled = self.footerDatesBtn.enabled = YES;
    [self enableOrDisableSortMapSearchContainer];
}

- (void)enableOrDisableSortMapSearchContainer {
    if (self.hotelTableViewDelegate.hotelData.count == 0) {
        switch (self.viewState) {
            case VIEW_STATE_MAP: {
                self.sortMapSearchContainer.alpha = 1.0f;
                self.sortMapSearchContainer.userInteractionEnabled = YES;
                break;
            }
                
            default: {
                self.sortMapSearchContainer.alpha = 0.2f;
                self.sortMapSearchContainer.userInteractionEnabled = NO;
                break;
            }
        }
    } else {
        self.sortMapSearchContainer.alpha = 1.0f;
        self.sortMapSearchContainer.userInteractionEnabled = YES;
    }
}

#pragma mark Helpers

- (void)setupTheFilterTableView {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"HotelNameFilterView" owner:self options:nil];
    UIView *filterView = views.firstObject;
    UITextField *tf = (UITextField *) [filterView viewWithTag:41414141];
    tf.delegate = _hotelTableViewDelegate;
    
    UIImage *im = [[UIImage imageNamed:@"search_mid.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *iv = [[UIImageView alloc] initWithImage:im];
    iv.tintColor = [UIColor blackColor];
    iv.contentMode = UIViewContentModeScaleAspectFit;
    iv.frame = CGRectMake(10, 8, 14, 14);
    
    UIView *ivc = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 26, 30)];
    ivc.backgroundColor = [UIColor clearColor];
    [ivc addSubview:iv];
    
    UIView *separator = [[UILabel alloc] initWithFrame:CGRectMake(0, 43.5f, 320, 0.5f)];
    separator.backgroundColor = kNavBorderColor();
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

- (void)setupTheSortView {
    UIView *sv = [self.view viewWithTag:414377];
    
    if (!sv) {
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"SortView" owner:self options:nil];
        sv = views.firstObject;
        sv.frame = CGRectMake(0, 600, 320, 300);
        [self.view addSubview:sv];
        
        UIButton *db = (WotaButton *) [sv viewWithTag:36373839];
        [db addTarget:self action:@selector(dropSortView) forControlEvents:UIControlEventTouchUpInside];
        
        UITapGestureRecognizer *tgr1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(letsSortYo:)];
        tgr1.numberOfTapsRequired = 1;
        tgr1.numberOfTouchesRequired = 1;
        [[sv viewWithTag:5101] addGestureRecognizer:tgr1];
        
        UITapGestureRecognizer *tgr2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(letsSortYo:)];
        tgr2.numberOfTapsRequired = 1;
        tgr2.numberOfTouchesRequired = 1;
        [[sv viewWithTag:5102] addGestureRecognizer:tgr2];
        
        UITapGestureRecognizer *tgr3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(letsSortYo:)];
        tgr3.numberOfTapsRequired = 1;
        tgr3.numberOfTouchesRequired = 1;
        [[sv viewWithTag:5103] addGestureRecognizer:tgr3];
        
        UITapGestureRecognizer *tgr4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(letsSortYo:)];
        tgr4.numberOfTapsRequired = 1;
        tgr4.numberOfTouchesRequired = 1;
        [[sv viewWithTag:5104] addGestureRecognizer:tgr4];
    }
    
    ((WotaTappableView *)[sv viewWithTag:5101]).borderColor = kWotaColorOne();
    ((WotaTappableView *)[sv viewWithTag:5102]).borderColor = [UIColor clearColor];
    ((WotaTappableView *)[sv viewWithTag:5103]).borderColor = [UIColor clearColor];
    ((WotaTappableView *)[sv viewWithTag:5104]).borderColor = [UIColor clearColor];
}

- (void)setupDaTravelersView {
    UIView *travelersView = [self.view viewWithTag:434147];
    
    if (!travelersView) {
        NSArray *wes = [[NSBundle mainBundle] loadNibNamed:@"TravelersView" owner:self options:nil];
        travelersView = wes.firstObject;
        travelersView.frame = CGRectMake(0, 569, 320, 320);
        [self.view addSubview:travelersView];
        
        WotaButton *db = (WotaButton *)[travelersView viewWithTag:4728197];
        [db addTarget:self action:@selector(dropTravelersView) forControlEvents:UIControlEventTouchUpInside];
        
        WotaButton *minusBtn = (WotaButton *)[travelersView viewWithTag:191901];
        [minusBtn addTarget:self action:@selector(clickMinusBtn:) forControlEvents:UIControlEventTouchUpInside];
        WotaButton *plusBtn = (WotaButton *)[travelersView viewWithTag:191903];
        [plusBtn addTarget:self action:@selector(clickPlusBtn:) forControlEvents:UIControlEventTouchUpInside];
        WotaButton *addKidsBtn = (WotaButton *)[travelersView viewWithTag:191904];
        [addKidsBtn addTarget:self action:@selector(clickKidsButton:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)clickFilterButton {
    [self loadFilterView];
    [self.view endEditing:YES];
}

- (void)clickSortButton {
    switch (self.viewState) {
        case VIEW_STATE_HOTELS: {
            [self loadSortView];
            [self.view endEditing:YES];
            break;
        }
            
        case VIEW_STATE_MAP: {
            [self removeAllPinsButUserLocation];
            [self findHotelsClicked:self.sortMapSearchContainer];
            self.mapBackContainer.hidden = YES;
            break;
        }
            
        default:
            break;
    }
}

- (void)clickTravelersContainer {
    __weak UIView *travelersView = [self.view viewWithTag:434147];
    
    [self.view endEditing:YES];
    [self.view bringSubviewToFront:_overlay];
    [self.view bringSubviewToFront:travelersView];
    [UIView animateWithDuration:0.28 animations:^{
        _overlay.alpha = 0.7f;
        travelersView.frame = CGRectMake(0, 248, 320, 320);
    } completion:^(BOOL finished) {
        ;
    }];
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

- (void)loadSortView {
    __weak UIView *sv = [self.view viewWithTag:414377];
    [self.view bringSubviewToFront:_overlay];
    [self.view bringSubviewToFront:sv];
    [UIView animateWithDuration:kTrvSearchModeAnimationDuration animations:^{
        _overlay.alpha = 0.7f;
        sv.frame = CGRectMake(0, 268, 320, 300);
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)dropSortView {
    __weak UIView *sv = [self.view viewWithTag:414377];
    [UIView animateWithDuration:kTrvSearchModeAnimationDuration animations:^{
        _overlay.alpha = 0.0f;
        sv.frame = CGRectMake(0, 600, 320, 300);
    } completion:^(BOOL finished) {
        [self.view sendSubviewToBack:_overlay];
        [self.view sendSubviewToBack:sv];
    }];
}

- (void)dropFilterOrSortView {
    if ([self.view viewWithTag:434147].frame.origin.y == 248) {
        [self dropTravelersView];
    } else if (self.viewState == VIEW_STATE_MAP || filterViewUp) {
        [self dropFilterView];
    } else {
        [self dropSortView];
    }
}

- (void)dropTravelersView {
    __weak UIView *tv = [self.view viewWithTag:434147];
    [UIView animateWithDuration:0.28 animations:^{
        _overlay.alpha = 0.0f;
        tv.frame = CGRectMake(0, 569, 320, 320);
    } completion:^(BOOL finished) {
        [self.view sendSubviewToBack:_overlay];
        [self.view sendSubviewToBack:tv];
    }];
}

- (void)resetWhereToTfAppearance {
    self.whereToTextField.layer.cornerRadius = 6.0f;
    self.whereToTextField.layer.borderColor = UIColorFromRGB(0xbbbbbb).CGColor;
    self.whereToTextField.layer.borderWidth = 0.7f;
}

- (UIView *)currentViewFromState {
    switch (self.viewState) {
        case VIEW_STATE_CRITERIA:
            return self.cupHolder;
            
        case VIEW_STATE_HOTELS:
            return self.hotelsTableViewContainer;
            
        case VIEW_STATE_MAP:
            return self.mapViewContainer;
            
        default:
            return nil;
    }
}

- (UIView *)currentSortOrMapSearchViewFromState {
    switch (self.viewState) {
        case VIEW_STATE_CRITERIA:
            return self.sortMapSearch;
            
        case VIEW_STATE_HOTELS:
            return self.sortImageView;
            
        case VIEW_STATE_MAP:
            return self.sortMapSearch;
            
        default:
            return nil;
    }
}

#pragma mark CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.mkMapView.showsUserLocation = NO;
        [SelectionCriteria singleton].currentLocationIsSet = NO;
    } else {
        self.mkMapView.showsUserLocation = YES;
        [SelectionCriteria singleton].currentLocationIsSet = YES;
    }
    
//    [manager startUpdatingLocation];
}

#pragma mark MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (userLocation) {
        ((WotaPlace *) [SelectionCriteria singleton].placesArray.firstObject).latitude = userLocation.location.coordinate.latitude;
        ((WotaPlace *) [SelectionCriteria singleton].placesArray.firstObject).longitude = userLocation.location.coordinate.longitude;
        [SelectionCriteria singleton].currentLocationIsSet = YES;
        
        if (!_userLocationHasUpdated && [[SelectionCriteria singleton] currentLocationIsSelectedPlace] && ![SelectionCriteria singleton].googlePlaceDetail) {
            [self redrawMapViewAnimated:YES radius:[SelectionCriteria singleton].zoomRadius];
        }
        
//        mapView.showsUserLocation = NO;
    }
    
    _userLocationHasUpdated = YES;
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    self.aboutToRedrawMapViewRegion = YES;
    UIView* view = mapView.subviews.firstObject;
    
    // Curtesy of http://b2cloud.com.au/tutorial/mkmapview-determining-whether-region-change-is-from-user-interaction/
    //	Look through gesture recognizers to determine
    //	whether this region change is from user interaction
    for(UIGestureRecognizer* recognizer in view.gestureRecognizers) {
        //	The user caused of this...
        if(recognizer.state == UIGestureRecognizerStateBegan
           || recognizer.state == UIGestureRecognizerStateEnded) {
            _nextRegionChangeIsFromUserInteraction = YES;
            self.mapMapSearch.userInteractionEnabled = NO;
            self.mapMapSearch.alpha = 0.3f;
            self.sortMapSearchContainer.alpha = 0.2f;
            self.sortMapSearchContainer.userInteractionEnabled = NO;
            break;
        }
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    self.currentlyRedrawingMapViewRegion = self.aboutToRedrawMapViewRegion = NO;
    if (self.nextRegionChangeIsFromBackButton) {
        self.containerView.userInteractionEnabled = YES;
        self.nextRegionChangeIsFromBackButton = NO;
        self.useMapRadiusForSearch = YES;
        self.mapMapSearch.userInteractionEnabled = YES;
        self.mapMapSearch.alpha = 1.0f;
        [self enableOrDisableSortMapSearchContainer];
        self.checkHotelsOutlet.enabled = self.footerDatesBtn.enabled = YES;
        self.mapBackContainer.hidden = YES;
    } else if(_nextRegionChangeIsFromUserInteraction) {
        _nextRegionChangeIsFromUserInteraction = NO;
        self.useMapRadiusForSearch = YES;
        self.mapMapSearch.userInteractionEnabled = YES;
        self.mapMapSearch.alpha = 1.0f;
        [self enableOrDisableSortMapSearchContainer];
//        if (!self.criteriaOrHotelSearchMode) {
            [self reverseGeoCodingDawg];
//        }

        if (self.criteriaOrHotelSearchMode) {
            if (mapView.region.center.latitude != [SelectionCriteria singleton].latitude
                    || mapView.region.center.longitude != [SelectionCriteria singleton].longitude) {
                self.mapBackContainer.hidden = NO;
            }
        }
    }
    
    if (self.redrawMapAnnotationCompletion) {
        self.redrawMapAnnotationCompletion();
        self.redrawMapAnnotationCompletion = nil;
    }
    
    if (mapView.region.center.latitude == [SelectionCriteria singleton].latitude
        || mapView.region.center.longitude == [SelectionCriteria singleton].longitude) {
        self.mapBackContainer.hidden = YES;
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    WotaMapAnnotatioin *wa = (WotaMapAnnotatioin *)annotation;
    WotaMKPinAnnotationView *annotationView = [[WotaMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    
    [iv setImageWithURL:[NSURL URLWithString:wa.imageUrl] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        // TODO: placeholder image
        // TODO: if nothing comes back, replace hotel.thumbNailUrlEnhanced with hotel.thumbNailUrl and try again
        ;
    }];
    
    annotationView.leftCalloutAccessoryView = iv;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annotationView.rowNUmber = wa.rowNUmber;
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    WotaMKPinAnnotationView *wp = (WotaMKPinAnnotationView *)view;
    EanHotelListHotelSummary *hotel = [_hotelTableViewDelegate.currentHotelData objectAtIndex:wp.rowNUmber];
    HotelInfoViewController *hvc = [[HotelInfoViewController alloc] initWithHotel:hotel];
    [[LoadEanData sharedInstance:hvc] loadHotelDetailsWithId:[hotel.hotelId stringValue]];
    [self.navigationController pushViewController:hvc animated:YES];
}

@end
