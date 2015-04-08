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

@property (weak, nonatomic) IBOutlet UITableView *roomsTableViewOutlet;
@property (nonatomic, strong) EanHotelRoomAvailabilityResponse *eanHrar;
@property (nonatomic, strong) NSArray *tableData;

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
}

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
    
    EanAvailabilityHotelRoomResponse *room = [EanAvailabilityHotelRoomResponse roomFromDict:[self.tableData objectAtIndex:indexPath.row]];
    
    cell.roomTypeDescriptionOutlet.text = room.roomTypeDescription;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SelectionCriteria *sc = [SelectionCriteria singleton];
    EanAvailabilityHotelRoomResponse *room = [EanAvailabilityHotelRoomResponse roomFromDict:[self.tableData objectAtIndex:indexPath.row]];
    
    BookViewController *bvc = [BookViewController new];
    
    [[LoadEanData sharedInstance:bvc] bookHotelRoomWithHotelId:self.eanHrar.hotelId arrivalDate:sc.arrivalDateEanString departureDate:sc.returnDateEanString supplierType:room.supplierType rateKey:self.eanHrar.rateKey roomTypeCode:room.roomTypeCode rateCode:room.rateCode chargeableRate:room.chargeableRate numberOfAdults:sc.numberOfAdults childTravelers:[ChildTraveler childTravelers] room1FirstName:@"test" room1LastName:@"testers" room1BedTypeId:@"23" room1SmokingPreference:@"NS" affiliateConfirmationId:[NSUUID UUID] email:@"test@yourSite.com" firstName:@"tester" lastName:@"testing" homePhone:@"1234567890" creditCardType:@"CA" creditCardNumber:@"5401999999999999" creditCardIdentifier:@"123" creditCardExpirationMonth:@"11" creditCardExpirationYear:@"2016" address1:@"travelnow" city:@"Bellevue" stateProvinceCode:@"WA" countryCode:@"US" postalCode:@"98004"];
    
    [self.navigationController pushViewController:bvc animated:YES];
}

@end
