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
#import <MapKit/MapKit.h>
#import "WotaMapAnnotatioin.h"
#import "WotaMKPinAnnotationView.h"

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
@property (nonatomic, strong) MKMapView *mkMapView;
@property (nonatomic, strong) UIView *searchContainer;
@property (weak, nonatomic) IBOutlet UIButton *searchMapBtn;
@property (weak, nonatomic) IBOutlet UILabel *pricesAvgLabel;

- (IBAction)clickSearchMap:(id)sender;

@end

@implementation HotelListingViewController {
    BOOL tableOrMap;
    BOOL searchOpenOrClosed;
}

#pragma mark Lifecycle

- (id)init {
    if (self = [super initWithNibName:@"HotelListingView" bundle:nil]) {
        self.animationDuraton = kSearchModeAnimationDuration;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    NavigationView *nv = [[NavigationView alloc] initWithDelegate:self];
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
    
    _mkMapView = [[MKMapView alloc] initWithFrame:_containerView.bounds];
    _mkMapView.delegate = self;
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        _mkMapView.showsUserLocation = YES;
    }
    [_containerView addSubview:_mkMapView];
    
    _hotelTableViewDelegate = [[HotelsTableViewDelegateImplementation alloc] init];
    
    _hotelsTableView = [[UITableView alloc] initWithFrame:_containerView.bounds];
    _hotelsTableView.dataSource = _hotelTableViewDelegate;
    _hotelsTableView.delegate = _hotelTableViewDelegate;
    _hotelsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _hotelsTableView.separatorColor = [UIColor clearColor];
    [_containerView addSubview:_hotelsTableView];
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(transitionBetweenTableAndMap)];
    tgr.numberOfTapsRequired = 1;
    tgr.numberOfTouchesRequired = 1;
    _wmapIvContainer.userInteractionEnabled = YES;
    [_wmapIvContainer addGestureRecognizer:tgr];
    
    UIImage *hamburger = [[UIImage imageNamed:@"hamburger"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *hiv = [[UIImageView alloc] initWithImage:hamburger];
    hiv.frame = CGRectMake(8, 10, 25, 27);
    hiv.hidden = YES;
    _hamburgerImageView = hiv;
    [_wmapIvContainer addSubview:_hamburgerImageView];
    
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
    
    [super viewDidLoad];
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
    [ad dropDaSpinnerAlreadyWithForce:YES];
}

#pragma mark flipping animation

- (void)transitionBetweenTableAndMap {
    if (tableOrMap) {
        [UIView transitionFromView:_mkMapView
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
        
        [UIView animateWithDuration:kFlipAnimationDuration animations:^{
            _searchMapBtn.alpha = 0.0f;
            _pricesAvgLabel.alpha = 1.0f;
            ;
        }];
    } else {
        [UIView transitionFromView:_hotelsTableView
                            toView:_mkMapView
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
        [self letsFindHotels:self];
        nv.whereToLabel.text = [SelectionCriteria singleton].whereToFirst;
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

- (void)requestStarted:(NSURL *)url {
    NSLog(@"%@.%@ finding hotels with URL:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [url absoluteString]);
}

- (void)requestFinished:(NSData *)responseData dataType:(LOAD_DATA_TYPE)dataType {
    if (dataType == LOAD_GOOGLE_AUTOCOMPLETE || dataType == LOAD_GOOGLE_PLACES) {
        return [super requestFinished:responseData dataType:dataType];
    } else if (dataType != LOAD_EAN_HOTELS_LIST) {
        return;
    }
    
    EanHotelListResponse *ehlr = [EanHotelListResponse eanObjectFromApiResponseData:responseData];
    _hotelTableViewDelegate.hotelData = ehlr.hotelList;
    [_hotelsTableView reloadData];
    [_hotelsTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    
    SelectionCriteria *sc = [SelectionCriteria singleton];
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = sc.latitude;
    zoomLocation.longitude= sc.longitude;
    
    double spanLat = ehlr.maxLatitudeDelta*2.00;
    double spanLon = ehlr.maxLongitudeDelta*2.00;
    MKCoordinateSpan span = MKCoordinateSpanMake(spanLat, spanLon);
    MKCoordinateRegion viewRegion = MKCoordinateRegionMake(zoomLocation, span);
    
    [_mkMapView setRegion:viewRegion animated:tableOrMap];
    [_mkMapView setNeedsDisplay];
    
    [self removeAllPinsButUserLocation];
    // TODO: I might have to remove any existing annotations before adding the following?
    for (int j = 0; j < [_hotelTableViewDelegate.hotelData count]; j++) {
        EanHotelListHotelSummary *hotel = [_hotelTableViewDelegate.hotelData objectAtIndex:j];
        WotaMapAnnotatioin *annotation = [[WotaMapAnnotatioin alloc] init];
        annotation.coordinate = CLLocationCoordinate2DMake(hotel.latitude, hotel.longitude);
        NSString *imageUrlString = [@"http://images.travelnow.com" stringByAppendingString:hotel.thumbNailUrlEnhanced];
        annotation.imageUrl = imageUrlString;
        
        annotation.rowNUmber = j;
        annotation.title = hotel.hotelNameFormatted;
        NSNumberFormatter *cf = kPriceRoundOffFormatter(hotel.rateCurrencyCode);
        annotation.subtitle = [NSString stringWithFormat:@"From %@/night", [cf stringFromNumber:hotel.lowRate]];
        [_mkMapView addAnnotation:annotation];
        
    }
    
    [self dropDaSpinnerAlready];
}

#pragma mark MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    WotaMapAnnotatioin *wa = (WotaMapAnnotatioin *)annotation;
    WotaMKPinAnnotationView *annotationView = (WotaMKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:@"WotaPinReuse"];
    if(!annotationView) {
        annotationView = [[WotaMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"WotaPinReuse"];
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        
        [iv setImageWithURL:[NSURL URLWithString:wa.imageUrl] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            // TODO: placeholder image
            // TODO: if nothing comes back, replace hotel.thumbNailUrlEnhanced with hotel.thumbNailUrl and try again
            ;
        }];
        
        annotationView.leftCalloutAccessoryView = iv;
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    
    annotationView.rowNUmber = wa.rowNUmber;
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    WotaMKPinAnnotationView *wp = (WotaMKPinAnnotationView *)view;
    EanHotelListHotelSummary *hotel = [_hotelTableViewDelegate.hotelData objectAtIndex:wp.rowNUmber];
    HotelInfoViewController *hvc = [[HotelInfoViewController alloc] initWithHotel:hotel];
    [[LoadEanData sharedInstance:hvc] loadHotelDetailsWithId:[hotel.hotelId stringValue]];
    [self.navigationController pushViewController:hvc animated:YES];
}

#pragma mark Overrides

- (void)redrawMapViewAnimated:(BOOL)animated radius:(double)radius {
    
}

#pragma mark Various

- (void)removeAllPinsButUserLocation {
    id userLocation = [_mkMapView userLocation];
    NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[_mkMapView annotations]];
    if (userLocation != nil) {
        [pins removeObject:userLocation];
    }
    
    [_mkMapView removeAnnotations:pins];
}

- (IBAction)clickSearchMap:(id)sender {
    [self reverseGeoCodingDawg];
}

- (void)reverseGeoCodingDawg {
    __weak NavigationView *nv = (NavigationView *) [self.view viewWithTag:kNavigationViewTag];
    __weak typeof(self) wes = self;
    [[LoadGooglePlacesData sharedInstance] loadPlaceDetailsWithLatitude:_mkMapView.region.center.latitude longitude:_mkMapView.region.center.longitude completionBlock:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [SelectionCriteria singleton].googlePlaceDetail = [GooglePlaceDetail placeDetailFromGeoCodeData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            wes.alreadyDroppedSpinner = NO;
            [wes letsFindHotels:wes];
            nv.whereToLabel.text = [SelectionCriteria singleton].whereToFirst;
        });
    }];
}

@end
