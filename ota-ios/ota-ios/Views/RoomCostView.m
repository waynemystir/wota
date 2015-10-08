//
//  RoomCostView.m
//  ota-ios
//
//  Created by WAYNE SMALL on 9/18/15.
//  Copyright © 2015 Irwin. All rights reserved.
//

#import "RoomCostView.h"
#import "WotaButton.h"
#import "NightlyRateTableViewDelegateImplementation.h"
#import "AppEnvironment.h"

@interface RoomCostView ()

@property (nonatomic, strong) EanAvailabilityHotelRoomResponse *room;
@property (nonatomic, strong) NightlyRateTableViewDelegateImplementation *nrtvd;
@property (weak, nonatomic) IBOutlet UIView *roomCostContainer;
@property (weak, nonatomic) IBOutlet UITableView *nightlyRatesTableView;
@property (weak, nonatomic) IBOutlet WotaButton *doneButton;
@property (weak, nonatomic) IBOutlet UIView *taxesFeesContainer;
@property (weak, nonatomic) IBOutlet UIView *totalContainer;
@property (weak, nonatomic) IBOutlet UILabel *taxFeeTotalAmtLabel;
@property (weak, nonatomic) IBOutlet UILabel *tripTotalAmtLabel;
@property (nonatomic, strong) UIView *overlayDisable;
@property (nonatomic) CGFloat xOffset;
@property (nonatomic) CGFloat yOffset;

@end

@implementation RoomCostView

- (id)initWithFrame:(CGRect)frame room:(EanAvailabilityHotelRoomResponse *)room {
    if (self= [super initWithFrame:frame]) {
        [[NSBundle mainBundle] loadNibNamed:@"RoomCostView" owner:self options:nil];
        [self addSubview:self.roomCostContainer];
        self.frame = frame;
        _room = room;
        [self setupTheView];
    }
    return self;
}

- (void)setupTheView {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 8.0f;
    
    [self.doneButton addTarget:self action:@selector(dropCostSummaryView) forControlEvents:UIControlEventTouchUpInside];
    
    self.nrtvd = [[NightlyRateTableViewDelegateImplementation alloc] init];
    self.nrtvd.room = _room;
    self.nrtvd.tableData = _room.rateInfo.chargeableRateInfo.nightlyRatesArray;
    UITableView *nrtv = self.nightlyRatesTableView;
    nrtv.dataSource = self.nrtvd;
    nrtv.delegate = self.nrtvd;
    nrtv.layer.borderColor = [UIColor blackColor].CGColor;
    nrtv.layer.borderWidth = 2;
    nrtv.layer.cornerRadius = 8.0f;
    [nrtv reloadData];
    
    CGFloat maxTvHeight = [_room.rateInfo.sumOfHotelFees doubleValue] == 0 ? 343.0f : 303.0f;
    
    CGFloat nrtvHeight = MIN(self.nightlyRatesTableView.contentSize.height, maxTvHeight);
    nrtv.frame = CGRectMake(nrtv.frame.origin.x, nrtv.frame.origin.y, nrtv.frame.size.width, nrtvHeight);
    
    NSNumberFormatter *tdf = kPriceTwoDigitFormatter(_room.rateInfo.chargeableRateInfo.currencyCode);
    
    CGFloat nextVertOrigin = 44.0f + nrtvHeight + 7.0f;
    CGRect tfcf = self.taxesFeesContainer.frame;
    
    if (_room.rateInfo.chargeableRateInfo.hotelOccupAndSalesTaxSum > 0) {
        UIView *host = [[UIView alloc] initWithFrame:CGRectMake(tfcf.origin.x, nextVertOrigin-7, tfcf.size.width, tfcf.size.height)];
        nextVertOrigin = host.frame.origin.y + host.frame.size.height + 1;
        host.backgroundColor = UIColorFromRGB(0xE7E7E7);
        [self addSubview:host];
        
        UILabel *hostAmtLbl = [[UILabel alloc] initWithFrame:CGRectMake(157, 8, 139, 20)];
        hostAmtLbl.textAlignment = NSTextAlignmentRight;
        hostAmtLbl.font = [UIFont systemFontOfSize:16.0f];
        hostAmtLbl.adjustsFontSizeToFitWidth = YES;
        hostAmtLbl.minimumScaleFactor = 0.6f;
        hostAmtLbl.text = [tdf stringFromNumber:@(_room.rateInfo.chargeableRateInfo.hotelOccupAndSalesTaxSum)];
        [host addSubview:hostAmtLbl];
        
        UILabel *hostLbl = [[UILabel alloc] initWithFrame:CGRectMake(11, 0, 144, 34)];
        hostLbl.textAlignment = NSTextAlignmentLeft;
        hostLbl.font = [UIFont systemFontOfSize:14.0f];
        hostLbl.text = @"Hotel Occupancy and Sales Tax";
        hostLbl.numberOfLines = 2;
        [host addSubview:hostLbl];
    }
    
    self.taxesFeesContainer.frame = CGRectMake(tfcf.origin.x, nextVertOrigin, tfcf.size.width, tfcf.size.height);
    tfcf = self.taxesFeesContainer.frame;
    
    NSNumber *sc = _room.rateInfo.chargeableRateInfo.surchargeTotal;
    self.taxFeeTotalAmtLabel.text = [sc doubleValue] == 0 ? @"Included" : [tdf stringFromNumber:sc];
    
    if (0 != [_room.rateInfo.sumOfHotelFees doubleValue]) {
        UIView *ev = [[UIView alloc] initWithFrame:CGRectMake(tfcf.origin.x, tfcf.origin.y + tfcf.size.height+1, tfcf.size.width, 28.0f)];
        ev.backgroundColor = UIColorFromRGB(0xE7E7E7);
        
        UILabel *evla = [[UILabel alloc] initWithFrame:CGRectMake(132, 4, 164, 20)];
        evla.textAlignment = NSTextAlignmentRight;
        evla.font = [UIFont systemFontOfSize:16.0f];
        evla.adjustsFontSizeToFitWidth = YES;
        evla.minimumScaleFactor = 0.7f;
        evla.text = [tdf stringFromNumber:_room.rateInfo.chargeableRateInfo.total];
        [ev addSubview:evla];
        
        UILabel *evl = [[UILabel alloc] initWithFrame:CGRectMake(11, 4, 124, 20)];
        evl.textAlignment = NSTextAlignmentLeft;
        evl.font = [UIFont systemFontOfSize:15.0f];
        NSString *ft = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
        evl.text = [NSString stringWithFormat:@"Due %@ Now", ft];
        [ev addSubview:evl];
        
        [self addSubview:ev];
        tfcf = ev.frame;
        
        UIView *sv = [[UIView alloc] initWithFrame:CGRectMake(tfcf.origin.x, tfcf.origin.y + tfcf.size.height, tfcf.size.width, 28.0f)];
        
        UILabel *svla = [[UILabel alloc] initWithFrame:CGRectMake(149, 4, 147, 20)];
        svla.textAlignment = NSTextAlignmentRight;
        svla.font = [UIFont systemFontOfSize:16.0f];
        svla.adjustsFontSizeToFitWidth = YES;
        svla.minimumScaleFactor = 0.65f;
        svla.text = [tdf stringFromNumber:_room.rateInfo.sumOfHotelFees];
        [sv addSubview:svla];
        
        UILabel *svl = [[UILabel alloc] initWithFrame:CGRectMake(11, 4, 137, 20)];
        svl.textAlignment = NSTextAlignmentLeft;
        svl.font = [UIFont systemFontOfSize:15.0f];
        svl.text = @"Fees Paid at Hotel";
        [sv addSubview:svl];
        
        [self addSubview:sv];
        tfcf = sv.frame;
    }
    
    CGRect tcf = self.totalContainer.frame;
    self.totalContainer.frame = CGRectMake(tcf.origin.x, tfcf.origin.y + tfcf.size.height, tcf.size.width, tcf.size.height);
    
    self.tripTotalAmtLabel.text = [tdf stringFromNumber:_room.rateInfo.totalPlusHotelFees];
}

- (void)loadCostSummaryView:(UIView *)superView xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset {
    CGFloat wx = ([[UIScreen mainScreen] bounds].size.width - self.frame.size.width)/2;
    CGFloat wy = [[UIScreen mainScreen] bounds].size.height;
    [self loadCostSummaryView:superView wx:wx wy:wy xOffset:xOffset yOffset:yOffset];
}

- (void)loadCostSummaryView:(UIView *)superView wx:(CGFloat)wx wy:(CGFloat)wy xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset {
    self.xOffset = xOffset;
    self.yOffset = yOffset;
    CGRect tcf = self.totalContainer.frame;
    self.frame = CGRectMake(wx, ((50 + wy - tcf.origin.y - tcf.size.height)/2), self.frame.size.width, tcf.origin.y + tcf.size.height);
    self.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(xOffset, yOffset), 0.001f, 0.001f);
    
    self.overlayDisable.alpha = 0.0f;
    [superView addSubview:self.overlayDisable];
    [superView bringSubviewToFront:self.overlayDisable];
    [superView addSubview:self];
    [superView bringSubviewToFront:self];
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.overlayDisable.alpha = 0.8f;
        weakSelf.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)dropCostSummaryView {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.overlayDisable.alpha = 0.0f;
        weakSelf.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(self.xOffset, self.yOffset), 0.001f, 0.001f);
    } completion:^(BOOL finished) {
        [weakSelf.overlayDisable removeFromSuperview];
        [weakSelf removeFromSuperview];
    }];
}

- (UIView *)overlayDisable {
    if (_overlayDisable) return _overlayDisable;
    
    _overlayDisable = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _overlayDisable.userInteractionEnabled = YES;
    _overlayDisable.alpha = 0.0f;
    _overlayDisable.backgroundColor = [UIColor blackColor];
    
    return _overlayDisable;
}

@end
