//
//  SelectRoomViewController.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/28/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "SelectRoomViewController.h"
#import "EanHotelRoomAvailabilityResponse.h"
#import "EanAvailabilityHotelRoomResponse.h"
#import "AvailableRoomTableViewCell.h"
#import "LoadEanData.h"
#import "SelectionCriteria.h"
#import "ChildTraveler.h"
#import "BookViewController.h"

NSTimeInterval const kAnimationDuration = 2.6;

@interface SelectRoomViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *roomsTableViewOutlet;
@property (weak, nonatomic) IBOutlet UIView *inputBookOutlet;
@property (weak, nonatomic) IBOutlet UIButton *bookButtonOutlet;

@property (nonatomic, strong) EanHotelRoomAvailabilityResponse *eanHrar;
@property (nonatomic, strong) EanAvailabilityHotelRoomResponse *selectedRoom;
@property (nonatomic, strong) NSArray *tableData;
@property (nonatomic, strong) NSIndexPath *expandedIndexPath;
@property (nonatomic) CGRect rectOfCellInSuperview;
@property (nonatomic, strong) UIButton *doneButton;

- (IBAction)justPushIt:(id)sender;

@end

@implementation SelectRoomViewController

- (id)init {
    self = [super initWithNibName:@"SelectRoomView" bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //**********************************************************************
    // This is needed so that this view controller (or it's nav controller?)
    // doesn't make room at the top of the table view's scroll view (I guess
    // to account for the nav bar).
    //***********************************************************************
    self.automaticallyAdjustsScrollViewInsets = YES;
    //***********************************************************************
    
    self.roomsTableViewOutlet.dataSource = self;
    self.roomsTableViewOutlet.delegate = self;
    self.roomsTableViewOutlet.layer.borderWidth = 2.0;
    self.roomsTableViewOutlet.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.inputBookOutlet.hidden = YES;
//    self.inputBookOutlet.frame = CGRectMake(10.0f, 412.0f, 300.0f, 0.0f);
    self.inputBookOutlet.transform = [self hiddenGuestInputTransform];
}

#pragma mark LoadDataProtocol methods

- (void)requestFinished:(NSData *)responseData {
    self.eanHrar = [EanHotelRoomAvailabilityResponse roomsAvailableResponseFromData:responseData];
    self.tableData = self.eanHrar.hotelRoomArray;
    [self.roomsTableViewOutlet reloadData];
}

#pragma mark Table View Data Source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"AvailableRoomCellIdentifier";
    AvailableRoomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (nil == cell) {
        [tableView registerNib:[UINib nibWithNibName:@"AvailableRoomTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    // Set these so that the cell expansion and compression work well
    // Curtesy of http://stackoverflow.com/questions/10220565/expanding-uitableviewcell
    cell.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    cell.clipsToBounds = YES;
    
    EanAvailabilityHotelRoomResponse *room = [EanAvailabilityHotelRoomResponse roomFromDict:[self.tableData objectAtIndex:indexPath.row]];
    
    cell.roomTypeDescriptionOutlet.text = room.roomTypeDescription;
    
    return cell;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //    [self bookIt];
    
    CGRect rectOfCellInTableView = [tableView rectForRowAtIndexPath:indexPath];
    self.rectOfCellInSuperview = [tableView convertRect:rectOfCellInTableView toView:[tableView superview]];
    
    // If the index path of the currently expanded cell is the same as the index that
    // has just been tapped, then set the expanded index to nil so that there aren't any
    // expanded cells, otherwise, set the expanded index to the index that has just
    // been selected.
    //
    // Curtesy of 0x7fffffff from http://stackoverflow.com/questions/4635338/uitableviewcell-expand-on-click
//    [tableView beginUpdates];
    if ([indexPath compare:self.expandedIndexPath] == NSOrderedSame) {
        self.expandedIndexPath = nil;
    } else {
        self.expandedIndexPath = indexPath;
        [self expandToDetailViews];
    }
//    [tableView endUpdates];
}

#pragma mark Various methods

- (void)expandToDetailViews {
    __block UIView *tvp = [self getTableViewPopOut];
    __weak UIView *rtv = self.roomsTableViewOutlet;
    __weak UIView *ibo = self.inputBookOutlet;
    
//    CGFloat rcX = self.rectOfCellInSuperview.origin.x + self.rectOfCellInSuperview.size.width / 2;
//    CGFloat ncX = rcX - tvp.center.x;
//    CGFloat rcY = self.rectOfCellInSuperview.origin.y + self.rectOfCellInSuperview.size.height / 2;
//    CGFloat ncY = rcY - tvp.center.y;
//    float rcW = (float) self.rectOfCellInSuperview.size.width / tvp.frame.size.width;
//    float rcH = (float) self.rectOfCellInSuperview.size.height / tvp.frame.size.height;
//    
//    CGAffineTransform startingPopoutTransform = CGAffineTransformMakeTranslation(ncX, ncY);
//    startingPopoutTransform = CGAffineTransformScale(startingPopoutTransform, rcW, rcH);
//    tvp.transform = startingPopoutTransform;
    
//    __block CGAffineTransform toTransform = CGAffineTransformMakeTranslation(0.0f, 0.0f);
//    toTransform = CGAffineTransformScale(toTransform, 1.0f, 1.0f);
    
    tvp.frame = self.rectOfCellInSuperview;
    tvp.hidden = NO;
    ibo.hidden = NO;
    [UIView animateWithDuration:kAnimationDuration animations:^{
//        tvp.transform = toTransform;
        tvp.frame = CGRectMake(10, 65, 300, 200);
        rtv.transform = CGAffineTransformMakeScale(0.1, 0.1);
        ibo.transform = [self shownGuestInputTransform];
    } completion:^(BOOL finished) {
        ibo.hidden = NO;
    }];
}

- (void)compressFromDetailViews:(id)sender {
    __weak UIView *tvp = self.doneButton.superview;
    __weak UIView *rtv = self.roomsTableViewOutlet;
    __weak UIView *ibo = self.inputBookOutlet;
    
//    CGFloat rcX = self.rectOfCellInSuperview.origin.x + self.rectOfCellInSuperview.size.width / 2;
//    CGFloat ncX = rcX - tvp.center.x;
//    CGFloat rcY = self.rectOfCellInSuperview.origin.y + self.rectOfCellInSuperview.size.height / 2;
//    CGFloat ncY = rcY - tvp.center.y;
//    float rcW = (float) self.rectOfCellInSuperview.size.width / tvp.frame.size.width;
//    float rcH = (float) self.rectOfCellInSuperview.size.height / tvp.frame.size.height;
//    
//    __block CGAffineTransform finishingPopoutTransform = CGAffineTransformMakeTranslation(ncX, ncY);
//    finishingPopoutTransform = CGAffineTransformScale(finishingPopoutTransform, rcW, rcH);
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
//        tvp.transform = finishingPopoutTransform;
        tvp.frame = self.rectOfCellInSuperview;
        rtv.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        ibo.transform = [self hiddenGuestInputTransform];
    } completion:^(BOOL finished) {
        tvp.hidden = YES;
        ibo.hidden = YES;
    }];
}

- (UIView *)getTableViewPopOut {
    UIView *tableViewPopout = [[UIView alloc] initWithFrame:self.rectOfCellInSuperview];
    tableViewPopout.backgroundColor = [UIColor redColor];
    tableViewPopout.hidden = YES;
    tableViewPopout.clipsToBounds = YES;
    [self.view addSubview:tableViewPopout];
    
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"AvailableRoomTableViewCell" owner:self options:nil];
    if (nil != views && [views count] == 1 && [views[0] isKindOfClass:[AvailableRoomTableViewCell class]]) {
        UIView *cv = ((AvailableRoomTableViewCell *) views[0]).contentView;
        UILabel *rtdLabel = (UILabel *)[cv viewWithTag:11];
        
        EanAvailabilityHotelRoomResponse *room = [EanAvailabilityHotelRoomResponse roomFromDict:[self.tableData objectAtIndex:self.expandedIndexPath.row]];
        
        rtdLabel.text = room.roomTypeDescription;
        [tableViewPopout addSubview:cv];
    }
    
    self.doneButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 50)];
    [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.doneButton.backgroundColor = [UIColor whiteColor];
    [self.doneButton addTarget:self action:@selector(compressFromDetailViews:) forControlEvents:UIControlEventTouchUpInside];
    [tableViewPopout addSubview:self.doneButton];
    return tableViewPopout;
}

- (CGAffineTransform)hiddenGuestInputTransform {
    CGAffineTransform hiddenTransform = CGAffineTransformMakeTranslation(0.0f, 200.0f);
    return CGAffineTransformScale(hiddenTransform, 0.01f, 0.01f);
}

- (CGAffineTransform)shownGuestInputTransform {
    CGAffineTransform shownTransform = CGAffineTransformMakeTranslation(0.0f, 0.0f);
    return CGAffineTransformScale(shownTransform, 1.0f, 1.0f);
}

- (UIView *)roomView {
    UIView *rv;
    return rv;
}

- (void)bookIt {
    if (nil == self.expandedIndexPath) {
        return;
    }
    
    self.selectedRoom = [EanAvailabilityHotelRoomResponse roomFromDict:[self.tableData objectAtIndex:self.expandedIndexPath.row]];
    SelectionCriteria *sc = [SelectionCriteria singleton];
    BookViewController *bvc = [BookViewController new];
    
    [[LoadEanData sharedInstance:bvc] bookHotelRoomWithHotelId:self.eanHrar.hotelId
                                                   arrivalDate:sc.arrivalDateEanString
                                                 departureDate:sc.returnDateEanString
                                                  supplierType:self.selectedRoom.supplierType
                                                       rateKey:self.eanHrar.rateKey
                                                  roomTypeCode:self.selectedRoom.roomTypeCode
                                                      rateCode:self.selectedRoom.rateCode
                                                chargeableRate:self.selectedRoom.chargeableRate
                                                numberOfAdults:sc.numberOfAdults
                                                childTravelers:[ChildTraveler childTravelers]
                                                room1FirstName:@"test"
                                                 room1LastName:@"testers"
                                                room1BedTypeId:@"23"
                                        room1SmokingPreference:@"NS"
                                       affiliateConfirmationId:[NSUUID UUID]
                                                         email:@"test@yourSite.com"
                                                     firstName:@"tester"
                                                      lastName:@"testing"
                                                     homePhone:@"1234567890"
                                                creditCardType:@"CA"
                                              creditCardNumber:@"5401999999999999"
                                          creditCardIdentifier:@"123"
                                     creditCardExpirationMonth:@"11"
                                      creditCardExpirationYear:@"2016"
                                                      address1:@"travelnow"
                                                          city:@"Bellevue"
                                             stateProvinceCode:@"WA"
                                                   countryCode:@"US"
                                                    postalCode:@"98004"];
    
    [self.navigationController pushViewController:bvc animated:YES];
}

- (IBAction)justPushIt:(id)sender {
    if (sender == self.bookButtonOutlet) {
        [self bookIt];
    }
}

@end
