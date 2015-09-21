//
//  HotelsTableViewDelegateImplementation.m
//  ota-ios
//
//  Created by WAYNE SMALL on 6/22/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "HotelsTableViewDelegateImplementation.h"
#import "HLTableViewCell.h"
//#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+WebCache.h"
#import "EanHotelListHotelSummary.h"
#import "AppEnvironment.h"
#import "HotelInfoViewController.h"
#import "LoadEanData.h"
#import "AppDelegate.h"
#import "WotaTappableView.h"

typedef NS_ENUM(NSUInteger, SORT_TYPE) {
    SORT_FEATURED = 5101,
    SORT_PRICE_LOW_TO_HIGH = 5102,
    SORT_PRICE_HIGH_TO_LOW = 5103,
    SORT_STARS = 5104
};

NSString * const kNotificationHotelDataFiltered = @"kNotificationHotelDataFiltered";
NSString * const kNotificationHotelDataSorted = @"kNotificationHotelDataSorted";

@interface HotelsTableViewDelegateImplementation () {
    BOOL inHotelNameFilterMode;
    BOOL inPriceFilterMode;
    BOOL inStarFilterMode;
}

@property (nonatomic, strong) NSMutableArray *filterableData;
@property (nonatomic, strong) NSString *filterText;
@property (nonatomic) SORT_TYPE sortType;
@property (nonatomic, strong) NSComparator sortComparator;

@end

@implementation HotelsTableViewDelegateImplementation

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentHotelData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"CellIdentifier";
    EanHotelListHotelSummary *hotel = self.currentHotelData[indexPath.row];
    HLTableViewCell *cell = [[HLTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier hotelRating:hotel.hotelRating];
    
    NSString *imageUrlString = [@"http://images.travelnow.com" stringByAppendingString:hotel.thumbNailUrlEnhanced];
    [cell.thumbImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlString] placeholderImage:[[self class] phi] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        // TODO: if nothing comes back, replace hotel.thumbNailUrlEnhanced with hotel.thumbNailUrl and try again
        ;
    }];
    
    cell.hotelNameLabel.text = hotel.hotelNameFormatted;
    NSNumberFormatter *pf = kPriceRoundOffFormatter(hotel.rateCurrencyCode);
    cell.roomRateLabel.text = [pf stringFromNumber:hotel.lowRate];//[NSNumber numberWithLong:3339993339]
    cell.cityLabel.text = hotel.city;
    
    NSString *discount = hotel.roomRateDetails.rateInfo.chargeableRateInfo.discountPercentString;
    if (hotel.roomRateDetails.rateInfo.promo && !stringIsEmpty(discount)) {
        cell.promoLabel.hidden = NO;
        cell.promoLabel.text = [NSString stringWithFormat:@"\n-%@", discount];
    } else {
        cell.promoLabel.hidden = YES;
        cell.promoLabel.text = @"";
    }
    
    cell.starBoardContainer.image = [StarBoard starBoardImageForHotelListWithRating:hotel.hotelRating];

    return cell;
}

+ (UIImage *)phi {
    static UIImage *_p = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _p = [UIImage imageNamed:@"hotel_large"];
    });
    
    return _p;
}

#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 96.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EanHotelListHotelSummary *hotel = self.currentHotelData[indexPath.row];
    HotelInfoViewController *hvc = [[HotelInfoViewController alloc] initWithHotel:hotel];
    [[LoadEanData sharedInstance:hvc] loadHotelDetailsWithId:[hotel.hotelId stringValue]];
    
    AppDelegate *ad = [[UIApplication sharedApplication] delegate];
    UINavigationController *nc = (UINavigationController *) ad.window.rootViewController;
    [nc pushViewController:hvc animated:YES];
    [tableView endEditing:YES];
}

#pragma mark UIScrollViewDelegate methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [scrollView endEditing:YES];
}

#pragma mark UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    inHotelNameFilterMode = YES;
    textField.layer.cornerRadius = 6.0f;
    textField.layer.borderColor = kWotaColorOne().CGColor;
    textField.layer.borderWidth = 0.7f;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    _filterText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self letsFilter];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    textField.text = _filterText = @"";
    [self letsFilter];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    inHotelNameFilterMode = !stringIsEmpty(textField.text);
    [self letsFilter];
    textField.layer.cornerRadius = 6.0f;
    textField.layer.borderColor = UIColorFromRGB(0xdddddd).CGColor;
    textField.layer.borderWidth = 0.7f;
}

#pragma mark Public methods

- (void)priceSliderChanged:(RangeSlider *)rangeSlider {
    NSNumberFormatter *pf = kPriceRoundOffFormatter([[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode]);
    
    UILabel *w = (UILabel *) [rangeSlider.superview viewWithTag:12345];
    self.selectedBottomPrice = (1 - rangeSlider.lowerValue) * [self.bottomPrice doubleValue] + rangeSlider.lowerValue * [self.topPrice doubleValue];
    w.text = [pf stringFromNumber:[NSNumber numberWithDouble:self.selectedBottomPrice]];//[NSString stringWithFormat:@"%.0f", self.selectedBottomPrice];
    
    UILabel *u = (UILabel *) [rangeSlider.superview viewWithTag:98765];
    self.selectedTopPrice = (1 - rangeSlider.upperValue) * [self.bottomPrice doubleValue] + rangeSlider.upperValue * [self.topPrice doubleValue];
    u.text = [pf stringFromNumber:[NSNumber numberWithDouble:self.selectedTopPrice]];//[NSString stringWithFormat:@"%.0f", self.selectedTopPrice];
    
    UILabel *wes = (UILabel *) [rangeSlider.superview viewWithTag:434343];
    NSString *plural = self.hotelData.count > 1 ? @"s" : @"";
    wes.text = [NSString stringWithFormat:@"%d of %lu Hotel%@", [self numberOfFilteredHotels], (unsigned long)self.hotelData.count, plural];
    
    inPriceFilterMode = rangeSlider.lowerValue != 0.0 || rangeSlider.upperValue != 1.0;
}

- (void)starClicked:(UITapGestureRecognizer *)tgr {
    UIView *starsContainer = tgr.view.superview;
    
    if (tgr.view.tag == 4299) {
        ((UILabel *)tgr.view).textColor = kWotaColorOne();
        
        for (int j = 1; j <= 5; j++) {
            UIView *sc = [starsContainer viewWithTag:(4300 + j)];
            ((UIView *)sc.subviews.firstObject).tintColor = [UIColor grayColor];
        }
        
        self.selectStarRating = 0.0;
        inStarFilterMode = NO;
    } else {
        ((UILabel *)[starsContainer viewWithTag:4299]).textColor = [UIColor grayColor];
        
        int starNumber = (int)tgr.view.tag - 4300;
        for (int j = 1; j <= 5; j++) {
            UIView *sc = [starsContainer viewWithTag:(4300 + j)];
            ((UIView *)sc.subviews.firstObject).tintColor = j <= starNumber ? kWotaColorOne() : [UIColor grayColor];
            self.selectStarRating = j == starNumber ? (double)j : self.selectStarRating;
        }
        
        inStarFilterMode = YES;
    }
    
    UILabel *wes = (UILabel *) [starsContainer.superview viewWithTag:434343];
    NSString *plural = self.hotelData.count > 1 ? @"s" : @"";
    wes.text = [NSString stringWithFormat:@"%d of %lu Hotel%@", [self numberOfFilteredHotels], (unsigned long)self.hotelData.count, plural];
}

- (int)numberOfFilteredHotels {
    return (int)[self performFilter].count;
}

- (void)letsSortYo:(UITapGestureRecognizer *)tgr {
    int wayne = (int)tgr.view.tag;
    if (wayne == self.sortType) {
        return;
    }
    
    for (int j = 5101; j <= 5104; j++) {
        WotaTappableView *wtv = (WotaTappableView *)[tgr.view.superview viewWithTag:j];
        wtv.borderColor = j == wayne ? kWotaColorOne() : [UIColor clearColor];
    }
    
    self.sortType = wayne;
    _hotelData = [_hotelData sortedArrayUsingComparator:self.sortComparator];
    self.filterableData = [NSMutableArray arrayWithArray:[self.filterableData sortedArrayUsingComparator:self.sortComparator]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationHotelDataSorted object:self];
}

#pragma mark Getters

- (BOOL)inFilterMode {
    return inHotelNameFilterMode || inPriceFilterMode || inStarFilterMode;
}

- (NSArray *)currentHotelData {
    return self.inFilterMode ? _filterableData : _hotelData;
}

- (NSNumber *)bottomPrice {
    NSNumber *bp = [NSNumber numberWithDouble:1000.0];
    
    for (EanHotelListHotelSummary *hotel in self.hotelData) {
        double lr = [hotel.lowRate doubleValue];
        bp = lr < [bp doubleValue] ? [NSNumber numberWithDouble:lr] : bp;
    }
    
    return bp;
}

- (NSNumber *)topPrice {
    NSNumber *tp = [NSNumber numberWithDouble:0.0];
    
    for (EanHotelListHotelSummary *hotel in self.hotelData) {
        double lr = [hotel.lowRate doubleValue];
        tp = lr > [tp doubleValue] ? [NSNumber numberWithDouble:lr] : tp;
    }
    
    return tp;
}

- (NSComparator)sortComparator {
    if (!_sortComparator) {
        
        __weak typeof(self) wes = self;
        
        _sortComparator = ^(id obj1, id obj2) {
            EanHotelListHotelSummary *h1 = obj1;
            EanHotelListHotelSummary *h2 = obj2;
            
            switch (wes.sortType) {
                case SORT_FEATURED: {
                    if (h1.featuredOrder < h2.featuredOrder) {
                        return NSOrderedAscending;
                    } else if (h1.featuredOrder > h2.featuredOrder) {
                        return NSOrderedDescending;
                    }
                    break;
                }
                    
                case SORT_PRICE_LOW_TO_HIGH: {
                    if ([h1.lowRate doubleValue] < [h2.lowRate doubleValue]) {
                        return NSOrderedAscending;
                    } else if ([h1.lowRate doubleValue] > [h2.lowRate doubleValue]) {
                        return NSOrderedDescending;
                    }
                    break;
                }
                    
                case SORT_PRICE_HIGH_TO_LOW: {
                    if ([h1.lowRate doubleValue] > [h2.lowRate doubleValue]) {
                        return NSOrderedAscending;
                    } else if ([h1.lowRate doubleValue] < [h2.lowRate doubleValue]) {
                        return NSOrderedDescending;
                    }
                    break;
                }
                    
                case SORT_STARS: {
                    if ([h1.hotelRating doubleValue] > [h2.hotelRating doubleValue]) {
                        return NSOrderedAscending;
                    } else if ([h1.hotelRating doubleValue] < [h2.hotelRating doubleValue]) {
                        return NSOrderedDescending;
                    }
                    break;
                }
                    
                default:
                    break;
            }
            
            return NSOrderedSame;
        };
    }
    
    return _sortComparator;
}

#pragma mark Setter

- (void)setHotelData:(NSArray *)hotelData {
    inHotelNameFilterMode = inPriceFilterMode = inStarFilterMode = NO;
    _filterText = @"";
    _selectStarRating = 0.0;
    _sortType = SORT_FEATURED;
    _hotelData = hotelData;
    self.filterableData = [NSMutableArray arrayWithArray:_hotelData];
}

#pragma mark Da Filter

- (void)letsFilter {
    if (self.inFilterMode || self.inFilterModePriorToLoadingFilterView) {
        self.filterableData = [self performFilter];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationHotelDataFiltered object:self];
    }
}

- (NSMutableArray *)performFilter {
    NSMutableArray *searchResults = [self.hotelData mutableCopy];
    
    /*******
     * First filter hotel name
     ******/
    
    // strip out all the leading and trailing spaces
    NSString *strippedString = [_filterText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
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
    
    /*******
     * Now filter low rate
     ******/
    
    NSExpression *lhsLR = [NSExpression expressionForKeyPath:@"lowRate"];
    NSExpression *rhsGT = [NSExpression expressionForConstantValue:[NSNumber numberWithDouble:self.selectedBottomPrice]];
    NSExpression *rhsLT = [NSExpression expressionForConstantValue:[NSNumber numberWithDouble:self.selectedTopPrice]];
    
    NSPredicate *greaterThanPredicate = [NSComparisonPredicate
                                         predicateWithLeftExpression:lhsLR
                                         rightExpression:rhsGT
                                         modifier:NSDirectPredicateModifier
                                         type:NSGreaterThanOrEqualToPredicateOperatorType
                                         options:0];
    
    NSPredicate *lessThanPredicate = [NSComparisonPredicate
                                      predicateWithLeftExpression:lhsLR
                                      rightExpression:rhsLT
                                      modifier:NSDirectPredicateModifier
                                      type:NSLessThanOrEqualToPredicateOperatorType
                                      options:0];
    
    NSMutableArray *LRItemsPredicate = [NSMutableArray array];
    [LRItemsPredicate addObject:greaterThanPredicate];
    [LRItemsPredicate addObject:lessThanPredicate];
    
    NSCompoundPredicate *LRCompoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:LRItemsPredicate];
    searchResults = [[searchResults filteredArrayUsingPredicate:LRCompoundPredicate] mutableCopy];
    
    /*******
     * And finally filter star rating
     ******/
    
    NSExpression *lhsSR = [NSExpression expressionForKeyPath:@"hotelRating"];
    NSExpression *rhsSR = [NSExpression expressionForConstantValue:[NSNumber numberWithDouble:self.selectStarRating]];
    
    NSPredicate *greaterThanStarPredicate = [NSComparisonPredicate predicateWithLeftExpression:lhsSR rightExpression:rhsSR modifier:NSDirectPredicateModifier type:NSGreaterThanOrEqualToPredicateOperatorType options:0];
    
    return [[searchResults filteredArrayUsingPredicate:greaterThanStarPredicate] mutableCopy];
}

@end
