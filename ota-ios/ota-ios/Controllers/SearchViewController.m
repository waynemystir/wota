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

static int const kAutoCompleteMinimumNumberOfCharacters = 4;
double const DEFAULT_RADIUS = 5.0;

@interface SearchViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

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
    self.whereToTextField.text = @"";//[SelectionCriteria singleton].whereToFirst;
    self.whereToSecondLevel.text = @"";//[SelectionCriteria singleton].whereToSecond;
}

#pragma mark UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (!_isPlacesTableViewExpanded) {
        [self animateTableViewExpansion];
    }
    
    self.whereToTextField.text = @"";
    self.whereToSecondLevel.text = @"";
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

#pragma mark LoadDataProtocol methods

- (void)requestStarted:(NSURL *)url {
    NSLog(@"%@.%@ loading URL:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [url absoluteString]);
}

- (void)requestFinished:(NSData *)responseData dataType:(LOAD_DATA_TYPE)dataType {
    switch (dataType) {
        case LOAD_GOOGLE_AUTOCOMPLETE: {
            self.placesTableData = [GoogleParser parseAutoCompleteResponse:responseData];
            [self.placesTableView reloadData];
            break;
        }
            
        case LOAD_GOOGLE_PLACES: {
            [SelectionCriteria singleton].googlePlaceDetail = [GooglePlaceDetail placeDetailFromData:responseData];
//            [[SelectionCriteria singleton] savePlace:[GooglePlaceDetail placeDetailFromData:responseData]];
            self.placesTableData = [SelectionCriteria singleton].placesArray;
            [self.placesTableView reloadData];
            self.whereToTextField.text = [SelectionCriteria singleton].whereToFirst;
            self.whereToSecondLevel.text = [SelectionCriteria singleton].whereToSecond;
            [self redrawMapViewAnimated:YES radius:DEFAULT_RADIUS];
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
    } else if ([self.placesTableData[indexPath.row] isKindOfClass:[WotaPlace class]]) {
        self.placesTableData = [SelectionCriteria singleton].placesArray;
        [self.placesTableView reloadData];
        [self.whereToTextField resignFirstResponder];
        [SelectionCriteria singleton].googlePlaceDetail = nil;
        [SelectionCriteria singleton].selectedPlace = self.placesTableData[indexPath.row];
        self.whereToTextField.text = [SelectionCriteria singleton].whereToFirst;
        self.whereToSecondLevel.text = [SelectionCriteria singleton].whereToSecond;
        [self animateTableViewCompression];
        [self redrawMapViewAnimated:YES radius:DEFAULT_RADIUS];
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
    [UIView animateWithDuration:0.3 animations:^{
        actv.frame = self.placesTableViewExpandedFrame;
    } completion:^(BOOL finished) {
    }];
}

- (void)animateTableViewCompression {
    __weak UIView *actv = self.placesTableView;
    self.isPlacesTableViewExpanded = NO;
    [UIView animateWithDuration:0.3 animations:^{
        actv.frame = self.placesTableViewZeroFrame;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark Methods to override

- (void)redrawMapViewAnimated:(BOOL)animated radius:(double)radius {
    [self doesNotRecognizeSelector:_cmd];
}

@end
