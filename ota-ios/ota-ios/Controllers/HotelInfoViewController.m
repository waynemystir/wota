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

@interface HotelInfoViewController () <CLLocationManagerDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewOutlet;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollerOutlet;
@property (weak, nonatomic) IBOutlet UIPageControl *imagePageControlOutlet;
@property (weak, nonatomic) IBOutlet UILabel *someLabelOutlet;
@property (weak, nonatomic) IBOutlet UIView *mapContainerOutlet;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UILabel *addressLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *shortDescLabelOutlet;
@property (weak, nonatomic) IBOutlet UIButton *bookButtonOutlet;
@property (nonatomic, strong) EanHotelInformationResponse *eanHotelInformationResponse;

- (IBAction)justPushIt:(id)sender;

@end

@implementation HotelInfoViewController {
    GMSMapView *mapView_;
}

- (id)init {
    self = [super initWithNibName:@"HotelInfoView" bundle:nil];
    return self;
}

- (id)initWithHotel:(EanHotel *)eanHotel {
    self = [self init];
    if (self != nil) {
        _eanHotel = eanHotel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollViewOutlet.contentSize = CGSizeMake(320.0f, 900.0f);
    self.imageScrollerOutlet.contentSize = CGSizeMake(1900.0f, 195.0f);
    self.imageScrollerOutlet.delegate = self;
    
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
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(10, 10, 280, 280) camera:camera];
    mapView_.myLocationEnabled = YES;
    //    self.view = mapView_;
    [self.mapContainerOutlet addSubview:mapView_];
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(_eanHotel.latitude, _eanHotel.longitude);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = mapView_;
    
    self.addressLabelOutlet.text = _eanHotel.hotelName;
    self.shortDescLabelOutlet.text = _eanHotel.shortDescription;
}

- (void)requestStarted:(NSURL *)url {
    NSLog(@"%@.%@ URL:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [url absoluteString]);
}

- (void)requestFinished:(NSData *)responseData {
    self.eanHotelInformationResponse = [EanHotelInformationResponse hotelInfoFromData:responseData];
    [self loadupTheImageScroller];
    self.someLabelOutlet.text = [NSString stringWithFormat:@"lat:%f long:%f", _eanHotel.latitude, _eanHotel.longitude];
}

- (void)loadupTheImageScroller {
    NSArray *ims = self.eanHotelInformationResponse.hotelImagesArray;
    for (int j = 0; j < [ims count]; j++) {
        EanHotelInfoImage *image = [EanHotelInfoImage imageFromDict:ims[j]];
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(j * 320, 0, 320.0f, 195.0f)];
        [iv setImageWithURL:[NSURL URLWithString:image.url]];
        self.imageScrollerOutlet.contentSize = CGSizeMake(320 + j * 320, 195.0f);
        [self.imageScrollerOutlet addSubview:iv];
    }
}

- (IBAction)justPushIt:(id)sender {
    if (sender == self.bookButtonOutlet) {
        SelectRoomViewController *srvc = [SelectRoomViewController new];
        SelectionCriteria *sc = [SelectionCriteria singleton];
        [[LoadEanData sharedInstance:srvc] loadAvailableRoomsWithHotelId:_eanHotel.hotelId
                                                             arrivalDate:sc.arrivalDateEanString
                                                           departureDate:sc.returnDateEanString
                                                          numberOfAdults:sc.numberOfAdults
                                                          childTravelers:[ChildTraveler childTravelers]];
        [self.navigationController pushViewController:srvc animated:YES];
    }
}
@end
