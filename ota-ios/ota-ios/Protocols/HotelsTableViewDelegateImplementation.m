//
//  HotelsTableViewDelegateImplementation.m
//  ota-ios
//
//  Created by WAYNE SMALL on 6/22/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "HotelsTableViewDelegateImplementation.h"
#import "HLTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "EanHotelListHotelSummary.h"
#import "AppEnvironment.h"
#import "HotelInfoViewController.h"
#import "LoadEanData.h"
#import "AppDelegate.h"

NSString * const kNotificationHotelDataChanged = @"kNotificationHotelDataChanged";

@interface HotelsTableViewDelegateImplementation () {
    BOOL inFilterMode;
}

@property (nonatomic, strong) NSMutableArray *filterableData;

@end

@implementation HotelsTableViewDelegateImplementation

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return inFilterMode ? self.filterableData.count : self.hotelData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"CellIdentifier";
    EanHotelListHotelSummary *hotel = inFilterMode ? _filterableData[indexPath.row] : _hotelData[indexPath.row];
    HLTableViewCell *cell = [[HLTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier hotelRating:hotel.hotelRating];
    
    NSString *imageUrlString = [@"http://images.travelnow.com" stringByAppendingString:hotel.thumbNailUrlEnhanced];
    [cell.thumbImageView setImageWithURL:[NSURL URLWithString:imageUrlString] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        // TODO: placeholder image
        // TODO: if nothing comes back, replace hotel.thumbNailUrlEnhanced with hotel.thumbNailUrl and try again
        ;
    }];
    
    cell.hotelNameLabel.text = hotel.hotelNameFormatted;
    NSNumberFormatter *pf = kPriceRoundOffFormatter(hotel.rateCurrencyCode);
    cell.roomRateLabel.text = [pf stringFromNumber:hotel.lowRate];//[NSNumber numberWithLong:3339993339]
    cell.cityLabel.text = hotel.city;
    
    return cell;
}

#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 96.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EanHotelListHotelSummary *hotel = inFilterMode ? _filterableData[indexPath.row] : _hotelData[indexPath.row];
    HotelInfoViewController *hvc = [[HotelInfoViewController alloc] initWithHotel:hotel];
    [[LoadEanData sharedInstance:hvc] loadHotelDetailsWithId:[hotel.hotelId stringValue]];
    
    AppDelegate *ad = [[UIApplication sharedApplication] delegate];
    [((UINavigationController *) ad.window.rootViewController) pushViewController:hvc animated:YES];
    [tableView endEditing:YES];
}

#pragma mark UIScrollViewDelegate methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [scrollView endEditing:YES];
}

#pragma mark UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    inFilterMode = YES;
    textField.layer.cornerRadius = 6.0f;
    textField.layer.borderColor = kWotaColorOne().CGColor;
    textField.layer.borderWidth = 0.7f;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *searchText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (stringIsEmpty(searchText)) {
        self.filterableData = [NSMutableArray arrayWithArray:self.hotelData];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationHotelDataChanged object:self];
        return YES;
    }
    
    NSMutableArray *searchResults = [self.hotelData mutableCopy];
    
    // strip out all the leading and trailing spaces
    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // break up the search terms (separated by spaces)
    NSArray *searchItems = nil;
    if (strippedString.length > 0) {
        searchItems = [strippedString componentsSeparatedByString:@" "];
    }
    
    // build all the "AND" expressions for each value in the searchString
    //
    NSMutableArray *andMatchPredicates = [NSMutableArray array];
    
    for (NSString *searchString in searchItems) {
        // each searchString creates an OR predicate for: name, yearIntroduced, introPrice
        //
        // example if searchItems contains "iphone 599 2007":
        //      name CONTAINS[c] "iphone"
        //      name CONTAINS[c] "599", yearIntroduced ==[c] 599, introPrice ==[c] 599
        //      name CONTAINS[c] "2007", yearIntroduced ==[c] 2007, introPrice ==[c] 2007
        //
        NSMutableArray *searchItemsPredicate = [NSMutableArray array];
        
        // Below we use NSExpression represent expressions in our predicates.
        // NSPredicate is made up of smaller, atomic parts: two NSExpressions (a left-hand value and a right-hand value)
        
        // name field matching
        NSExpression *lhs = [NSExpression expressionForKeyPath:@"hotelNameFormatted"];
        NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
        NSPredicate *finalPredicate = [NSComparisonPredicate
                                       predicateWithLeftExpression:lhs
                                       rightExpression:rhs
                                       modifier:NSDirectPredicateModifier
                                       type:NSContainsPredicateOperatorType
                                       options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        // at this OR predicate to our master AND predicate
        NSCompoundPredicate *orMatchPredicates = [NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
        [andMatchPredicates addObject:orMatchPredicates];
    }
    
    // match up the fields of the Product object
    NSCompoundPredicate *finalCompoundPredicate =
    [NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
    searchResults = [[searchResults filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
    
    self.filterableData = searchResults;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationHotelDataChanged object:self];
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    textField.text = @"";
    self.filterableData = [NSMutableArray arrayWithArray:self.hotelData];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationHotelDataChanged object:self];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (stringIsEmpty(textField.text)) {
        self.filterableData = [NSMutableArray arrayWithArray:self.hotelData];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationHotelDataChanged object:self];
    
    textField.layer.cornerRadius = 6.0f;
    textField.layer.borderColor = UIColorFromRGB(0xdddddd).CGColor;
    textField.layer.borderWidth = 0.7f;
}

#pragma mark Getter

- (NSArray *)currentHotelData {
    return inFilterMode ? _filterableData : _hotelData;
}

#pragma mark Setters

- (void)setHotelData:(NSArray *)hotelData {
    inFilterMode = NO;
    _hotelData = hotelData;
    self.filterableData = [NSMutableArray arrayWithCapacity:_hotelData.count];
}

@end
