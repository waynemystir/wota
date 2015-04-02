//
//  MapViewController.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/24/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>

@interface MapViewController () <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIView *mapContainerOutlet;
@property (weak, nonatomic) IBOutlet UIButton *currentLocationOutlet;
@property (nonatomic, strong) CLLocationManager *locationManager;

- (IBAction)justPushIt:(id)sender;

@end

@implementation MapViewController {
    GMSMapView *mapView_;
}

- (id)init {
    self = [super initWithNibName:@"MapView" bundle:nil];
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
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6];
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(10, 10, 280, 280) camera:camera];
    mapView_.myLocationEnabled = YES;
    //    self.view = mapView_;
    [self.mapContainerOutlet addSubview:mapView_];
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = mapView_;
}

- (IBAction)justPushIt:(id)sender {
    if (sender == self.currentLocationOutlet) {
        CLLocationDegrees latitude = self.locationManager.location.coordinate.latitude;
        CLLocationDegrees longitude = self.locationManager.location.coordinate.longitude;
        [self goToSomeLocationWithLatitude:latitude AndLongitude:longitude];
    }
}

- (void)goToSomeLocationWithLatitude:(CLLocationDegrees)latitude AndLongitude:(CLLocationDegrees)longitude {
    NSLog(@"The address is %f %f", latitude, longitude);
    
    CLLocationCoordinate2D target = CLLocationCoordinate2DMake(latitude, longitude);
    
    [mapView_ animateToLocation:target];
    [mapView_ animateToZoom:17];
}

#pragma mark CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    //    NSLog(@"%@.%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    //    NSLog(@"%@.%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    
    //    CLLocationDegrees latitude = self.locationManager.location.coordinate.latitude;
    //    CLLocationDegrees longitude = self.locationManager.location.coordinate.longitude;
    //
    //    NSLog(@"The address is %f %f", latitude, longitude);
    //
    //    CLLocationCoordinate2D target = CLLocationCoordinate2DMake(latitude, longitude);
    //
    //    [mapView_ animateToLocation:target];
    //    [mapView_ animateToZoom:17];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@.%@ ERROR:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [error localizedDescription]);
}

@end
