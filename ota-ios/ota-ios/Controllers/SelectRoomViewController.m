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
#import "GuestInfo.h"

NSTimeInterval const kAnimationDuration = 0.6;
NSUInteger const kGuestDetailsViewTag = 51;

@interface SelectRoomViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *roomsTableViewOutlet;
@property (weak, nonatomic) IBOutlet UIView *inputBookOutlet;
@property (weak, nonatomic) IBOutlet UIButton *bookButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *guestButtonOutlet;
@property (weak, nonatomic) IBOutlet UITextField *firstNameOutlet;
@property (weak, nonatomic) IBOutlet UITextField *lastNameOutlet;
@property (weak, nonatomic) IBOutlet UITextField *emailOutlet;
@property (weak, nonatomic) IBOutlet UITextField *phoneOutlet;

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
    
    if ([indexPath compare:self.expandedIndexPath] == NSOrderedSame) {
        self.expandedIndexPath = nil;
    } else {
        self.expandedIndexPath = indexPath;
        [self expandToDetailViews];
    }
}

#pragma mark Various methods

- (void)expandToDetailViews {
    __block UIView *tvp = [self getTableViewPopOut];
    __weak UIView *rtv = self.roomsTableViewOutlet;
    __weak UIView *ibo = self.inputBookOutlet;
    
    tvp.frame = self.rectOfCellInSuperview;
    tvp.hidden = NO;
    ibo.hidden = NO;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        tvp.frame = CGRectMake(10, 65, 300, 200);
        rtv.transform = CGAffineTransformMakeScale(0.1, 0.1);
        ibo.transform = [self shownGuestInputTransform];
    }];
}

- (void)compressFromDetailViews:(id)sender {
    __weak UIView *tvp = self.doneButton.superview;
    __weak UIView *rtv = self.roomsTableViewOutlet;
    __weak UIView *ibo = self.inputBookOutlet;
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
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

- (IBAction)justPushIt:(id)sender {
    if (sender == self.bookButtonOutlet) {
        [self bookIt];
    } else if (sender == self.guestButtonOutlet) {
        [self loadGuestDetailsView];
    }
}

- (void)bookIt {
    if (nil == self.expandedIndexPath) {
        return;
    }
    
    self.selectedRoom = [EanAvailabilityHotelRoomResponse roomFromDict:[self.tableData objectAtIndex:self.expandedIndexPath.row]];
    SelectionCriteria *sc = [SelectionCriteria singleton];
    GuestInfo *gi = [GuestInfo singleton];
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
                                                room1FirstName:gi.firstName
                                                 room1LastName:gi.lastName
                                                room1BedTypeId:@"23"
                                        room1SmokingPreference:@"NS"
                                       affiliateConfirmationId:[NSUUID UUID]
                                                         email:gi.email
                                                     firstName:gi.firstName
                                                      lastName:gi.lastName
                                                     homePhone:gi.phoneNumber
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

- (void)loadGuestDetailsView {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"GuestDetailsView" owner:self options:nil];
    if (nil == views || [views count] != 1) {
        return;
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dropGuestDetailsView:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dropGuestDetailsView:)];
    
    UIView *guestDetailsView = views[0];
    guestDetailsView.tag = kGuestDetailsViewTag;
    guestDetailsView.frame = CGRectMake(10, 64, 300, 300);
    
    CGPoint gboCenter = [self.view convertPoint:self.guestButtonOutlet.center fromView:self.inputBookOutlet];
    CGFloat fromX = gboCenter.x - guestDetailsView.center.x;
    CGFloat fromY = gboCenter.y - guestDetailsView.center.y;
    CGAffineTransform fromTransform = CGAffineTransformMakeTranslation(fromX, fromY);
    guestDetailsView.transform = CGAffineTransformScale(fromTransform, 0.01f, 0.01f);
    
    [self.view addSubview:guestDetailsView];
    [self.firstNameOutlet becomeFirstResponder];
    self.firstNameOutlet.text = [GuestInfo singleton].firstName;
    self.lastNameOutlet.text = [GuestInfo singleton].lastName;
    self.emailOutlet.text = [GuestInfo singleton].email;
    self.phoneOutlet.text = [GuestInfo singleton].phoneNumber;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        guestDetailsView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)dropGuestDetailsView:(id)sender {
    if (sender == self.navigationItem.rightBarButtonItem) {
        GuestInfo *gi = [GuestInfo singleton];
        gi.firstName = self.firstNameOutlet.text;
        gi.lastName = self.lastNameOutlet.text;
        gi.email = self.emailOutlet.text;
        gi.phoneNumber = self.phoneOutlet.text;
    }
    
    __weak UIView *guestView = [self.view viewWithTag:kGuestDetailsViewTag];
    
    CGPoint gboCenter = [self.view convertPoint:self.guestButtonOutlet.center fromView:self.inputBookOutlet];
    CGFloat toX = gboCenter.x - guestView.center.x;
    CGFloat toY = gboCenter.y - guestView.center.y;
    __block CGAffineTransform toTransform = CGAffineTransformMakeTranslation(toX, toY);
    
    [self.firstNameOutlet resignFirstResponder];
    self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
    self.navigationItem.rightBarButtonItem = nil;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        guestView.transform = CGAffineTransformScale(toTransform, 0.01f, 0.01f);
    } completion:^(BOOL finished) {
        [guestView removeFromSuperview];;
    }];
}

- (void)loadPaymentDetailsView {
    
}

@end
