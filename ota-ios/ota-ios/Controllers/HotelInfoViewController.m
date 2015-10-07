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
#import "UIImageView+WebCache.h"
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
#import "ImageViewHotelInfo.h"

#define degreesToRadians(x) (M_PI * x / 180.0)
#define METERS_PER_MILE 1609.344

typedef NS_ENUM(NSUInteger, HI_ORIENTATION) {
    HI_ORIENTATION_UNKNOWN = UIDeviceOrientationUnknown,
    HI_PORTRAIT = UIDeviceOrientationPortrait,
    HI_PORTRAIT_UPSIDE_DOWN = UIDeviceOrientationPortraitUpsideDown,
    HI_LANDSCAPE_LEFT = UIDeviceOrientationLandscapeLeft,
    HI_LANDSCAPE_RIGHT = UIDeviceOrientationLandscapeRight,
    HI_FLAT_FACE_UP = UIDeviceOrientationFaceUp,
    HI_FLAT_FACE_DOWN = UIDeviceOrientationFaceDown
};

NSUInteger const kImageBatchSize = 20;
NSUInteger const kImageBatchStartNext = 13;
NSTimeInterval const kHiAnimationDuration = 0.43;
CGFloat const kImageScrollerStartY = -112.0f;
CGFloat const kImageFrameCenterY = 208;
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

@property (nonatomic) BOOL alreadyDroppedSpinner;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewOutlet;
@property (weak, nonatomic) IBOutlet UIView *contentView;
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
//@property (nonatomic, strong) SelectRoomViewController *selectRoomViewController;
@property (nonatomic) BOOL paymentTypesReturned;
@property (nonatomic) BOOL paymentTypesAddedToPoliciesLabel;
@property (nonatomic) BOOL policiesLabelIsSet;
@property (nonatomic, strong) NSString *paymentTypesBulletted;
@property (weak, nonatomic) IBOutlet UILabel *pageNumberLabel;
@property (weak, nonatomic) IBOutlet UIView *imageDisclaimerContainer;
@property (weak, nonatomic) IBOutlet WotaTappableView *bookRoomContainer;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSString *locationString;
@property (nonatomic, strong) NSMutableArray *eanImages;
@property (nonatomic, strong) UIImage *placeHolderImage;
@property (nonatomic, strong) NSMutableArray *imageBatchesAlreadyLoaded;
@property (nonatomic) CGRect sr;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapContainerHeightConstr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapContainerBottomConstr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageScrollerTopConstr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageScrollerBottomConstr1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageScrollerBottomConstr2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageScrollerHeightConstr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageScrollerWidthConstr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewTopConstr;

@property (nonatomic) CGFloat picPageWidth;

@end

@implementation HotelInfoViewController {
    CGRect mapRectInScroller;
}

#pragma mark Lifecycle

- (id)init {
    if (self = [super initWithNibName:@"HotelInfoVw" bundle:nil]) {
        _sr = [[UIScreen mainScreen] bounds];
        _picPageWidth = _sr.size.height - 68;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    TrotterLog(@"WARNING:%s", __PRETTY_FUNCTION__);
}

- (id)initWithHotel:(EanHotelListHotelSummary *)eanHotel {
    self = [self init];
    if (self != nil) {
        _eanHotel = eanHotel;
        
        [[LoadEanData sharedInstance] loadPaymentTypesWithHotelId:[_eanHotel.hotelId stringValue] supplierType:_eanHotel.supplierType rateType:_eanHotel.roomRateDetails.rateInfo.rateType completionBlock:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            _paymentTypesBulletted = [EanPaymentTypeResponse eanObjectFromApiResponseData:data].paymentTypesBulletted;
            _paymentTypesReturned = YES;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self appendPaymentTypesToPoliciesLabel];
            });
            
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
    
    CGRect sf = [[UIScreen mainScreen] bounds];
    if (sf.size.height == 480) {
        self.view.transform = kIpadTransform();
    }
    
    self.currentOrientation = HI_PORTRAIT;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotateOrNot) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    self.scrollViewOutlet.scrollsToTop = YES;
    self.scrollViewOutlet.delaysContentTouches = NO;
    self.imageScrollerOutlet.delegate = self;
//    self.imageScrollerOutlet.contentSize = CGSizeMake(1900.0f, 195.0f);
    
    _fromRateContainer.tapColor = kTheColorOfMoney();
    _fromRateContainer.untapColor = [UIColor clearColor];
    _fromRateContainer.backgroundColor = [UIColor clearColor];
    _fromRateContainer.borderColor = kTheColorOfMoney();
    _fromRateContainer.userInteractionEnabled = YES;
    
    NSNumberFormatter *cf = kPriceRoundOffFormatter(_eanHotel.rateCurrencyCode);
    NSString *price = [NSString stringWithFormat:@"From %@/nt", [cf stringFromNumber:_eanHotel.lowRate]];
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
    
    UIView *idv = [[NSBundle mainBundle] loadNibNamed:@"ImageDisclaimerView" owner:nil options:nil].firstObject;
    [_imageDisclaimerContainer addSubview:idv];
    
    NSURL *iu = [NSURL URLWithString:[_eanHotel tripAdvisorRatingUrl]];
    [_tripAdvisorImageView sd_setImageWithURL:iu placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
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
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = _eanHotel.latitude;
    zoomLocation.longitude= _eanHotel.longitude;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.4*METERS_PER_MILE, 0.4*METERS_PER_MILE);
    [_mapView setRegion:viewRegion];
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        _mapView.showsUserLocation = YES;
    }
    
    MKPointAnnotation *hotelAnnotation = [[MKPointAnnotation alloc] init];
    hotelAnnotation.coordinate = CLLocationCoordinate2DMake(_eanHotel.latitude, _eanHotel.longitude);
    hotelAnnotation.title = _eanHotel.hotelNameFormatted;
    hotelAnnotation.subtitle = [NSString stringWithFormat:@"From %@/nt", [cf stringFromNumber:_eanHotel.lowRate]];
    [_mapView addAnnotation:hotelAnnotation];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_contentView
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil 
                                                                     attribute:NSLayoutAttributeNotAnAttribute 
                                                                    multiplier:1.0 
                                                                      constant:_sr.size.width]];
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
    
    for (int j = 1; j <= stars.count; j++) {
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
    TrotterLog(@"%@.%@ URL:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [[[connection currentRequest] URL] absoluteString]);
}

- (void)requestFinished:(NSData *)responseData dataType:(LOAD_DATA_TYPE)dataType {
    self.eanHotelInformationResponse = [EanHotelInformationResponse eanObjectFromApiResponseData:responseData];
    [self loadupTheImageScroller];
    [self loadupTheAmenities];
}

- (void)requestTimedOut:(LOAD_DATA_TYPE)dataType {
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

- (void)requestFailedCredentials {
    [self dropTheSpinnerAlready:YES];
    __weak typeof(self) wes = self;
    [NetworkProblemResponder launchWithSuperView:self.view headerTitle:@"System Error" messageString:@"Sorry for the inconvenience. We are experiencing a technical issue. Please try again shortly." completionCallback:^{
        [wes.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)requestFailed {
    [self dropTheSpinnerAlready:YES];
    __weak typeof(self) wes = self;
    [NetworkProblemResponder launchWithSuperView:self.view headerTitle:@"An Error Occurred" messageString:@"Please try again." completionCallback:^{
        [wes.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark Various

- (UIImage *)placeHolderImage {
    return _placeHolderImage ? : (_placeHolderImage = [UIImage imageNamed:@"hotel_info"]);
}

- (NSMutableArray *)eanImages {
    return _eanImages ? : (_eanImages = [NSMutableArray array]);
}

- (NSMutableArray *)imageBatchesAlreadyLoaded {
    return _imageBatchesAlreadyLoaded ? : (_imageBatchesAlreadyLoaded = [@[] mutableCopy]);
}

- (UIImageView *)currentImageView {
    NSInteger cp = _currentPageNumber - 1;
    UIView *civc = [_imageScrollerOutlet viewWithTag:kRoomImageViewContainersStartingTag + cp];
    UIImageView *civ = (UIImageView *) [civc viewWithTag:kRoomImageViewsStartingTag + cp];
    return civ;
}

- (void)loadupTheImageScroller {
    _imageScrollerWidthConstr.constant = _picPageWidth;
    NSArray *ims = self.eanHotelInformationResponse.hotelImagesArray;
    for (int j = 0; j < [ims count]; j++) {
        UIView *ivc = [[UIView alloc] initWithFrame:CGRectMake(j * _picPageWidth, 0, _picPageWidth, 325.0f)];
        ivc.backgroundColor = [UIColor blackColor];
        ivc.tag = kRoomImageViewContainersStartingTag + j;
        [_imageScrollerOutlet addSubview:ivc];
        
        ImageViewHotelInfo *iv = [[ImageViewHotelInfo alloc] initWithFrame:[self rectForOrient:HI_PORTRAIT]];
        iv.backgroundColor = [UIColor blackColor];
        iv.contentMode = UIViewContentModeScaleAspectFit;
        iv.clipsToBounds = YES;
        iv.tag = kRoomImageViewsStartingTag + j;
        iv.image = self.placeHolderImage;
        iv.containsPlaceholderImage = YES;
        iv.frame = [self rectForOrient:HI_PORTRAIT];
        iv.center = CGPointMake(_picPageWidth/2, kImageFrameCenterY);
        [ivc addSubview:iv];
        
        EanHotelInfoImage *eii = [EanHotelInfoImage imageFromDict:ims[j]] ? : [EanHotelInfoImage new];
        if (eii) [self.eanImages addObject:eii];
    }
    
    [self loadImageBatch:0];
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTheImage:)];
    tgr.numberOfTapsRequired = tgr.numberOfTouchesRequired = 1;
    [_imageScrollerOutlet addGestureRecognizer:tgr];
    _imageScrollerOutlet.userInteractionEnabled = YES;
    
    _imageScrollerOutlet.contentSize = CGSizeMake(_picPageWidth * [ims count], 325);
    _currentPageNumber = 1;
    _totalNumberOfPages = [ims count];
    _pageNumberLabel.text = [NSString stringWithFormat:@"1/%lu", (unsigned long)[ims count]];
}

- (void)loadImageBatch:(int)j {
    if (j < self.imageBatchesAlreadyLoaded.count) return;
    else [self.imageBatchesAlreadyLoaded addObject:@(j)];
    
    int start = kImageBatchSize * j;
    NSUInteger end = MIN((start + kImageBatchSize), self.eanImages.count);
    while (start < end) [self loadTheImage:start++];
}

- (void)loadTheImage:(int)j {
    EanHotelInfoImage *eii = self.eanImages[j];
    
    __weak UIView *ivc = [_imageScrollerOutlet viewWithTag:(kRoomImageViewContainersStartingTag + j)];
    __weak typeof(ImageViewHotelInfo) *wiv = (ImageViewHotelInfo *) [ivc viewWithTag:(kRoomImageViewsStartingTag + j)];
    __weak typeof(self) wes = self;
    
    [wiv sd_setImageWithURL:[NSURL URLWithString:eii.url]
           placeholderImage:wes.placeHolderImage
                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                      
                      wiv.frame = [wes rectForOrient:wes.currentOrientation];
                      if (!wes.hideEffinStatusBar) {
                          wiv.center = CGPointMake(wes.picPageWidth/2, kImageFrameCenterY);
                      }
                      wiv.containsPlaceholderImage = NO;
    }];
}

- (void)loadupTheAmenities {
    EanHotelDetails *hd = self.eanHotelInformationResponse.hotelDetails;
    UILabel *so = _shortDescLabelOutlet;
    [so setPreferredMaxLayoutWidth:_sr.size.width - 16];
    so.text = hd.locationDescription;
    
    if (stringIsEmpty(hd.amenitiesDescription) && [self.eanHotelInformationResponse.propertyAmenitiesArray count] == 0) {
        _propAmenTities.text = @"";
        _amenitiesContainer.text = @"";
        _propAmenTities.hidden = _amenitiesContainer.hidden = YES;
    } else {
        NSString *at = !stringIsEmpty(hd.amenitiesDescription) ? [hd.amenitiesDescription stringByAppendingString:@"\n"] : @"";
        NSArray *ams = self.eanHotelInformationResponse.propertyAmenitiesArray;
        for (int j = 0; j < [ams count]; j++) {
            EanPropertyAmenity *pa = [EanPropertyAmenity amenityFromDict:ams[j]];
            NSString *wes = (stringIsEmpty(hd.amenitiesDescription) && j == 0) ? @"● %@" : @"\n● %@";
            at = [at stringByAppendingFormat:wes, pa.amenityName];
        }
        
        _amenitiesContainer.text = at;
        [_amenitiesContainer setPreferredMaxLayoutWidth:_sr.size.width - 16];
        _propAmenTities.hidden = _amenitiesContainer.hidden = NO;
    }
    
    if (stringIsEmpty(hd.diningDescription)) {
        _diningTitle.text = @"";
        _diningLabel.text = @"";
        _diningTitle.hidden = _diningLabel.hidden = YES;
    } else {
        _diningLabel.text = stringByStrippingHTML(hd.diningDescription);
        [_diningLabel setPreferredMaxLayoutWidth:_sr.size.width - 16];
        _diningTitle.hidden = _diningLabel.hidden = NO;
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
    self.locationString = [NSString stringWithFormat:@"%@%@%@", _eanHotel.city, sl, cl];
    
    if (stringIsEmpty(alt)) {
        _addressTitle.text = @"";
        _addressLabelOutlet.text = @"";
    } else {
        _addressLabelOutlet.text = alt;
        [_addressLabelOutlet setPreferredMaxLayoutWidth:_sr.size.width - 16];
    }
    
    NSString *pcid = stringIsEmpty(hd.checkInInstructionsFormatted) ? @"" : @"\n";
    pcid = stringIsEmpty(hd.hotelPolicy) ? @"" : [NSString stringWithFormat:@"%@● ", pcid];
    NSString *pt = [NSString stringWithFormat:@"%@%@%@%@", hd.checkInInstructionsFormatted, pcid, hd.hotelPolicy, hd.propertyInformationFormatted];
    _policiesLabel.text = pt;
    [_policiesLabel setPreferredMaxLayoutWidth:_sr.size.width - 16];
    
    _policiesLabelIsSet = YES;
    [self appendPaymentTypesToPoliciesLabel];
}

- (void)appendPaymentTypesToPoliciesLabel {
    if (!_paymentTypesAddedToPoliciesLabel && _paymentTypesReturned && _policiesLabelIsSet) {
        _paymentTypesAddedToPoliciesLabel = YES;
        if (_paymentTypesBulletted) {
            NSString *pta = [_policiesLabel.text stringByAppendingString:_paymentTypesBulletted];
            _policiesLabel.text = pta;
        }
    }
    
    [self finishOffTheLabels];
}

- (void)finishOffTheLabels {
    if (stringIsEmpty(_eanHotelInformationResponse.hotelDetails.roomFeesDescriptionFormmatted)) {
        _feesTitle.text = @"";
        _feesLabel.text = @"";
    } else {
        _feesTitle.text = @"Fees";
        _feesLabel.text = self.eanHotelInformationResponse.hotelDetails.roomFeesDescriptionFormmatted;
        [_feesLabel setPreferredMaxLayoutWidth:_sr.size.width - 16];
    }
    
    [self dropTheSpinnerAlready:NO];
}

- (void)dropTheSpinnerAlready:(BOOL)justDoIt {
    if (!justDoIt && (!_paymentTypesReturned || !_policiesLabelIsSet /*|| !_firstImageArrived*/)) {
        return;
    }
    
    if (_alreadyDroppedSpinner) {
        return;
    }
    _alreadyDroppedSpinner = YES;
    
    AppDelegate *ad = [[UIApplication sharedApplication] delegate];
    [ad dropDaSpinnerAlreadyWithForce:NO];
}

- (void)prepareTheSelectRoomViewController {
//    if (self.selectRoomViewController) return;
    
    UIImage *image = nil;
    for (int j = 0; j < [[_imageScrollerOutlet subviews] count]; j++) {
        UIView *ivc = [_imageScrollerOutlet viewWithTag:kRoomImageViewContainersStartingTag + j];
        ImageViewHotelInfo *iv = (ImageViewHotelInfo *) [ivc viewWithTag:kRoomImageViewsStartingTag + j];
        if (iv && iv.image && !iv.containsPlaceholderImage) {
            image = iv.image;
            break;
        }
    }
    
    image = image ? : self.placeHolderImage;
    
    SelectRoomViewController *selectRoomViewController = [[SelectRoomViewController alloc] initWithPlaceholderImage:image hotelName:self.eanHotel.hotelNameFormatted locationName:self.locationString];
    SelectionCriteria *sc = [SelectionCriteria singleton];
    [[LoadEanData sharedInstance:selectRoomViewController] loadAvailableRoomsWithHotelId:[_eanHotel.hotelId stringValue]
                                                         arrivalDate:sc.arrivalDateEanString
                                                       departureDate:sc.returnDateEanString
                                                      numberOfAdults:sc.numberOfAdults
                                                                          childTravelers:[ChildTraveler childTravelers]];
    [self.navigationController pushViewController:selectRoomViewController animated:YES];
}

- (void)gotoSelectRoomVC {
    [self prepareTheSelectRoomViewController];
}

- (void)loadDaMap {
    NavigationView *nv = (NavigationView *) [self.view viewWithTag:kNavigationViewTag];
    [self.view bringSubviewToFront:nv];
    [nv animateToCancel];
    
    _scrollViewOutlet.scrollEnabled = NO;
    _mapOverlay.hidden = YES;
    
    [_contentView layoutIfNeeded];
    self.mapContainerHeightConstr.constant = _scrollViewOutlet.frame.size.height;
    self.mapContainerBottomConstr.constant = 200;
    [UIView animateWithDuration:kHiAnimationDuration animations:^{
        [_contentView layoutIfNeeded];
        self.mapContainerOutlet.frame = _scrollViewOutlet.bounds;
    } completion:^(BOOL finished) {
    }];
}

- (void)dropDaMap {
    NavigationView *nv = (NavigationView *) [self.view viewWithTag:kNavigationViewTag];
    [self.view bringSubviewToFront:nv];
    [nv animateToBack];
    
    _scrollViewOutlet.scrollEnabled = YES;
    _mapOverlay.hidden = NO;
    
    [_contentView layoutIfNeeded];
    self.mapContainerHeightConstr.constant = 200;
    self.mapContainerBottomConstr.constant = 19;
    [UIView animateWithDuration:kHiAnimationDuration animations:^{
        [_contentView layoutIfNeeded];
    } completion:^(BOOL finished) {
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
    if (dvo == _currentOrientation) return;
    
    if (_imageScrollerOutlet.frame.origin.y == kImageScrollerStartY) return;
    
    switch (dvo) {
        case HI_PORTRAIT_UPSIDE_DOWN:
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
            
        case HI_ORIENTATION_UNKNOWN:
        case HI_FLAT_FACE_UP:
        case HI_FLAT_FACE_DOWN:
        default: {
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
    CGFloat w = _sr.size.height;
    switch (ho) {
        case HI_PORTRAIT:
            return CGPointMake(-131, -150);
            break;
        case HI_LANDSCAPE_LEFT:
            return w == 568 ? CGPointMake(-131, -150) : w == 667 ? CGPointMake(-158, -177) : w == 736 ? CGPointMake(-177, -196) : CGPointMake(-131, -150);
            break;
        case HI_LANDSCAPE_RIGHT:
            return w == 568 ? CGPointMake(-251, -274) : w == 667 ? CGPointMake(-299, -322) : w == 736 ? CGPointMake(-334, -357) : CGPointMake(-251, -274);
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
            return CGRectMake((_picPageWidth - _sr.size.width - 20)/2, 0, _sr.size.width + 20, _sr.size.height);
            break;
        case HI_LANDSCAPE_LEFT:
            return CGRectMake(0, (_sr.size.height - _sr.size.width)/2, _picPageWidth, _sr.size.width);
            break;
        case HI_LANDSCAPE_RIGHT:
            return CGRectMake(0, (_sr.size.height - _sr.size.width)/2, _picPageWidth, _sr.size.width);
            break;
            
        default:
            return CGRectMake((_picPageWidth - _sr.size.width - 20)/2, 0, _sr.size.width + 20, _sr.size.height);
            break;
    }
}

- (BOOL)prefersStatusBarHidden {
    return _hideEffinStatusBar;
}

- (void)loadDaPrettyPictures {
    _currentOrientation = HI_PORTRAIT;
    
    _hideEffinStatusBar = YES;
    
    __weak typeof(self) wes = self;
    __weak UIScrollView *sv = _scrollViewOutlet;
    sv.scrollEnabled = NO;
    [self.view bringSubviewToFront:sv];
    UIView *overlay = [self imagerOverlay];
    [wes.view addSubview:overlay];
    [wes.view bringSubviewToFront:overlay];
    
    __weak UIView *iso = _imageScrollerOutlet;
    [sv bringSubviewToFront:iso];
    
    __weak UIView *pnl = _pageNumberLabel;
    [sv bringSubviewToFront:pnl];
    
    __weak UIImageView *civ = [self currentImageView];
    CGRect civFrame = [self rectForOrient:_currentOrientation];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [wes.view layoutIfNeeded];
    wes.scrollViewTopConstr.constant = -32;
    wes.imageScrollerTopConstr.constant = kImageScrollerPortraitY + sv.contentOffset.y;
    wes.imageScrollerHeightConstr.constant = _sr.size.height;
    [wes.view bringSubviewToFront:wes.scrollViewOutlet];
    [UIView animateWithDuration:kHiAnimationDuration animations:^{
        [wes.view layoutIfNeeded];
        civ.frame = civFrame;
        overlay.alpha = 1.0f;
        pnl.frame = CGRectMake(_sr.size.width - 60, _sr.size.height + sv.contentOffset.y + 8, 58, 21);
        [wes setNeedsStatusBarAppearanceUpdate];
    } completion:^(BOOL finished) {
        for (int j = 0; j < [[iso subviews] count]; j++) {
            UIView *wivc = [iso viewWithTag:kRoomImageViewContainersStartingTag + j];
            UIImageView *wiv = (UIImageView *) [wivc viewWithTag:kRoomImageViewsStartingTag + j];
            wiv.frame = civFrame;
        }
    }];
}

- (UIView *)imagerOverlay {
    UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, -200, _sr.size.width, 1168)];
    overlay.tag = 10920983;
    overlay.userInteractionEnabled = YES;
    overlay.backgroundColor = [UIColor blackColor];
    overlay.alpha = 0.0f;
    return overlay;
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
    
    __weak typeof(self) wes = self;
    [wes.view layoutIfNeeded];
    wes.scrollViewTopConstr.constant = 64;
    wes.imageScrollerTopConstr.constant = kImageScrollerStartY;
    wes.imageScrollerHeightConstr.constant = 325;
    [UIView animateWithDuration:kHiAnimationDuration animations:^{
        [wes.view layoutIfNeeded];
        civ.frame = [wes rectForOrient:HI_PORTRAIT];
        civ.center = CGPointMake(wes.picPageWidth/2, kImageFrameCenterY);
        overlay.alpha = 0.0f;
        pnl.frame = CGRectMake(_sr.size.width - 60, 193, 58, 21);
        [wes setNeedsStatusBarAppearanceUpdate];
    } completion:^(BOOL finished) {
        sv.scrollEnabled = YES;
        [overlay removeFromSuperview];
        for (int j = 0; j < [[iso subviews] count]; j++) {
            UIView *wivc = [iso viewWithTag:kRoomImageViewContainersStartingTag + j];
            UIImageView *wiv = (UIImageView *) [wivc viewWithTag:kRoomImageViewsStartingTag + j];
            wiv.frame = [wes rectForOrient:HI_PORTRAIT];
            wiv.center = CGPointMake(_picPageWidth/2, kImageFrameCenterY);
        }
    }];
}

#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Curtesy of http://stackoverflow.com/questions/5272228/detecting-uiscrollview-page-change
    static NSInteger previousPage = 0;
    CGFloat pageWidth = _picPageWidth;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    _currentPageNumber = 1 + lround(fractionalPage);
    if (previousPage != _currentPageNumber) {
        // Page has changed, do your thing!
        // ...
        _pageNumberLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)_currentPageNumber, (long)_totalNumberOfPages];
        
        // Update previous page
        previousPage = _currentPageNumber;
        
        // Check if we need to load the next batch of images
        if (_currentPageNumber % kImageBatchSize == kImageBatchStartNext)
            [self loadImageBatch:(1 + (int)(_currentPageNumber / kImageBatchSize))];
    }
}

@end
