//
//  SearchViewController.m
//  ota-ios
//
//  Created by WAYNE SMALL on 6/22/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "SearchViewController.h"
#import "SelectionCriteria.h"
#import "PlaceAutoCompleteTableViewCell.h"
#import "GoogleParser.h"
#import "GooglePlace.h"
#import "GooglePlaceDetail.h"
#import "LoadEanData.h"
#import "HotelListingViewController.h"
#import "AppDelegate.h"

static int const kAutoCompleteMinimumNumberOfCharacters = 4;
double const DEFAULT_RADIUS = 5.0;
static double const METERS_PER_MILE = 1609.344;

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.placesTableView = [[UITableView alloc] initWithFrame:self.placesTableViewZeroFrame];
    self.placesTableView.backgroundColor = [UIColor whiteColor];
    self.placesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.placesTableView.separatorColor = [UIColor clearColor];
    self.placesTableView.dataSource = self;
    self.placesTableView.delegate = self;
    self.placesTableView.sectionHeaderHeight = 0.0f;
    [self.view addSubview:self.placesTableView];
    
    self.placesTableData = [SelectionCriteria singleton].placesArray;
    [self.placesTableView reloadData];
    
    self.whereToTextField.delegate = self;
    [self resetWhereToTfAppearance];
    self.whereToTextField.text = @"";//[SelectionCriteria singleton].whereToFirst;
    self.whereToSecondLevel.text = @"";//[SelectionCriteria singleton].whereToSecond;
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.notMyFirstRodeo) {
        self.placesTableData = [SelectionCriteria singleton].placesArray;
        [self.placesTableView reloadData];
    }
    
    self.notMyFirstRodeo = YES;
    
    [super viewWillAppear:animated];
}

#pragma mark UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (!_isPlacesTableViewExpanded) {
        [self animateTableViewExpansion];
    }
    
    self.whereToTextField.text = @"";
    self.whereToSecondLevel.text = @"";
    
    self.whereToTextField.layer.cornerRadius = WOTA_CORNER_RADIUS;
    self.whereToTextField.layer.borderColor = kWotaColorOne().CGColor;
    self.whereToTextField.layer.borderWidth = 1.0f;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *autoCompleteText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([autoCompleteText length] >= kAutoCompleteMinimumNumberOfCharacters) {
        [[LoadGooglePlacesData sharedInstance:self] autoCompleteSomePlaces:autoCompleteText];
    } else {
        return [self textFieldShouldClear:textField];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.whereToTextField resignFirstResponder];
    self.whereToTextField.text = [SelectionCriteria singleton].whereToFirst;
    self.whereToSecondLevel.text = [SelectionCriteria singleton].whereToSecond;
    [self animateTableViewCompression];
    
    return [self textFieldShouldClear:textField];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (self.placesTableData != [SelectionCriteria singleton].placesArray) {
        self.placesTableData = [SelectionCriteria singleton].placesArray;
        [self.placesTableView reloadData];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self resetWhereToTfAppearance];
}

#pragma mark LoadDataProtocol methods

- (void)requestStarted:(NSURL *)url {
    NSLog(@"%@.%@ loading URL:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [url absoluteString]);
}

- (void)requestFinished:(NSData *)responseData dataType:(LOAD_DATA_TYPE)dataType {
    switch (dataType) {
        case LOAD_GOOGLE_AUTOCOMPLETE: {
            self.placesTableData = [NSMutableArray arrayWithArray:[GoogleParser parseAutoCompleteResponse:responseData]];
            [self.placesTableView reloadData];
            break;
        }
            
        case LOAD_GOOGLE_PLACES: {
            [SelectionCriteria singleton].googlePlaceDetail = [GooglePlaceDetail placeDetailFromData:responseData];
            self.useMapRadiusForSearch = NO;
//            [[SelectionCriteria singleton] savePlace:[GooglePlaceDetail placeDetailFromData:responseData]];
            self.placesTableData = [SelectionCriteria singleton].placesArray;
            [self.placesTableView reloadData];
//            [self.placesTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            self.whereToTextField.text = [SelectionCriteria singleton].whereToFirst;
            self.whereToSecondLevel.text = [SelectionCriteria singleton].whereToSecond;
            if (self.redrawMapOnSelection) {
                [self redrawMapViewAnimated:YES radius:[SelectionCriteria singleton].googlePlaceDetail.zoomRadius];
            }
            break;
        }
            
        default:
            break;
    }
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
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"PowerebByGoogleCell" owner:self options:nil];
        UITableViewCell *poweredByGoogleCell = views.firstObject;
        return poweredByGoogleCell;
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
    if ([self.placesTableData[indexPath.row] isKindOfClass:[NSString class]]) {
        return;
    }
    
    PlaceAutoCompleteTableViewCell * cell = (PlaceAutoCompleteTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if ([self.placesTableData[indexPath.row] isKindOfClass:[GooglePlace class]]) {
        // TODO: I'm worried that we are setting the "where to" value here but that the
        // Google place detail values aren't set until the "loadPlaceDetails" returns.
        // The user could potentially click "Find Hotels" before the Google place details
        // are returned. So we could have two potential problems from this. First, the call
        // to LoadEanData.loadHotelsWithLatitude:longitude: could return data for the wrong
        // place. And second, we could have mismatched data in SelectionCriteria between
        // whereTo and googlePlaceDetail.
        [[LoadGooglePlacesData sharedInstance:self] loadPlaceDetails:cell.placeId];
        self.placesTableData = [SelectionCriteria singleton].placesArray;
        [self.placesTableView reloadData];
        [self.whereToTextField resignFirstResponder];
        [self animateTableViewCompression];
        self.useMapRadiusForSearch = NO;
    } else if ([self.placesTableData[indexPath.row] isKindOfClass:[WotaPlace class]]) {
        self.placesTableData = [SelectionCriteria singleton].placesArray;
        [self.placesTableView reloadData];
        [self.whereToTextField resignFirstResponder];
        [SelectionCriteria singleton].googlePlaceDetail = nil;
        [SelectionCriteria singleton].selectedPlace = self.placesTableData[indexPath.row];
        self.whereToTextField.text = [SelectionCriteria singleton].whereToFirst;
        self.whereToSecondLevel.text = [SelectionCriteria singleton].whereToSecond;
        [self animateTableViewCompression];
        if (self.redrawMapOnSelection) {
            [self redrawMapViewAnimated:YES radius:[SelectionCriteria singleton].selectedPlace.zoomRadius];
        }
        self.useMapRadiusForSearch = NO;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark Some animation methods

- (void)animateTableViewExpansion {
    __weak UIView *actv = self.placesTableView;
    [self.view bringSubviewToFront:actv];
    self.isPlacesTableViewExpanded = YES;
    [UIView animateWithDuration:self.animationDuraton animations:^{
        actv.frame = self.placesTableViewExpandedFrame;
    } completion:^(BOOL finished) {
    }];
}

- (void)animateTableViewCompression {
    __weak UIView *actv = self.placesTableView;
    self.isPlacesTableViewExpanded = NO;
    [UIView animateWithDuration:self.animationDuraton animations:^{
        actv.frame = self.placesTableViewZeroFrame;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark Various methods likely called by sublclasses

- (void)redrawMapViewAnimated:(BOOL)animated radius:(double)radius {
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.zoomLocation, 1.6*radius*METERS_PER_MILE, 1.6*radius*METERS_PER_MILE);
    [self.mkMapView setRegion:viewRegion animated:animated];
}

- (CLLocationCoordinate2D)zoomLocation {
    SelectionCriteria *sc = [SelectionCriteria singleton];
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = sc.latitude;
    zoomLocation.longitude= sc.longitude;
    return zoomLocation;
}

- (void)letsFindHotels:(HotelListingViewController *)hvc searchRadius:(double)searchRadius {
    SelectionCriteria *sc = [SelectionCriteria singleton];
    
    searchRadius = searchRadius * 0.6;
    searchRadius = fmax(searchRadius, 1);
    searchRadius = fmin(searchRadius, 50);
    int sri = ceil(searchRadius);
    
    [[LoadEanData sharedInstance:hvc] loadHotelsWithLatitude:sc.latitude
                                                   longitude:sc.longitude
                                                 arrivalDate:sc.arrivalDateEanString
                                                  returnDate:sc.returnDateEanString
                                                searchRadius:[NSNumber numberWithInt:sri]];
    
    if ([SelectionCriteria singleton].googlePlaceDetail) {
        [[SelectionCriteria singleton] savePlace:[SelectionCriteria singleton].googlePlaceDetail];
    }
    
    self.placesTableData = [SelectionCriteria singleton].placesArray;
    [self.placesTableView reloadData];
    
    if (hvc != self) {
        [self.navigationController pushViewController:hvc animated:YES];
    } else {
        AppDelegate *ad = [[UIApplication sharedApplication] delegate];
        [ad loadDaSpinner];
    }
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
    return self.mapRadiusInMeters / METERS_PER_MILE;
}

#pragma mark Getter

- (NSTimeInterval)animationDuraton {
    if (_animationDuraton == 0.0) {
        return 0.3;
    }
    
    return _animationDuraton;
}

#pragma mark Helpers

- (void)resetWhereToTfAppearance {
    self.whereToTextField.layer.cornerRadius = 6.0f;
    self.whereToTextField.layer.borderColor = UIColorFromRGB(0xbbbbbb).CGColor;
    self.whereToTextField.layer.borderWidth = 0.7f;
}

@end
