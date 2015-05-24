//
//  HotelInfoViewController.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/26/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "HotelInfoViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
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

@interface HotelInfoViewController () <CLLocationManagerDelegate, NavigationDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewOutlet;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollerOutlet;
@property (weak, nonatomic) IBOutlet UILabel *someLabelOutlet;
@property (weak, nonatomic) IBOutlet UIView *mapContainerOutlet;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UILabel *addressTitle;
@property (weak, nonatomic) IBOutlet UILabel *addressLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *shortDescLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *propAmenTities;
@property (weak, nonatomic) IBOutlet UILabel *policiesTitle;
@property (weak, nonatomic) IBOutlet UILabel *policiesLabel;
@property (weak, nonatomic) IBOutlet UIButton *bookButtonOutlet;
@property (weak, nonatomic) IBOutlet UILabel *amenitiesContainer;
@property (nonatomic, strong) EanHotelInformationResponse *eanHotelInformationResponse;
@property (nonatomic, strong) SelectRoomViewController *selectRoomViewController;

- (IBAction)justPushIt:(id)sender;

@end

@implementation HotelInfoViewController {
    GMSMapView *mapView_;
}

- (id)init {
    self = [super initWithNibName:@"HotelInfoView" bundle:nil];
    return self;
}

- (id)initWithHotel:(EanHotelListHotelSummary *)eanHotel {
    self = [self init];
    if (self != nil) {
        _eanHotel = eanHotel;
    }
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
    
    self.scrollViewOutlet.contentSize = CGSizeMake(320.0f, 900.0f);
    self.imageScrollerOutlet.contentSize = CGSizeMake(1900.0f, 195.0f);
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.delegate = self;
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:_eanHotel.latitude
                                                            longitude:_eanHotel.longitude
                                                                 zoom:6];
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(10, 10, 280, 180) camera:camera];
    mapView_.myLocationEnabled = YES;
    //Curtesy of http://stackoverflow.com/questions/26796466/ios-how-to-get-rid-of-app-is-using-your-location-notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    //    self.view = mapView_;
    [self.mapContainerOutlet addSubview:mapView_];
    [_mapContainerOutlet sendSubviewToBack:mapView_];
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(_eanHotel.latitude, _eanHotel.longitude);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = mapView_;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

-(void)appWillResignActive:(NSNotification*)note
{
    //Curtesy of http://stackoverflow.com/questions/26796466/ios-how-to-get-rid-of-app-is-using-your-location-notification
    mapView_.myLocationEnabled = NO;
}

- (void)clickBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickTitle {
    
}

- (void)requestStarted:(NSURL *)url {
    NSLog(@"%@.%@ URL:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [url absoluteString]);
}

- (void)requestFinished:(NSData *)responseData {
    self.eanHotelInformationResponse = [EanHotelInformationResponse eanObjectFromApiResponseData:responseData];
    [self loadupTheImageScroller];
    [self loadupTheAmenities];
    self.someLabelOutlet.text = [NSString stringWithFormat:@"lat:%f long:%f", _eanHotel.latitude, _eanHotel.longitude];
    
//    [self prepareTheSelectRoomViewController];
}

- (void)loadupTheImageScroller {
    NSArray *ims = self.eanHotelInformationResponse.hotelImagesArray;
    for (int j = 0; j < [ims count]; j++) {
        EanHotelInfoImage *eanInfoImage = [EanHotelInfoImage imageFromDict:ims[j]];
//        NSLog(@"WES %@", eanInfoImage.url);
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(j * 320, 0, 320.0f, 225.0f)];
        __weak typeof(UIImageView) *wiv = iv;
        [iv setImageWithURL:[NSURL URLWithString:eanInfoImage.url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (image.size.width > (1.3 * image.size.height)) {
                wiv.contentMode = UIViewContentModeScaleAspectFit;
            } else {
                wiv.contentMode = UIViewContentModeScaleAspectFill;
            }
            if (j == 0) {
                [self prepareTheSelectRoomViewControllerWithPlaceholderImage:image];
            }
        }];
        self.imageScrollerOutlet.contentSize = CGSizeMake(320 + j * 320, 195.0f);
        [self.imageScrollerOutlet addSubview:iv];
    }
}

- (void)loadupTheAmenities {
    EanHotelDetails *hd = self.eanHotelInformationResponse.hotelDetails;
    UILabel *so = _shortDescLabelOutlet;
    so.text = hd.locationDescription;
    [so sizeToFit];
    CGRect mf = _mapContainerOutlet.frame;
    _mapContainerOutlet.frame = CGRectMake(mf.origin.x, so.frame.origin.y + so.frame.size.height + 8.0f, mf.size.width, mf.size.height);
    mf = _mapContainerOutlet.frame;
    
    CGRect tf = _propAmenTities.frame;
    _propAmenTities.frame = CGRectMake(tf.origin.x, mf.origin.y + mf.size.height + 9.0f, tf.size.width, tf.size.height);
    tf = _propAmenTities.frame;
    
    CGRect acf = _amenitiesContainer.frame;
    _amenitiesContainer.frame = CGRectMake(acf.origin.x, tf.origin.y + tf.size.height + 9.0f, acf.size.width, acf.size.height);
    
    NSString *at = hd.amenitiesDescription;
    NSArray *ams = self.eanHotelInformationResponse.propertyAmenitiesArray;
    for (int j = 0; j < [ams count]; j++) {
        EanPropertyAmenity *pa = [EanPropertyAmenity amenityFromDict:ams[j]];
        at = [at stringByAppendingFormat:@"\n● %@", pa.amenity];
    }
    
    _amenitiesContainer.text = at;
    [_amenitiesContainer sizeToFit];
    acf = _amenitiesContainer.frame;
    
    NSString *sl = _eanHotel.stateProvinceCode ? [NSString stringWithFormat:@", %@", _eanHotel.stateProvinceCode] : @"";
    NSString *pcl = _eanHotel.postalCode ? [NSString stringWithFormat:@" %@", _eanHotel.postalCode] : @"";
    
    NSString *ccc = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    NSString *cl = @"";
    if (![ccc isEqualToString:_eanHotel.countryCode]) {
        NSString *countryName = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:_eanHotel.countryCode];
        cl = [NSString stringWithFormat:@"\n%@", countryName];
    }
    
    CGRect atf = _addressTitle.frame;
    _addressTitle.frame = CGRectMake(atf.origin.x, acf.origin.y + acf.size.height + 9.0f, atf.size.width, atf.size.height);
    atf = _addressTitle.frame;
    
    NSString *alt = [NSString stringWithFormat:@"%@\n%@\n%@%@%@%@", _eanHotel.hotelName, _eanHotel.address1, _eanHotel.city, sl, pcl, cl];
    _addressLabelOutlet.text = alt;
    [_addressLabelOutlet sizeToFit];
    
    CGRect alf = _addressLabelOutlet.frame;
    _addressLabelOutlet.frame = CGRectMake(alf.origin.x, atf.origin.y + atf.size.height + 9.0f, alf.size.width, alf.size.height);
    alf = _addressLabelOutlet.frame;
    
    CGRect pf = _policiesTitle.frame;
    _policiesTitle.frame = CGRectMake(pf.origin.x, alf.origin.y + alf.size.height + 9.0f, pf.size.width, pf.size.height);
    pf = _policiesTitle.frame;
    
    NSString *pt = [NSString stringWithFormat:@"%@%@", hd.checkInInstructionsFormatted, hd.propertyInformationFormatted];
    _policiesLabel.text = pt;
    [_policiesLabel sizeToFit];
    
    CGRect plf = _policiesLabel.frame;
    _policiesLabel.frame = CGRectMake(plf.origin.x, pf.origin.y + pf.size.height + 9.0f, plf.size.width, plf.size.height);
    plf = _policiesLabel.frame;
    
    _scrollViewOutlet.contentSize = CGSizeMake(_scrollViewOutlet.frame.size.width, plf.origin.y + plf.size.height + 64.0f + 10);
}

- (void)prepareTheSelectRoomViewControllerWithPlaceholderImage:(UIImage *)phi {
    self.selectRoomViewController = [[SelectRoomViewController alloc] initWithPlaceholderImage:phi];
    SelectionCriteria *sc = [SelectionCriteria singleton];
    [[LoadEanData sharedInstance:self.selectRoomViewController] loadAvailableRoomsWithHotelId:_eanHotel.hotelId
                                                         arrivalDate:sc.arrivalDateEanString
                                                       departureDate:sc.returnDateEanString
                                                      numberOfAdults:sc.numberOfAdults
                                                      childTravelers:[ChildTraveler childTravelers]];
}

- (IBAction)justPushIt:(id)sender {
    if (sender == self.bookButtonOutlet) {
        [self.navigationController pushViewController:self.selectRoomViewController animated:YES];
    }
}
@end
