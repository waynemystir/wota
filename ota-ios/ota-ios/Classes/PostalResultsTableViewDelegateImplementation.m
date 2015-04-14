//
//  PostalResultsTableViewDelegateImplementation.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/13/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "PostalResultsTableViewDelegateImplementation.h"
#import "PostalResultsTableViewCell.h"

@implementation PostalResultsTableViewDelegateImplementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"postalCellIdentifier";
    PostalResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell) {
        [tableView registerNib:[UINib nibWithNibName:@"PostResultsTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    GooglePlaceDetail *gpd = [self.tableData objectAtIndex:indexPath.row];
    NSString *localityString = gpd.localityShortName ? [gpd.localityShortName stringByAppendingString:@", "] : @"";
    NSString *stateStr = gpd.administrativeAreaLevel1ShortName ? [gpd.administrativeAreaLevel1ShortName stringByAppendingString:@", "] : @"";
    NSString *cntryStr = gpd.countryShortName ? : @"";
    NSString *addressString = [NSString stringWithFormat:@"%@%@%@", localityString, stateStr, cntryStr];
    cell.cellAddrOutlet.text = addressString;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(didSelectRow:)]) {
        [self.delegate didSelectRow:[self.tableData objectAtIndex:indexPath.row]];
    }
}

@end
