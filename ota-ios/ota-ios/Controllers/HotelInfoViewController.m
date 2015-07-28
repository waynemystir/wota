//
//  HotelInfoViewController.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/26/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "HotelInfoViewController.h"
#import "LoadEanData.h"
#import "SelectionCriteria.h"
#import "ChildTraveler.h"
#import "SelectRoomViewController.h"
#import "EanHotelInformationResponse.h"
#import "EanHotelInfoImage.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NavigationView.h"
#import "EanPropertyAmenity.h"
#import "EanHotelDetails.h"
#import "EanPaymentTypeResponse.h"
#import "AppEnvironment.h"
#import "AppDelegate.h"
#import "WotaTappableView.h"
#import "LoadGooglePlacesData.h"
#import <MapKit/MapKit.h>
#import "NetworkProblemResponder.h"

#define degreesToRadians(x) (M_PI * x / 180.0)
#define METERS_PER_MILE 1609.344

typedef NS_ENUM(NSUInteger, HI_ORIENTATION) {
    HI_PORTRAIT = UIDeviceOrientationPortrait,
    HI_LANDSCAPE_LEFT = UIDeviceOrientationLandscapeLeft,
    HI_LANDSCAPE_RIGHT = UIDeviceOrientationLandscapeRight
};

NSTimeInterval const kHiAnimationDuration = 0.43;
CGFloat const kImageScrollerStartY = -100.0f;
CGFloat const kImageScrollerStartHeight = 325.0f;
CGFloat const kImageScrollerPortraitY = 34.0f;
CGFloat const kImageScrollerPortraitHeight = 500.0f;
NSUInteger const kRoomImageViewContainersStartingTag = 1113151719;
NSUInteger const kRoomImageViewsStartingTag = 1917151311;

@interface HotelInfoViewController () <CLLocationManagerDelegate, NavigationDelegate, UIScrollViewDelegate>

@property (nonatomic) NSInteger currentPageNumber;
@property (nonatomic) NSInteger totalNumberOfPages;
@property (nonatomic) HI_ORIENTATION currentOrientation;
@property (nonatomic) BOOL hideEffinStatusBar;

@property (nonatomic) BOOL firstImageArrived;
@property (nonatomic) BOOL alreadyDroppedSpinner;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewOutlet;
@property (weak, nonatomic) IBOutlet WotaTappableView *selectRoomContainer;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollerOutlet;
@property (weak, nonatomic) IBOutlet WotaTappableView *fromRateContainer;
@property (weak, nonatomic) IBOutlet UILabel *tripAdvisorBasedOnLabel;
@property (weak, nonatomic) IBOutlet UIImageView *tripAdvisorImageView;
@property (weak, nonatomic) IBOutlet UIImageView *star1;
@property (weak, nonatomic) IBOutlet UIImageView *star2;
@property (weak, nonatomic) IBOutlet UIImageView *star3;
@property (weak, nonatomic) IBOutlet UIImageView *star4;
@property (weak, nonatomic) IBOutlet UIImageView *star5;
@property (weak, nonatomic) IBOutlet UILabel *someLabelOutlet;
@property (weak, nonatomic) IBOutlet UIView *mapContainerOutlet;
@property (weak, nonatomic) IBOutlet UIView *mapOverlay;
@property (weak, nonatomic) IBOutlet UILabel *addressTitle;
@property (weak, nonatomic) IBOutlet UILabel *addressLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *shortDescLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *propAmenTities;
@property (weak, nonatomic) IBOutlet UILabel *policiesTitle;
@property (weak, nonatomic) IBOutlet UILabel *policiesLabel;
@property (weak, nonatomic) IBOutlet UILabel *amenitiesContainer;
@property (weak, nonatomic) IBOutlet UILabel *feesTitle;
@property (weak, nonatomic) IBOutlet UILabel *feesLabel;
@property (weak, nonatomic) IBOutlet UILabel *diningTitle;
@property (weak, nonatomic) IBOutlet UILabel *diningLabel;
@property (nonatomic, strong) EanHotelInformationResponse *eanHotelInformationResponse;
@property (nonatomic, strong) SelectRoomViewController *selectRoomViewController;
@property (nonatomic) BOOL paymentTypesReturned;
@property (nonatomic) BOOL policiesLabelIsSet;
@property (nonatomic, strong) NSString *paymentTypesBulletted;
@property (weak, nonatomic) IBOutlet UILabel *pageNumberLabel;
@property (weak, nonatomic) IBOutlet WotaTappableView *bookRoomContainer;
@property (nonatomic, strong) MKMapView *mapView;

@end

@implementation HotelInfoViewController {
    CGRect mapRectInScroller;
}

#pragma mark Lifecycle

- (id)init {
    self = [super initWithNibName:@"HotelInfoView" bundle:nil];
    return self;
}

- (void)didReceiveMemoryWarning {
    NSLog(@"%@:didReceiveMemoryWarning", self.class);
}

- (id)initWithHotel:(EanHotelListHotelSummary *)eanHotel {
    self = [self init];
    if (self != nil) {
        _eanHotel = eanHotel;
        [[LoadEanData sharedInstance] loadPaymentTypesWithHotelId:[_eanHotel.hotelId stringValue] supplierType:_eanHotel.supplierType rateType:_eanHotel.roomRateDetails.rateInfo.rateType completionBlock:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            _paymentTypesBulletted = [EanPaymentTypeResponse eanObjectFromApiResponseData:data].paymentTypesBulletted;
            _paymentTypesReturned = YES;
            [self appendPaymentTypesToPoliciesLabel];
        }];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    NavigationView *nv = [[NavigationView alloc] initWithDelegate:self];
    nv.animationDuration = kHiAnimationDuration;
    nv.whereToLabel.text = _eanHotel.hotelNameFormatted;
    [self.view addSubview:nv];
    
    AppDelegate *ad = [[UIApplication sharedApplication] delegate];
    [ad loadDaSpinner];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotateOrNot) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    //**********************************************************************
    // This is needed so that this view controller (or it's nav controller?)
    // doesn't make room at the top of the table view's scroll view (I guess
    // to account for the nav bar).
    //***********************************************************************
    self.automaticallyAdjustsScrollViewInsets = NO;
    //***********************************************************************
    
    self.scrollViewOutlet.contentSize = CGSizeMake(320.0f, 900.0f);
    self.scrollViewOutlet.scrollsToTop = YES;
    self.scrollViewOutlet.delaysContentTouches = NO;
    self.imageScrollerOutlet.delegate = self;
    self.imageScrollerOutlet.contentSize = CGSizeMake(1900.0f, 195.0f);
    
    _fromRateContainer.tapColor = kTheColorOfMoney();
    _fromRateContainer.untapColor = [UIColor clearColor];
    _fromRateContainer.backgroundColor = [UIColor clearColor];
    _fromRateContainer.borderColor = kTheColorOfMoney();
    _fromRateContainer.userInteractionEnabled = YES;
    
    NSNumberFormatter *cf = kPriceRoundOffFormatter(_eanHotel.rateCurrencyCode);
    NSString *price = [NSString stringWithFormat:@"From %@/night", [cf stringFromNumber:_eanHotel.lowRate]];
    _someLabelOutlet.text = price;
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoSelectRoomVC)];
    tgr.numberOfTapsRequired = 1;
    tgr.numberOfTouchesRequired = 1;
    tgr.cancelsTouchesInView = YES;
    [_fromRateContainer addGestureRecognizer:tgr];
    
    UITapGestureRecognizer *tgr2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoSelectRoomVC)];
    tgr2.numberOfTapsRequired = 1;
    tgr2.numberOfTouchesRequired = 1;
    tgr2.cancelsTouchesInView = YES;
    [_selectRoomContainer addGestureRecognizer:tgr2];
    
    UITapGestureRecognizer *tgr2b = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoSelectRoomVC)];
    tgr2b.numberOfTapsRequired = 1;
    tgr2b.numberOfTouchesRequired = 1;
    tgr2b.cancelsTouchesInView = YES;
    [_bookRoomContainer addGestureRecognizer:tgr2b];
    
    NSURL *iu = [NSURL URLWithString:[_eanHotel tripAdvisorRatingUrl]];
    _tripAdvisorImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_tripAdvisorImageView setImageWithURL:iu placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        ;
    }];
    
    NSString *numReviews = [kNumberFormatterWithThousandsSeparatorNoDecimals() stringFromNumber:_eanHotel.tripAdvisorReviewCount];
    BOOL zr = [_eanHotel.tripAdvisorReviewCount integerValue] == 0;
    NSString *plural = [_eanHotel.tripAdvisorReviewCount integerValue] == 1 ? @"" : @"s";
    NSString *basedOn = numReviews && !zr ? [NSString stringWithFormat:@"Based on %@ review%@", numReviews, plural] : @"No Reviews";
    _tripAdvisorBasedOnLabel.text = basedOn;
    
    [self colorTheHotelRatingStars];
    
    _mapContainerOutlet.clipsToBounds = YES;
    
    UITapGestureRecognizer *tgr3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadDaMap)];
    tgr3.numberOfTapsRequired = 1;
    tgr3.numberOfTouchesRequired = 1;
    tgr3.cancelsTouchesInView = YES;
    [_mapOverlay addGestureRecognizer:tgr3];
    
    _mapView = [[MKMapView alloc] initWithFrame:_mapContainerOutlet.bounds];
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = _eanHotel.latitude;
    zoomLocation.longitude= _eanHotel.longitude;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.4*METERS_PER_MILE, 0.4*METERS_PER_MILE);
    [_mapView setRegion:viewRegion];
//    _mapView.delegate = self;
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        _mapView.showsUserLocation = YES;
    }
    [_mapContainerOutlet addSubview:_mapView];
    [_mapContainerOutlet sendSubviewToBack:_mapView];
    
    MKPointAnnotation *hotelAnnotation = [[MKPointAnnotation alloc] init];
    hotelAnnotation.coordinate = CLLocationCoordinate2DMake(_eanHotel.latitude, _eanHotel.longitude);
    hotelAnnotation.title = _eanHotel.hotelNameFormatted;
    hotelAnnotation.subtitle = [NSString stringWithFormat:@"From %@/night", [cf stringFromNumber:_eanHotel.lowRate]];
    [_mapView addAnnotation:hotelAnnotation];
}

- (void)colorTheHotelRatingStars {
    NSNumber *hr = _eanHotel.hotelRating;
    double hrd = [hr doubleValue];
    NSArray *stars = [NSArray arrayWithObjects:_star1, _star2, _star3, _star4, _star5, nil];
    
    if (hrd == 0) {
        UILabel *negatoryLabel = [[UILabel alloc] initWithFrame:_star1.superview.bounds];
        negatoryLabel.backgroundColor = [UIColor whiteColor];
        negatoryLabel.text = @"Not Rated";
        negatoryLabel.textColor = [UIColor grayColor];
        negatoryLabel.textAlignment = NSTextAlignmentCenter;
        negatoryLabel.font = [UIFont systemFontOfSize:15.0f];
        [_star1.superview addSubview:negatoryLabel];
        [_star1.superview bringSubviewToFront:negatoryLabel];
        for (UIView *star in stars) {
            [star removeFromSuperview];
        }
        return;
    }
    
    NSInteger floorHr = floor(hrd);
    hrd = hrd - floorHr;
    
    _star1.image = [_star1.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _star2.image = [_star2.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _star3.image = [_star3.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _star4.image = [_star4.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _star5.image = [_star5.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    for (int j = 1; j <= 5; j++) {
        if (j <= [hr integerValue]) {
            [((UIImageView *)stars[j-1]) setTintColor:kWotaColorOne()];
        } else {
            [((UIImageView *)stars[j-1]) setTintColor:[UIColor lightGrayColor]];
        }
    }
    
    if (hrd != 0 && floorHr >= 0 && floorHr < [stars count]) {
        UIImageView *partialStar = stars[floorHr];
        
        UIImage *ls = [UIImage imageNamed:@"star.png"];
        UIImageView *onaTop = [[UIImageView alloc] initWithImage:ls];
        onaTop.contentMode = UIViewContentModeLeft;
        onaTop.clipsToBounds = YES;
        onaTop.layer.masksToBounds = YES;
        [onaTop setTintColor:kWotaColorOne()];
        onaTop.frame = CGRectMake(0, 0, partialStar.frame.size.width/2, partialStar.frame.size.height);
        [partialStar addSubview:onaTop];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

- (void)dealloc {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark NavigationDelegate methods

- (void)clickBack {
    [self dropTheSpinnerAlready:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickCancel {
    [self dropDaMap];
}

- (void)clickTitle {
    
}

#pragma mark LoadDataProtocol methods

- (void)requestStarted:(NSURLConnection *)connection {
    NSLog(@"%@.%@ URL:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [[[connection currentRequest] URL] absoluteString]);
}

- (void)requestFinished:(NSData *)responseData dataType:(LOAD_DATA_TYPE)dataType {
    self.eanHotelInformationResponse = [EanHotelInformationResponse eanObjectFromApiResponseData:responseData];
    [self loadupTheImageScroller];
    [self loadupTheAmenities];
    
//    [self prepareTheSelectRoomViewController];
}

- (void)requestTimedOut {
    [self dropTheSpinnerAlready:YES];
    __weak typeof(self) wes = self;
    [NetworkProblemResponder launchWithSuperView:self.view headerTitle:nil messageString:nil completionCallback:^{
        [wes.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)requestFailedOffline {
    [self dropTheSpinnerAlready:YES];
    __weak typeof(self) wes = self;
    [NetworkProblemResponder launchWithSuperView:self.view headerTitle:@"Network Error" messageString:@"The network could not be reached. Please check your connection and try again." completionCallback:^{
        [wes.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark Various

- (UIImageView *)currentImageView {
    NSInteger cp = _currentPageNumber - 1;
    UIView *civc = [_imageScrollerOutlet viewWithTag:kRoomImageViewContainersStartingTag + cp];
    UIImageView *civ = (UIImageView *) [civc viewWithTag:kRoomImageViewsStartingTag + cp];
    return civ;
}

- (void)loadupTheImageScroller {
    NSArray *ims = self.eanHotelInformationResponse.hotelImagesArray;
    for (int j = 0; j < [ims count]; j++) {
        EanHotelInfoImage *eanInfoImage = [EanHotelInfoImage imageFromDict:ims[j]];
        UIView *ivc = [[UIView alloc] initWithFrame:CGRectMake(j * 500, 0, 500.0f, 325.0f)];
        ivc.backgroundColor = [UIColor blackColor];
        ivc.tag = kRoomImageViewContainersStartingTag + j;
        
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, 360.0f, 325.0f)];
        iv.backgroundColor = [UIColor blackColor];
        iv.clipsToBounds = YES;
        iv.tag = kRoomImageViewsStartingTag + j;
        [ivc addSubview:iv];
        __weak typeof(UIImageView) *wiv = iv;
        CGRect wivFrame = [self rectForOrient:HI_PORTRAIT];
        [iv setImageWithURL:[NSURL URLWithString:eanInfoImage.url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            wiv.contentMode = UIViewContentModeScaleAspectFit;
            wiv.frame = wivFrame;
            wiv.center = CGPointMake(250, 212);
            if (j == 0) {
                _firstImageArrived = YES;
                [self prepareTheSelectRoomViewControllerWithPlaceholderImage:image];
                [self dropTheSpinnerAlready:NO];
            }
        }];
        
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTheImage:)];
        tgr.numberOfTapsRequired = 1;
        tgr.numberOfTouchesRequired = 1;
        [_imageScrollerOutlet addGestureRecognizer:tgr];
        _imageScrollerOutlet.userInteractionEnabled = YES;
        [_imageScrollerOutlet addSubview:ivc];
    }
    
    _imageScrollerOutlet.contentSize = CGSizeMake(500 * [ims count], 325);
    _currentPageNumber = 1;
    _totalNumberOfPages = [ims count];
    _pageNumberLabel.text = [NSString stringWithFormat:@"1/%lu", (unsigned long)[ims count]];
}

- (void)loadupTheAmenities {
    EanHotelDetails *hd = self.eanHotelInformationResponse.hotelDetails;
    UILabel *so = _shortDescLabelOutlet;
    so.text = hd.locationDescription;
    [so sizeToFit];
    CGRect mf = _mapContainerOutlet.frame;
    _mapContainerOutlet.frame = CGRectMake(mf.origin.x, so.frame.origin.y + so.frame.size.height + 10.0f, mf.size.width, mf.size.height);
    mf = _mapContainerOutlet.frame;
    
    CGRect tf = _propAmenTities.frame;
    CGRect acf = _amenitiesContainer.frame;
    if (stringIsEmpty(hd.amenitiesDescription) && [self.eanHotelInformationResponse.propertyAmenitiesArray count] == 0) {
        _propAmenTities.text = @"";
        _propAmenTities.frame = CGRectMake(tf.origin.x, mf.origin.y + mf.size.height + 0.0f, tf.size.width, 0.0f);
        tf = _propAmenTities.frame;
        
        _amenitiesContainer.text = @"";
        _amenitiesContainer.frame = CGRectMake(acf.origin.x, tf.origin.y + tf.size.height + 0.0f, acf.size.width, 0.0f);
        acf = _amenitiesContainer.frame;
    } else {
        _propAmenTities.frame = CGRectMake(tf.origin.x, mf.origin.y + mf.size.height + 15.0f, tf.size.width, tf.size.height);
        tf = _propAmenTities.frame;
        
        NSString *at = !stringIsEmpty(hd.amenitiesDescription) ? [hd.amenitiesDescription stringByAppendingString:@"\n"] : @"";
        NSArray *ams = self.eanHotelInformationResponse.propertyAmenitiesArray;
        for (int j = 0; j < [ams count]; j++) {
            EanPropertyAmenity *pa = [EanPropertyAmenity amenityFromDict:ams[j]];
            NSString *wes = (stringIsEmpty(hd.amenitiesDescription) && j == 0) ? @"● %@" : @"\n● %@";
            at = [at stringByAppendingFormat:wes, pa.amenityName];
        }
        
        _amenitiesContainer.text = at;
//        [_amenitiesContainer sizeToFit];
        CGSize size = [_amenitiesContainer sizeThatFits:CGSizeMake(acf.size.width, CGFLOAT_MAX)];
        acf.size.height = size.height;
        _amenitiesContainer.frame = acf;
        acf = _amenitiesContainer.frame;
        
        _amenitiesContainer.frame = CGRectMake(acf.origin.x, tf.origin.y + tf.size.height + 4.0f, acf.size.width, acf.size.height);
        acf = _amenitiesContainer.frame;
    }
    
    CGRect dtf = _diningTitle.frame;
    CGRect dlf = _diningLabel.frame;
    if (stringIsEmpty(hd.diningDescription)) {
        _diningTitle.text = @"";
        _diningTitle.frame = CGRectMake(dtf.origin.x, acf.origin.y + acf.size.height + 0.0f, dtf.size.width, 0.0f);
        dtf = _diningTitle.frame;
        
        _diningLabel.text = @"";
        _diningLabel.frame = CGRectMake(dlf.origin.x, dtf.origin.y + dtf.size.height + 0.0f, dlf.size.width, 0.0);
        dlf = _diningLabel.frame;
    } else {
        _diningTitle.frame = CGRectMake(dtf.origin.x, acf.origin.y + acf.size.height + 15.0f, dtf.size.width, dtf.size.height);
        dtf = _diningTitle.frame;
        
        _diningLabel.text = stringByStrippingHTML(hd.diningDescription);
        CGSize size = [_diningLabel sizeThatFits:CGSizeMake(dlf.size.width, CGFLOAT_MAX)];
        dlf.size.height = size.height;
        _diningLabel.frame = dlf;
        
        _diningLabel.frame = CGRectMake(dlf.origin.x, dtf.origin.y + dtf.size.height + 4.0f, dlf.size.width, dlf.size.height);
        dlf = _diningLabel.frame;
    }
    
    NSString *sl = _eanHotel.stateProvinceCode ? [NSString stringWithFormat:@", %@", _eanHotel.stateProvinceCode] : @"";
    NSString *pcl = _eanHotel.postalCode ? [NSString stringWithFormat:@" %@", _eanHotel.postalCode] : @"";
    
    NSString *ccc = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    NSString *cl = @"";
    if (![ccc isEqualToString:_eanHotel.countryCode]) {
        NSString *countryName = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:_eanHotel.countryCode];
        cl = [NSString stringWithFormat:@"\n%@", countryName];
    }
    
    NSString *alt = [NSString stringWithFormat:@"%@\n%@\n%@%@%@%@", _eanHotel.hotelNameFormatted, _eanHotel.address1Formatted, _eanHotel.city, sl, pcl, cl];
    
    CGRect atf = _addressTitle.frame;
    CGRect alf = _addressLabelOutlet.frame;
    if (stringIsEmpty(alt)) {
        _addressTitle.text = @"";
        _addressTitle.frame = CGRectMake(atf.origin.x, dlf.origin.y + dlf.size.height + 0.0f, atf.size.width, 0.0f);
        atf = _addressTitle.frame;
        
        _addressLabelOutlet.text = @"";
        _addressLabelOutlet.frame = CGRectMake(alf.origin.x, atf.origin.y + atf.size.height + 0.0f, alf.size.width, 0.0f);
        alf = _addressLabelOutlet.frame;
    } else {
        _addressTitle.frame = CGRectMake(atf.origin.x, dlf.origin.y + dlf.size.height + 15.0f, atf.size.width, atf.size.height);
        atf = _addressTitle.frame;
        
        _addressLabelOutlet.text = alt;
//        [_addressLabelOutlet sizeToFit];
        CGSize size = [_addressLabelOutlet sizeThatFits:CGSizeMake(alf.size.width, CGFLOAT_MAX)];
        alf.size.height = size.height;
        _addressLabelOutlet.frame = alf;
        alf = _addressLabelOutlet.frame;
        
        _addressLabelOutlet.frame = CGRectMake(alf.origin.x, atf.origin.y + atf.size.height + 4.0f, alf.size.width, alf.size.height);
        alf = _addressLabelOutlet.frame;
    }
    
    CGRect pf = _policiesTitle.frame;
    _policiesTitle.frame = CGRectMake(pf.origin.x, alf.origin.y + alf.size.height + 15.0f, pf.size.width, pf.size.height);
    pf = _policiesTitle.frame;
    
    NSString *pt = [NSString stringWithFormat:@"%@%@", hd.checkInInstructionsFormatted, hd.propertyInformationFormatted];
    _policiesLabel.text = pt;
//    [_policiesLabel sizeToFit];
    CGRect plf = _policiesLabel.frame;
    CGSize size = [_policiesLabel sizeThatFits:CGSizeMake(plf.size.width, CGFLOAT_MAX)];
    plf.size.height = size.height;
    _policiesLabel.frame = plf;
    _policiesLabel.frame = CGRectMake(plf.origin.x, pf.origin.y + pf.size.height + 4.0f, plf.size.width, plf.size.height);
    _policiesLabelIsSet = YES;
    
    [self appendPaymentTypesToPoliciesLabel];
}

- (void)appendPaymentTypesToPoliciesLabel {
    if (_paymentTypesReturned && _policiesLabelIsSet) {
        if (_paymentTypesBulletted) {
            NSString *pta = [_policiesLabel.text stringByAppendingString:_paymentTypesBulletted];
            _policiesLabel.text = pta;
        }
//        [_policiesLabel sizeToFit];
        CGRect plf = _policiesLabel.frame;
        CGSize size = [_policiesLabel sizeThatFits:CGSizeMake(plf.size.width, CGFLOAT_MAX)];
        plf.size.height = size.height;
        _policiesLabel.frame = plf;
    }
    
    [self finishOffTheLabels];
}

- (void)finishOffTheLabels {
    CGRect plf = _policiesLabel.frame;
    
    CGRect ftf = _feesTitle.frame;
    CGRect flf = _feesLabel.frame;
    if (stringIsEmpty(_eanHotelInformationResponse.hotelDetails.roomFeesDescriptionFormmatted)) {
        _feesTitle.text = @"";
        _feesTitle.frame = CGRectMake(ftf.origin.x, plf.origin.y + plf.size.height + 0.0f, ftf.size.width, 0.0f);
        ftf = _feesTitle.frame;
        
        _feesLabel.text = @"";
        _feesLabel.frame = CGRectMake(flf.origin.x, ftf.origin.y + ftf.size.height + 0.0f, flf.size.width, 0.0f);
        flf = _feesLabel.frame;
    } else {
        _feesTitle.text = @"Fees";
        _feesTitle.frame = CGRectMake(ftf.origin.x, plf.origin.y + plf.size.height + 15.0f, ftf.size.width, 21.0f);
        ftf = _feesTitle.frame;
        
        _feesLabel.text = self.eanHotelInformationResponse.hotelDetails.roomFeesDescriptionFormmatted;
//        [_feesLabel sizeToFit];
        CGSize size = [_feesLabel sizeThatFits:CGSizeMake(flf.size.width, CGFLOAT_MAX)];
        flf.size.height = size.height;
        _feesLabel.frame = flf;
        flf = _feesLabel.frame;
        
        _feesLabel.frame = CGRectMake(flf.origin.x, ftf.origin.y + ftf.size.height + 4.0f, flf.size.width, flf.size.height);
        flf = _feesLabel.frame;
    }
    
    CGRect barf = _bookRoomContainer.frame;
    _bookRoomContainer.frame = CGRectMake(barf.origin.x, flf.origin.y + flf.size.height + 15.0f, barf.size.width, barf.size.height);
    barf = _bookRoomContainer.frame;
    
    _scrollViewOutlet.contentSize = CGSizeMake(_scrollViewOutlet.frame.size.width, barf.origin.y + barf.size.height + 67.0f);
    [self dropTheSpinnerAlready:NO];
}

- (void)dropTheSpinnerAlready:(BOOL)justDoIt {
    if (!justDoIt && (!_paymentTypesReturned || !_policiesLabelIsSet || !_firstImageArrived)) {
        return;
    }
    
    if (_alreadyDroppedSpinner) {
        return;
    }
    _alreadyDroppedSpinner = YES;
    
    AppDelegate *ad = [[UIApplication sharedApplication] delegate];
    [ad dropDaSpinnerAlreadyWithForce:NO];
}

- (void)prepareTheSelectRoomViewControllerWithPlaceholderImage:(UIImage *)phi {
    self.selectRoomViewController = [[SelectRoomViewController alloc] initWithPlaceholderImage:phi];
    SelectionCriteria *sc = [SelectionCriteria singleton];
    [[LoadEanData sharedInstance:self.selectRoomViewController] loadAvailableRoomsWithHotelId:[_eanHotel.hotelId stringValue]
                                                         arrivalDate:sc.arrivalDateEanString
                                                       departureDate:sc.returnDateEanString
                                                      numberOfAdults:sc.numberOfAdults
                                                      childTravelers:[ChildTraveler childTravelers]];
}

- (void)gotoSelectRoomVC {
    if (nil == _selectRoomViewController) {
        UIImage *image = nil;
        for (int j = 0; j < [[_imageScrollerOutlet subviews] count]; j++) {
            UIView *ivc = [_imageScrollerOutlet viewWithTag:kRoomImageViewContainersStartingTag + j];
            UIImageView *iv = (UIImageView *) [ivc viewWithTag:kRoomImageViewsStartingTag + j];
            if (nil != iv || nil != iv.image) {
                image = iv.image;
                break;
            }
        }
        
        [self prepareTheSelectRoomViewControllerWithPlaceholderImage:image];
    }
    [self.navigationController pushViewController:self.selectRoomViewController animated:YES];
}

- (void)loadDaMap {
    __weak UIScrollView *sv = _scrollViewOutlet;
    __weak UIView *mc = _mapContainerOutlet;
    __weak UIView *mv = _mapView;
    [mc sendSubviewToBack:_mapOverlay];
    [mc bringSubviewToFront:mv];
    [sv bringSubviewToFront:mc];
    mapRectInScroller = mc.frame;
    _mapOverlay.frame = CGRectZero;
    
    NavigationView *nv = (NavigationView *) [self.view viewWithTag:kNavigationViewTag];
    [self.view bringSubviewToFront:nv];
    [nv animateToCancel];
    
    sv.scrollEnabled = NO;
    
    [UIView animateWithDuration:kHiAnimationDuration animations:^{
        mc.frame = CGRectMake(0, sv.contentOffset.y, 320, 504);
        mv.frame = mc.bounds;
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)dropDaMap {
    __weak UIScrollView *sv = _scrollViewOutlet;
    __weak UIView *mc = _mapContainerOutlet;
    __weak UIView *mo = _mapOverlay;
    __weak UIView *mv = _mapView;
    __block CGRect mcf = mapRectInScroller;
    
    NavigationView *nv = (NavigationView *) [self.view viewWithTag:kNavigationViewTag];
    [self.view bringSubviewToFront:nv];
    [nv animateToBack];
    
    sv.scrollEnabled = YES;
    
    [UIView animateWithDuration:kHiAnimationDuration animations:^{
        mc.frame = mcf;
        mo.frame = mc.bounds;
        mv.center = CGPointMake(160, 100);
    } completion:^(BOOL finished) {
        [sv sendSubviewToBack:mc];
        [mc sendSubviewToBack:mv];
        [mc bringSubviewToFront:mo];
    }];
}

- (void)clickTheImage:(UITapGestureRecognizer *)gesture {
    if (gesture.view.frame.origin.y == kImageScrollerStartY) {
        [self loadDaPrettyPictures];
    } else {
        [self dropDaPrettyPictures];
    }
}

- (void)rotateOrNot {
    NSUInteger dvo = [[UIDevice currentDevice] orientation];
    if (dvo == _currentOrientation) {
        NSLog(@"SAME ORIENTATION");
        return;
    }
    
    if (_imageScrollerOutlet.frame.origin.y == kImageScrollerStartY) {
        return;
    }
    
    switch (dvo) {
        case HI_PORTRAIT: {
            _currentOrientation = HI_PORTRAIT;
            [self letsFlip];
            break;
        }
        case HI_LANDSCAPE_LEFT: {
            _currentOrientation = HI_LANDSCAPE_LEFT;
            [self letsFlip];
            break;
        }
        case HI_LANDSCAPE_RIGHT: {
            _currentOrientation = HI_LANDSCAPE_RIGHT;
            [self letsFlip];
            break;
        }
            
        default: {
            _currentOrientation = HI_PORTRAIT;
            [self letsFlip];
            break;
        }
    }
}

- (CGFloat)angleFromOrientation:(HI_ORIENTATION)ho {
    switch (ho) {
        case HI_PORTRAIT:
            return 0.0f;
            break;
        case HI_LANDSCAPE_LEFT:
            return 90.0f;
            break;
        case HI_LANDSCAPE_RIGHT:
            return -90.0f;
            break;
            
        default:
            return 0.0f;
            break;
    }
}

- (CGPoint)pnpo:(HI_ORIENTATION)ho {
    switch (ho) {
        case HI_PORTRAIT:
            return CGPointMake(-131, -150);
            break;
        case HI_LANDSCAPE_LEFT:
            return CGPointMake(-131, -150);
            break;
        case HI_LANDSCAPE_RIGHT:
            return CGPointMake(-251, -274);
            break;
            
        default:
            return CGPointMake(-131, -150);
            break;
    }
}

CGAffineTransform CGAffineTransformMakeRotationAt(CGFloat angle, CGPoint pt){
    const CGFloat fx = pt.x, fy = pt.y, fcos = cos(angle), fsin = sin(angle);
    return CGAffineTransformMake(fcos, fsin, -fsin, fcos, fx - fx * fcos + fy * fsin, fy - fx * fsin - fy * fcos);
}

- (void)letsFlip {
    __weak UIScrollView *iso = _imageScrollerOutlet;
    __weak UIImageView *civ = [self currentImageView];
    __weak UIView *pnl = _pageNumberLabel;
    
    iso.contentMode = UIViewContentModeCenter;
    
    CGFloat targetAngle = [self angleFromOrientation:_currentOrientation];
    CGAffineTransform t = CGAffineTransformMakeRotation(degreesToRadians(targetAngle));
    CGAffineTransform tp = CGAffineTransformMakeRotationAt(degreesToRadians(targetAngle), [self pnpo:_currentOrientation]);
    
    CGRect civRect = [self rectForOrient:_currentOrientation];
    
    [UIView animateWithDuration:kHiAnimationDuration animations:^{
        iso.transform = t;
        civ.frame = civRect;
        pnl.transform = tp;
    } completion:^(BOOL finished) {
        for (int j = 0; j < [[iso subviews] count]; j++) {
            UIView *wivc = [iso viewWithTag:kRoomImageViewContainersStartingTag + j];
            UIImageView *wiv = (UIImageView *) [wivc viewWithTag:kRoomImageViewsStartingTag + j];
            wiv.frame = civRect;
        }
    }];
}

- (CGRect)rectForOrient:(HI_ORIENTATION)ho {
    switch (ho) {
        case HI_PORTRAIT:
            return CGRectMake(70, 0, 360.0f, kImageScrollerPortraitHeight);
            break;
        case HI_LANDSCAPE_LEFT:
            return CGRectMake(10, 90, 480.0f, 320);
            break;
        case HI_LANDSCAPE_RIGHT:
            return CGRectMake(10, 90, 480.0f, 320);
            break;
            
        default:
            return CGRectMake(70, 0, 360.0f, kImageScrollerPortraitHeight);
            break;
    }
}

- (BOOL)prefersStatusBarHidden {
    return _hideEffinStatusBar;
}

- (void)loadDaPrettyPictures {
    _currentOrientation = HI_PORTRAIT;
    
    _hideEffinStatusBar = YES;
    
    __weak UIScrollView *sv = _scrollViewOutlet;
    sv.scrollEnabled = NO;
    [self.view bringSubviewToFront:sv];
    UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, -200, 320, 1168)];
    overlay.tag = 10920983;
    overlay.userInteractionEnabled = YES;
    overlay.backgroundColor = [UIColor blackColor];
    overlay.alpha = 0.0f;
    [sv addSubview:overlay];
    [sv bringSubviewToFront:overlay];
    
    __weak UIView *iso = _imageScrollerOutlet;
    [sv bringSubviewToFront:iso];
    
    __weak UIView *pnl = _pageNumberLabel;
    [sv bringSubviewToFront:pnl];
    
    __weak UIImageView *civ = [self currentImageView];
    CGRect civFrame = [self rectForOrient:_currentOrientation];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:kHiAnimationDuration animations:^{
        sv.frame = CGRectMake(0, 0, 320, 549+64);
        overlay.alpha = 1.0;
        iso.frame = CGRectMake(iso.frame.origin.x, kImageScrollerPortraitY + sv.contentOffset.y, iso.frame.size.width, kImageScrollerPortraitHeight);
        civ.frame = civFrame;
        pnl.frame = CGRectMake(260, 545 + sv.contentOffset.y, 58, 21);
        [weakSelf setNeedsStatusBarAppearanceUpdate];
    } completion:^(BOOL finished) {
        for (int j = 0; j < [[iso subviews] count]; j++) {
            UIView *wivc = [iso viewWithTag:kRoomImageViewContainersStartingTag + j];
            UIImageView *wiv = (UIImageView *) [wivc viewWithTag:kRoomImageViewsStartingTag + j];
            wiv.frame = civFrame;
        }
    }];
}

- (void)dropDaPrettyPictures {
    _hideEffinStatusBar = NO;
    
    if (_currentOrientation != HI_PORTRAIT) {
        _currentOrientation = HI_PORTRAIT;
        [self letsFlip];
    }
    
    __weak UIView *overlay = [self.view viewWithTag:10920983];
    __weak UIScrollView *iso = _imageScrollerOutlet;
    __weak UIScrollView *sv = _scrollViewOutlet;
    sv.clipsToBounds = YES;
    [self.view bringSubviewToFront:sv];
    
    __weak UIImageView *civ = [self currentImageView];
    
    __weak UIView *pnl = _pageNumberLabel;
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:kHiAnimationDuration animations:^{
        sv.frame = CGRectMake(0, 64, 320, 549);
        overlay.alpha = 0.0f;
        iso.frame = CGRectMake(iso.frame.origin.x, kImageScrollerStartY, iso.frame.size.width, kImageScrollerStartHeight);
        civ.frame = [weakSelf rectForOrient:HI_PORTRAIT];
        civ.center = CGPointMake(250, 212);
        pnl.frame = CGRectMake(260, 203, 58, 21);
        [weakSelf setNeedsStatusBarAppearanceUpdate];
    } completion:^(BOOL finished) {
        sv.scrollEnabled = YES;
        [overlay removeFromSuperview];
        for (int j = 0; j < [[iso subviews] count]; j++) {
            UIView *wivc = [iso viewWithTag:kRoomImageViewContainersStartingTag + j];
            UIImageView *wiv = (UIImageView *) [wivc viewWithTag:kRoomImageViewsStartingTag + j];
            wiv.frame = [weakSelf rectForOrient:HI_PORTRAIT];
            wiv.center = CGPointMake(250, 212);
        }
    }];
}

#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Curtesy of http://stackoverflow.com/questions/5272228/detecting-uiscrollview-page-change
    static NSInteger previousPage = 0;
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    _currentPageNumber = 1 + lround(fractionalPage);
    if (previousPage != _currentPageNumber) {
        // Page has changed, do your thing!
        // ...
        _pageNumberLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)_currentPageNumber, (long)_totalNumberOfPages];
        
        // Finally, update previous page
        previousPage = _currentPageNumber;
    }
}

@end
