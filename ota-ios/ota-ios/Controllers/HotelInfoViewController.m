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

@interface HotelInfoViewController () <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *someLabelOutlet;
@property (weak, nonatomic) IBOutlet UIView *mapContainerOutlet;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UILabel *addressLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *shortDescLabelOutlet;
@property (weak, nonatomic) IBOutlet UIButton *bookButtonOutlet;

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
    NSError *error = nil;
    id respDict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
    if (error != nil) {
        NSLog(@"ERROR");
    } else {
        NSLog(@"HOTELDETAIL:%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        self.someLabelOutlet.text = [NSString stringWithFormat:@"lat:%f long:%f", _eanHotel.latitude, _eanHotel.longitude];
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
