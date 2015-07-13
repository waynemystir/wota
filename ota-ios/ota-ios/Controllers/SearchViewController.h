//
//  SearchViewController.h
//  ota-ios
//
//  Created by WAYNE SMALL on 6/22/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadGooglePlacesData.h"
#import <MapKit/MapKit.h>

@class HotelListingViewController;

extern double const DEFAULT_RADIUS;

@interface SearchViewController : UIViewController <LoadDataProtocol, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *whereToTextField;
@property (weak, nonatomic) IBOutlet UILabel *whereToSecondLevel;
@property (nonatomic, strong) NSMutableArray *placesTableData;
@property (nonatomic, strong) UITableView *placesTableView;
@property (nonatomic) CGRect placesTableViewZeroFrame;
@property (nonatomic) CGRect placesTableViewExpandedFrame;
@property (nonatomic) BOOL isPlacesTableViewExpanded;
@property (nonatomic) NSTimeInterval animationDuraton;
@property (nonatomic, strong) MKMapView *mkMapView;
@property (nonatomic) CLLocationCoordinate2D zoomLocation;
@property (nonatomic) CLLocationDistance mapRadiusInMeters;
@property (nonatomic) CLLocationDistance mapRadiusInMiles;
@property (nonatomic) BOOL notMyFirstRodeo;
@property (nonatomic) BOOL redrawMapOnSelection;
@property (nonatomic) BOOL useMapRadiusForSearch;
@property (nonatomic) BOOL loadingGooglePlaceDetails;
@property (nonatomic, strong) NSString *tmpSelectedCellPlaceName;

- (void)animateTableViewExpansion;
- (void)animateTableViewCompression;
- (void)redrawMapViewAnimated:(BOOL)animated radius:(double)radius;
- (void)letsFindHotels:(HotelListingViewController *)hotelListingViewController
          searchRadius:(double)searchRadius
            withPushVC:(BOOL)pushVC;
- (void)dropDaSpinnerAlready;

@end
