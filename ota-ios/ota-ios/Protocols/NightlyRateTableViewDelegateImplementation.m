//
//  NightlyRateTableViewDelegateImplementation.m
//  ota-ios
//
//  Created by WAYNE SMALL on 5/5/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "NightlyRateTableViewDelegateImplementation.h"
#import "NightRateTableCellView.h"
#import "EanNightlyRate.h"
#import "AppEnvironment.h"

@implementation NightlyRateTableViewDelegateImplementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NightReuser";
    NightRateTableCellView *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (nil == cell) {
        [tableView registerNib:[UINib nibWithNibName:@"NightRateTableCellView" bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    
    EanNightlyRate *nr = [_tableData objectAtIndex:indexPath.row];
    
    cell.rateOutlet.text = [nr.baseRate stringValue];
    cell.dateOutlet.text = [kShortDateFormatter() stringFromDate:nr.daDate];
    
    return  cell;
}

- (NSNumber *)nightsTotal {
    NSNumber *nt = 0;
    for (EanNightlyRate *nr in _tableData) {
        nt = [NSNumber numberWithDouble:[nt doubleValue] + [nr.baseRate doubleValue]];
    }
    return nt;
}

@end
