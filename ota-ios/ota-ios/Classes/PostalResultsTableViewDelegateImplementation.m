//
//  PostalResultsTableViewDelegateImplementation.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/13/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "PostalResultsTableViewDelegateImplementation.h"
#import "PostalResultsTableViewCell.h"
#import "PlaceAutoCompleteTableViewCell.h"
#import "LoadGooglePlacesData.h"


@implementation PostalResultsTableViewDelegateImplementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"placeAutoCompleteCell";
    PlaceAutoCompleteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"PlaceAutoCompleteTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    
    GooglePlace *place = [GooglePlace placeFromObject:[self.tableData objectAtIndex:indexPath.row]];
    cell.outletPlaceName.text = place.placeName;
    cell.placeId = place.placeId;
    
    return cell;
//    NSString *cellIdentifier = @"postalCellIdentifier";
//    PostalResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    if (nil == cell) {
//        [tableView registerNib:[UINib nibWithNibName:@"PostResultsTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
//        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    }
//    
//    GooglePlaceDetail *gpd = [self.tableData objectAtIndex:indexPath.row];
//    NSString *localityString = gpd.localityShortName ? [gpd.localityShortName stringByAppendingString:@", "] : @"";
//    NSString *stateStr = gpd.administrativeAreaLevel1ShortName ? [gpd.administrativeAreaLevel1ShortName stringByAppendingString:@", "] : @"";
//    NSString *cntryStr = gpd.countryShortName ? : @"";
//    NSString *addressString = [NSString stringWithFormat:@"%@%@%@", localityString, stateStr, cntryStr];
//    cell.cellAddrOutlet.text = addressString;
//    
//    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(didSelectRow:)]) {
        PlaceAutoCompleteTableViewCell * cell = (PlaceAutoCompleteTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [[LoadGooglePlacesData sharedInstance:self] loadPlaceDetails:cell.placeId];
        [self.delegate didSelectRow:[GooglePlace placeFromObject:[self.tableData objectAtIndex:indexPath.row]]];
    }
}

@end
