//
//  HotelListingViewController.m
//  ean-ota-ios
//
//  Created by WAYNE SMALL on 3/21/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "HotelListingViewController.h"
#import "EanHotelListResponse.h"
#import "HotelsTableViewDelegateImplementation.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "HotelInfoViewController.h"
#import "LoadEanData.h"
#import "AppEnvironment.h"
#import "AppDelegate.h"
#import "SelectionCriteria.h"
#import "ChildTraveler.h"
#import "NavigationView.h"
#import "WotaMapAnnotatioin.h"
#import "WotaMKPinAnnotationView.h"
#import "WotaTappableView.h"
#import "WotaButton.h"
#import "Trotter-Swift.h"

NSTimeInterval const kFlipAnimationDuration = 0.75;
NSTimeInterval const kSearchModeAnimationDuration = 0.36;

@interface HotelListingViewController () <NavigationDelegate, MKMapViewDelegate>

@property (nonatomic) BOOL alreadyDroppedSpinner;
@property (strong, nonatomic) UITableView *hotelsTableView;
@property (nonatomic, strong) HotelsTableViewDelegateImplementation *hotelTableViewDelegate;
@property (weak, nonatomic) IBOutlet UIView *wmapIvContainer;
@property (weak, nonatomic) IBOutlet UIImageView *wmapImageView;
@property (nonatomic, weak) UIImageView *hamburgerImageView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *searchContainer;
@property (weak, nonatomic) IBOutlet UIButton *searchMapBtn;
@property (weak, nonatomic) IBOutlet UILabel *pricesAvgLabel;
@property (weak, nonatomic) IBOutlet UIView *sortFilterContainer;
@property (weak, nonatomic) IBOutlet UIImageView *sortImageView;
@property (weak, nonatomic) IBOutlet UIImageView *filterImageView;
@property (nonatomic) double listMaxLatitudeDelta;
@property (nonatomic) double listMaxLongitudeDelta;
@property (weak, nonatomic) IBOutlet UIView *overlay;
@property (nonatomic, strong) NSString *provisionalTitle;

- (IBAction)clickSearchMap:(id)sender;

@end

@implementation HotelListingViewController {
    BOOL tableOrMap;
    BOOL filterViewUp;
    BOOL waitToFindHotelsUntilGooglePlaceDetailsReturn;
}

#pragma mark Lifecycle

- (id)init {
    return [self initWithProvisionalTitle:@""];
}

- (id)initWithProvisionalTitle:(NSString *)provisionalTitle {
    if (self = [super initWithNibName:@"HotelListingView" bundle:nil]) {
        self.animationDuraton = kSearchModeAnimationDuration;
        self.provisionalTitle = provisionalTitle;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    NSLog(@"%@:didReceiveMemoryWarning", self.class);
}

- (void)loadView {
    [super loadView];
    
    NavigationView *nv = [[NavigationView alloc] initWithDelegate:self];
    nv.whereToLabel.text = !stringIsEmpty(self.provisionalTitle) ? self.provisionalTitle : @"";
    [self.view addSubview:nv];
    
    [nv rightViewAddSearch];
    
    AppDelegate *ad = [[UIApplication sharedApplication] delegate];
    [ad loadDaSpinner];
}

- (void)viewDidLoad {
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
    
    self.mkMapView = [[MKMapView alloc] initWithFrame:_containerView.bounds];
    self.mkMapView.delegate = self;
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.mkMapView.showsUserLocation = YES;
    }
    [_containerView addSubview:self.mkMapView];
    
    _hotelTableViewDelegate = [[HotelsTableViewDelegateImplementation alloc] init];
    
    _hotelsTableView = [[UITableView alloc] initWithFrame:_containerView.bounds];
    _hotelsTableView.dataSource = _hotelTableViewDelegate;
    _hotelsTableView.delegate = _hotelTableViewDelegate;
    _hotelsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _hotelsTableView.separatorColor = [UIColor clearColor];
    _hotelsTableView.delaysContentTouches = NO;
    [_containerView addSubview:_hotelsTableView];
    
    [self setupTheFilterTableView];
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(transitionBetweenTableAndMap)];
    tgr.numberOfTapsRequired = 1;
    tgr.numberOfTouchesRequired = 1;
    _wmapIvContainer.userInteractionEnabled = YES;
    [_wmapIvContainer addGestureRecognizer:tgr];
    
    UITapGestureRecognizer *tgr2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickSortFilterButton)];
    tgr2.numberOfTapsRequired = 1;
    tgr2.numberOfTouchesRequired = 1;
    tgr2.cancelsTouchesInView = NO;
    _sortFilterContainer.userInteractionEnabled = YES;
    [_sortFilterContainer addGestureRecognizer:tgr2];
    
    UIImage *hamburger = [[UIImage imageNamed:@"hamburger"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *hiv = [[UIImageView alloc] initWithImage:hamburger];
    hiv.frame = CGRectMake(8, 10, 25, 27);
    hiv.hidden = YES;
    _hamburgerImageView = hiv;
    [_wmapIvContainer addSubview:_hamburgerImageView];
    
    _filterImageView.hidden = YES;
    
    _searchMapBtn.alpha = 0.0f;
    
    _searchContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 63.4f, 320, 0)];
    _searchContainer.clipsToBounds = YES;
    _searchContainer.backgroundColor = kNavigationColor();
    [self.view addSubview:_searchContainer];
    
    UITextField *wt = [[UITextField alloc] initWithFrame:CGRectMake(6, 5, 308, 30)];
    wt.backgroundColor = [UIColor whiteColor];
    wt.borderStyle = UITextBorderStyleRoundedRect;
    wt.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    wt.returnKeyType = UIReturnKeyDone;
    wt.autocapitalizationType = UITextAutocapitalizationTypeNone;
    wt.autocorrectionType = UITextAutocorrectionTypeNo;
    wt.spellCheckingType = UITextSpellCheckingTypeNo;
    wt.clearButtonMode = UITextFieldViewModeWhileEditing;
    wt.placeholder = @"Where to?";
    wt.font = [UIFont systemFontOfSize:16.0f];
    self.whereToTextField = wt;
    [_searchContainer addSubview:self.whereToTextField];
    
    UIView *border = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0.6f)];
    border.tag = 123456781;
    border.backgroundColor = kNavBorderColor();
    [_searchContainer addSubview:border];
    
    self.placesTableViewZeroFrame = CGRectMake(0, 63.4f, 320, 0);
    self.placesTableViewExpandedFrame = CGRectMake(0, 103.4f, 320, 248.5f);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onHotelDataFiltered) name:kNotificationHotelDataFiltered object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onHotelDataSorted) name:kNotificationHotelDataSorted object:nil];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [self showOrHideTvControls];
}

- (void)dropDaSpinnerAlready {
    if (_alreadyDroppedSpinner) {
        return;
    }
    _alreadyDroppedSpinner = YES;
    
    AppDelegate *ad = [[UIApplication sharedApplication] delegate];
    [ad dropDaSpinnerAlreadyWithForce:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationHotelDataFiltered object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationHotelDataSorted object:nil];
}

#pragma mark flipping animation

- (void)transitionBetweenTableAndMap {
    if (tableOrMap) {
        [UIView transitionFromView:self.mkMapView
                            toView:_hotelsTableView
                          duration:kFlipAnimationDuration
                           options:UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionAllowAnimatedContent
                        completion:^(BOOL finished) {
                            tableOrMap = NO;
                        }];
        
        [UIView transitionFromView:_hamburgerImageView
                            toView:_wmapImageView
                          duration:kFlipAnimationDuration
                           options:UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionAllowAnimatedContent
                        completion:^(BOOL finished) {
                        }];
        
        [UIView transitionFromView:_filterImageView
                            toView:_sortImageView
                          duration:kFlipAnimationDuration
                           options:UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionAllowAnimatedContent
                        completion:^(BOOL finished) {
                        }];
        
        [UIView animateWithDuration:kFlipAnimationDuration animations:^{
            _searchMapBtn.alpha = 0.0f;
            _pricesAvgLabel.alpha = 1.0f;
            ;
        }];
    } else {
        [UIView transitionFromView:_hotelsTableView
                            toView:self.mkMapView
                          duration:kFlipAnimationDuration
                           options:UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionAllowAnimatedContent
                        completion:^(BOOL finished) {
                            tableOrMap = YES;
                        }];
        
        [UIView transitionFromView:_wmapImageView
                            toView:_hamburgerImageView
                          duration:kFlipAnimationDuration
                           options:UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionAllowAnimatedContent
                        completion:^(BOOL finished) {
                        }];
        
        [UIView transitionFromView:_sortImageView
                            toView:_filterImageView
                          duration:kFlipAnimationDuration
                           options:UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionAllowAnimatedContent
                        completion:^(BOOL finished) {
                        }];
        
        [UIView animateWithDuration:kFlipAnimationDuration animations:^{
            _searchMapBtn.alpha = 1.0f;
            _pricesAvgLabel.alpha = 0.0f;
            ;
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

- (void)clickRight {
    __weak UIView *sc = _searchContainer;
    __weak UIView *bd = [sc viewWithTag:123456781];
    __weak NavigationView *nv = (NavigationView *) [self.view viewWithTag:kNavigationViewTag];
    nv.animationDuration = kSearchModeAnimationDuration;
    if (sc.frame.size.height == 0) {
//        self.whereToTextField.placeholder = [SelectionCriteria singleton].whereToFirst;
        [self.whereToTextField becomeFirstResponder];
        [self.view bringSubviewToFront:sc];
        [nv animateToCancel];
        [nv rightViewFlipToRefresh];
        [UIView animateWithDuration:kSearchModeAnimationDuration animations:^{
            sc.frame = CGRectMake(0, 63.4f, 320, 40);
            bd.frame = CGRectMake(0, 39.4f, 320, 0.6f);
        } completion:^(BOOL finished) {
            nv.animationDuration = 0.0;
        }];
    } else {
        [self exitSearchModeWithSearch:YES];
    }
}

- (void)clickCancel {
    [self exitSearchModeWithSearch:NO];
}

- (void)exitSearchModeWithSearch:(BOOL)search {
    __weak UIView *sc = _searchContainer;
    __weak UIView *bd = [sc viewWithTag:123456781];
    __weak NavigationView *nv = (NavigationView *) [self.view viewWithTag:kNavigationViewTag];
    nv.animationDuration = kSearchModeAnimationDuration;
    _alreadyDroppedSpinner = NO;
    
    if (search) {
        if (!self.loadingGooglePlaceDetails) {
            [self letsFindHotels:self searchRadius:[SelectionCriteria singleton].zoomRadius withPushVC:NO];
        } else {
            waitToFindHotelsUntilGooglePlaceDetailsReturn = YES;
        }
    }
    
    [self animateTableViewCompression];
    [self.whereToTextField endEditing:YES];
    [nv animateToBack];
    [nv rightViewFlipToSearch];
    [UIView animateWithDuration:kSearchModeAnimationDuration animations:^{
        sc.frame = CGRectMake(0, 63.4f, 320, 0);
        bd.frame = CGRectMake(0, 0, 320, 0.6f);
    } completion:^(BOOL finished) {
        nv.animationDuration = 0.0;
    }];
}

#pragma mark UITextFieldDelegate overrides

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.whereToTextField.placeholder = [SelectionCriteria singleton].whereToFirst;
    [super textFieldDidBeginEditing:textField];
    [self.view bringSubviewToFront:_searchContainer];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self exitSearchModeWithSearch:NO];
    return YES;
}

#pragma mark LoadDataProtocol methods

- (void)requestStarted:(NSURLConnection *)connection {
    NSLog(@"%@.%@ finding hotels with URL:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [[[connection currentRequest] URL] absoluteString]);
}

- (void)requestFinished:(NSData *)responseData dataType:(LOAD_DATA_TYPE)dataType {
    if (dataType == LOAD_GOOGLE_AUTOCOMPLETE) {
        return [super requestFinished:responseData dataType:dataType];
    } else if (dataType == LOAD_GOOGLE_PLACES) {
        [super requestFinished:responseData dataType:dataType];
        if (waitToFindHotelsUntilGooglePlaceDetailsReturn) {
            [self letsFindHotels:self searchRadius:[SelectionCriteria singleton].zoomRadius withPushVC:NO];
            waitToFindHotelsUntilGooglePlaceDetailsReturn = NO;
        }
        return;
    } else if (dataType != LOAD_EAN_HOTELS_LIST) {
        return;
    }
    
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
    [self setupTheSortView];
    
    __weak NavigationView *nv = (NavigationView *) [self.view viewWithTag:kNavigationViewTag];
    nv.whereToLabel.text = [SelectionCriteria singleton].whereToFirst;
    
    [self dropDaSpinnerAlready];
}

#pragma mark MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    WotaMapAnnotatioin *wa = (WotaMapAnnotatioin *)annotation;
//    WotaMKPinAnnotationView *annotationView = (WotaMKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:@"WotaPinReuse"];
//    if(!annotationView) {
        WotaMKPinAnnotationView *annotationView = [[WotaMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"WotaPinReuse"];
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        
        [iv setImageWithURL:[NSURL URLWithString:wa.imageUrl] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            // TODO: placeholder image
            // TODO: if nothing comes back, replace hotel.thumbNailUrlEnhanced with hotel.thumbNailUrl and try again
            ;
        }];
        
        annotationView.leftCalloutAccessoryView = iv;
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//    }
    
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

#pragma mark Various

- (void)removeAllPinsButUserLocation {
    id userLocation = [self.mkMapView userLocation];
    NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[self.mkMapView annotations]];
    if (userLocation != nil) {
        [pins removeObject:userLocation];
    }
    
    [self.mkMapView removeAnnotations:pins];
}

- (IBAction)clickSearchMap:(id)sender {
    [self exitSearchModeWithSearch:NO];
    [self reverseGeoCodingDawg];
}

- (void)reverseGeoCodingDawg {
    __weak typeof(self) wes = self;
    AppDelegate *ad = [[UIApplication sharedApplication] delegate];
    [ad loadDaSpinner];
    
    [[LoadGooglePlacesData sharedInstance] loadPlaceDetailsWithLatitude:self.mkMapView.region.center.latitude
                                                              longitude:self.mkMapView.region.center.longitude
                                                        completionBlock:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        [SelectionCriteria singleton].googlePlaceDetail = [GooglePlaceDetail placeDetailFromGeoCodeData:data];
        [SelectionCriteria singleton].googlePlaceDetail.zoomRadius = self.mapRadiusInMiles;
                                                            
        dispatch_async(dispatch_get_main_queue(), ^{
            wes.alreadyDroppedSpinner = NO;
            [wes letsFindHotels:wes searchRadius:self.mapRadiusInMiles withPushVC:NO];
            
        });
                                                            
    }];
}

- (void)onHotelDataFiltered {
    [_hotelsTableView reloadData];
    [self redrawMapAnnotationsAndRegion:NO];
}

- (void)letsSortYo:(UITapGestureRecognizer *)tgr {
    [self.hotelTableViewDelegate letsSortYo:tgr];
    [self dropSortView];
}

- (void)onHotelDataSorted {
    [_hotelsTableView reloadData];
    [self redrawMapAnnotationsAndRegion:NO];
}

- (void)redrawMapAnnotationsAndRegion:(BOOL)redrawRegion {
    if (redrawRegion) {
        double spanLat = _listMaxLatitudeDelta*2.50;
        double spanLon = _listMaxLongitudeDelta*2.50;
        MKCoordinateSpan span = MKCoordinateSpanMake(spanLat, spanLon);
        MKCoordinateRegion viewRegion = MKCoordinateRegionMake(self.zoomLocation, span);
        
        [self.mkMapView setRegion:viewRegion animated:tableOrMap];
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

- (void)setupTheFilterTableView {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"FilterTableView" owner:self options:nil];
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
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickFilterButton)];
    tgr.numberOfTapsRequired = 1;
    tgr.numberOfTouchesRequired = 1;
    tgr.cancelsTouchesInView = NO;
    WotaTappableView *filterContainer = (WotaTappableView *) [filterView viewWithTag:1239871];
    filterContainer.tapColor = kWotaColorOne();
    filterContainer.untapColor = [UIColor clearColor];
    filterContainer.userInteractionEnabled = YES;
    [filterContainer addGestureRecognizer:tgr];
    
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

#pragma mark Filter methods

- (void)clickSortFilterButton {
    if (tableOrMap) {
        [self clickFilterButton];
    } else {
        [self loadSortView];
        [self.view endEditing:YES];
    }
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
    [UIView animateWithDuration:kSearchModeAnimationDuration animations:^{
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
    [UIView animateWithDuration:kSearchModeAnimationDuration animations:^{
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
    [UIView animateWithDuration:kSearchModeAnimationDuration animations:^{
        _overlay.alpha = 0.7f;
        sv.frame = CGRectMake(0, 268, 320, 300);
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)dropSortView {
    __weak UIView *sv = [self.view viewWithTag:414377];
    [UIView animateWithDuration:kSearchModeAnimationDuration animations:^{
        _overlay.alpha = 0.0f;
        sv.frame = CGRectMake(0, 600, 320, 300);
    } completion:^(BOOL finished) {
        [self.view sendSubviewToBack:_overlay];
        [self.view sendSubviewToBack:sv];
    }];
}

- (void)dropFilterOrSortView {
    if (tableOrMap || filterViewUp) {
        [self dropFilterView];
    } else {
        [self dropSortView];
    }
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
        self.wmapIvContainer.hidden = YES;
        self.searchMapBtn.hidden = YES;
        self.pricesAvgLabel.hidden = YES;
        self.sortFilterContainer.hidden = YES;
    } else {
        self.hotelsTableView.tableHeaderView.hidden = NO;
        self.wmapIvContainer.hidden = NO;
        self.searchMapBtn.hidden = NO;
        self.pricesAvgLabel.hidden = NO;
        self.sortFilterContainer.hidden = NO;
    }
}

@end
