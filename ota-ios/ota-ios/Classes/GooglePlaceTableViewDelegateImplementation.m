//
//  GooglePlaceTableViewDelegateImplementation.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/13/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "GooglePlaceTableViewDelegateImplementation.h"
#import "PlaceAutoCompleteTableViewCell.h"


@implementation GooglePlaceTableViewDelegateImplementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.tableData[indexPath.row] isKindOfClass:[NSString class]]) {
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
    
    GooglePlace *place = [self.tableData objectAtIndex:indexPath.row];
    cell.outletPlaceName.text = place.placeName;
    cell.placeId = place.placeId;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.tableData[indexPath.row] isKindOfClass:[NSString class]]) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(didSelectRow:)]) {
        [self.delegate didSelectRow:[self.tableData objectAtIndex:indexPath.row]];
    }
}

@end
