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
    NSNumberFormatter *tdf = kPriceTwoDigitFormatter(self.room.rateInfo.chargeableRateInfo.currencyCode);
    
    cell.rateOutlet.text = [tdf stringFromNumber:nr.rate];
    cell.dateOutlet.text = [kShortDateFormatter() stringFromDate:nr.daDate];
    
    return  cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 17.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 27.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *hv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 246, 27)];
    
    UILabel *numberNights = [[UILabel alloc] initWithFrame:CGRectMake(8, 4, 82, 19)];
    numberNights.textAlignment = NSTextAlignmentLeft;
    NSUInteger c = [self.tableData count];
    numberNights.text = [NSString stringWithFormat:@"%lu Night%@", (unsigned long) c, c > 1 ? @"s" : @""];
    [hv addSubview:numberNights];
    
    NSNumberFormatter *tdf = kPriceTwoDigitFormatter(self.room.rateInfo.chargeableRateInfo.currencyCode);
    
    UILabel *nightsTotal = [[UILabel alloc] initWithFrame:CGRectMake(90, 4, 149, 19)];
    nightsTotal.textAlignment = NSTextAlignmentRight;
    nightsTotal.text = [tdf stringFromNumber:self.room.rateInfo.chargeableRateInfo.nightlyRateTotal];
    [hv addSubview:nightsTotal];
    return hv;
}

@end
