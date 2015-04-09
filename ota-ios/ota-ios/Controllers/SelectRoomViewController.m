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

@interface SelectRoomViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewOutlet;
@property (weak, nonatomic) IBOutlet UITableView *roomsTableViewOutlet;
@property (weak, nonatomic) IBOutlet UIView *inputBookOutlet;
@property (weak, nonatomic) IBOutlet UIButton *bookButtonOutlet;


@property (nonatomic, strong) EanHotelRoomAvailabilityResponse *eanHrar;
@property (nonatomic, strong) EanAvailabilityHotelRoomResponse *selectedRoom;
@property (nonatomic, strong) NSArray *tableData;
@property (nonatomic, strong) NSIndexPath *expandedIndexPath;

- (IBAction)justPushIt:(id)sender;

@end

@implementation SelectRoomViewController

- (id)init {
    self = [super initWithNibName:@"SelectRoomView" bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.roomsTableViewOutlet.dataSource = self;
    self.roomsTableViewOutlet.delegate = self;
    
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
    
    // If the index path of the currently expanded cell is the same as the index that
    // has just been tapped, then set the expanded index to nil so that there aren't any
    // expanded cells, otherwise, set the expanded index to the index that has just
    // been selected.
    //
    // Curtesy of 0x7fffffff from http://stackoverflow.com/questions/4635338/uitableviewcell-expand-on-click
    
    if ([indexPath compare:self.expandedIndexPath] == NSOrderedSame) {
        self.expandedIndexPath = nil;
        [self compressFromDetailViews];
    } else {
        self.expandedIndexPath = indexPath;
        [self expandToDetailViews];
    }
    
    [tableView beginUpdates]; // tell the table you're about to start making changes
    [tableView endUpdates]; // tell the table you're done making your changes
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // If the expandedIndexPath is not nil and equals this indexPath, then return
    // the height of the tableView
    //
    // Curtesy of 0x7fffffff from http://stackoverflow.com/questions/4635338/uitableviewcell-expand-on-click
    if ([indexPath compare:self.expandedIndexPath] == NSOrderedSame) {
        return tableView.frame.size.height;
    }
    
    // Otherwise return zero if there is a selected row or the normal height if
    // there is no selected row
    if (nil != self.expandedIndexPath) {
        return 0.0f;
    } else {
        return 44.0f;
    }
}

#pragma mark Various methods

- (void)expandToDetailViews {
    self.scrollViewOutlet.contentSize = CGSizeMake(320.0f, 800.0f);
    
    __weak UIView *rtv = self.roomsTableViewOutlet;
    __weak UIView *ibo = self.inputBookOutlet;
    ibo.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        rtv.frame = CGRectMake(10, 43, 300, 200);
        ibo.transform = [self shownGuestInputTransform];
    } completion:^(BOOL finished) {
        ibo.hidden = NO;
    }];
}

- (void)compressFromDetailViews {
    self.scrollViewOutlet.contentSize = CGSizeMake(320.0f, 508.0f);
    
    __weak UIView *rtv = self.roomsTableViewOutlet;
    __weak UIView *ibo = self.inputBookOutlet;
    [UIView animateWithDuration:0.3 animations:^{
        rtv.frame = CGRectMake(10, 43, 300, 300);
        ibo.transform = [self hiddenGuestInputTransform];
    } completion:^(BOOL finished) {
        ibo.hidden = YES;
    }];
}

- (CGAffineTransform)hiddenGuestInputTransform {
//    CGFloat hiddenX = self.inputBookOutlet.center.x;
//    CGFloat hiddenY = self.inputBookOutlet.center.y + 200.0f;
    CGAffineTransform hiddenTransform = CGAffineTransformMakeTranslation(0.0f, 200.0f);
    return CGAffineTransformScale(hiddenTransform, 0.01f, 0.01f);
}

- (CGAffineTransform)shownGuestInputTransform {
    CGAffineTransform shownTransform = CGAffineTransformMakeTranslation(0.0f, 0.0f);
    return CGAffineTransformScale(shownTransform, 1.0f, 1.0f);
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
