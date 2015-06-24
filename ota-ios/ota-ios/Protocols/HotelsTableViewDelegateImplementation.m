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

@implementation HotelsTableViewDelegateImplementation

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.hotelData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"CellIdentifier";
    EanHotelListHotelSummary *hotel = [_hotelData objectAtIndex:indexPath.row];
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
    EanHotelListHotelSummary *hotel = [self.hotelData objectAtIndex:indexPath.row];
    HotelInfoViewController *hvc = [[HotelInfoViewController alloc] initWithHotel:hotel];
    [[LoadEanData sharedInstance:hvc] loadHotelDetailsWithId:[hotel.hotelId stringValue]];
    
    AppDelegate *ad = [[UIApplication sharedApplication] delegate];
    [((UINavigationController *) ad.window.rootViewController) pushViewController:hvc animated:YES];
}

@end
