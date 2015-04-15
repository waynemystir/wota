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
#import "AppEnvironment.h"
#import "JNKeychain.h"
#import "GoogleParser.h"
#import "GooglePlaces.h"
#import "GooglePlaceDetail.h"
#import "GooglePlaceTableViewDelegateImplementation.h"
#import "LoadGooglePlacesData.h"
#import "EanPlace.h"

typedef NS_ENUM(NSUInteger, LOAD_DATA) {
    LOAD_ROOM = 0,
    LOAD_AUTOOMPLETE = 1,
    LOAD_PLACE = 2
};

NSTimeInterval const kAnimationDuration = 0.6;
NSUInteger const kGuestDetailsViewTag = 51;
NSUInteger const kPaymentDetailsViewTag = 52;
NSUInteger const kAvailRoomCellContViewTag = 19191;
NSString * const kNoLocationsFoundMessage = @"No locations found for this postal code. Please try again.";

@interface SelectRoomViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, SelectGooglePlaceDelegate>

@property (nonatomic) LOAD_DATA load_data_type;

@property (weak, nonatomic) IBOutlet UITableView *roomsTableViewOutlet;
@property (weak, nonatomic) IBOutlet UIView *inputBookOutlet;
@property (weak, nonatomic) IBOutlet UIButton *bookButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *guestButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *paymentButtonOutlet;

@property (weak, nonatomic) IBOutlet UITextField *firstNameOutlet;
@property (weak, nonatomic) IBOutlet UITextField *lastNameOutlet;
@property (weak, nonatomic) IBOutlet UITextField *emailOutlet;
@property (weak, nonatomic) IBOutlet UITextField *phoneOutlet;

@property (weak, nonatomic) IBOutlet UITextField *ccNumberOutlet;
@property (weak, nonatomic) IBOutlet UITextField *expirationOutlet;
@property (weak, nonatomic) IBOutlet UITextField *address1Outlet;
@property (nonatomic, strong) UIPickerView *expirationPicker;
@property (weak, nonatomic) IBOutlet UITextField *addressTextFieldOutlet;
@property (weak, nonatomic) IBOutlet UIView *ccContainerOutlet;

@property (nonatomic, strong) EanHotelRoomAvailabilityResponse *eanHrar;
@property (nonatomic, strong) EanAvailabilityHotelRoomResponse *selectedRoom;
@property (nonatomic, strong) NSArray *tableData;
@property (nonatomic, strong) NSIndexPath *expandedIndexPath;
@property (nonatomic) CGRect rectOfCellInSuperview;
@property (nonatomic) CGRect rectOfAvailRoomContView;
@property (nonatomic, strong) UIButton *doneButton;

@property (nonatomic, strong) UITableView *googlePlacesTableView;
@property (nonatomic, strong) GooglePlaceTableViewDelegateImplementation *googlePlacesTableViewDelegate;
@property (nonatomic) BOOL startFillAddress;

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
//    self.roomsTableViewOutlet.layer.borderWidth = 2.0;
//    self.roomsTableViewOutlet.layer.borderColor = self.view.tintColor.CGColor;
    
//    if ([self.roomsTableViewOutlet respondsToSelector:@selector(separatorInset)]) {
//        [self.roomsTableViewOutlet setSeparatorInset:UIEdgeInsetsZero];
//    }
    
    [self setupExpirationPicker];
    
    self.inputBookOutlet.hidden = YES;
//    self.inputBookOutlet.frame = CGRectMake(10.0f, 412.0f, 300.0f, 0.0f);
    self.inputBookOutlet.transform = [self hiddenGuestInputTransform];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

//- (void)keyboardWillShow:(id)sender {
//    [self dropPostalResultsTableView];
//}

- (void)startEnteringCcBillAddress {
    NSLog(@"");
    
    if (nil == self.googlePlacesTableView) {
        self.googlePlacesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, 320, 268)];
        self.googlePlacesTableView.layer.borderWidth = 2.0f;
        self.googlePlacesTableView.layer.borderColor = self.view.tintColor.CGColor;
        if (nil == self.googlePlacesTableViewDelegate) {
            self.googlePlacesTableViewDelegate = [[GooglePlaceTableViewDelegateImplementation alloc] init];
            self.googlePlacesTableViewDelegate.delegate = self;
        }
        self.googlePlacesTableView.dataSource = self.googlePlacesTableViewDelegate;
        self.googlePlacesTableView.delegate = self.googlePlacesTableViewDelegate;
    }
    
    [self.view endEditing:YES];
    [self loadPostalResultsTableView];
}

- (void)autoCompleteCcBillAddress {
    self.load_data_type = LOAD_AUTOOMPLETE;
    [[LoadGooglePlacesData sharedInstance:self] autoCompleteSomePlaces:self.addressTextFieldOutlet.text];
}

#pragma mark LoadDataProtocol methods

- (void)requestFinished:(NSData *)responseData {
    switch (self.load_data_type) {
        case LOAD_ROOM: {
            self.eanHrar = [EanHotelRoomAvailabilityResponse roomsAvailableResponseFromData:responseData];
            self.tableData = self.eanHrar.hotelRoomArray;
            [self.roomsTableViewOutlet reloadData];
            break;
        }
            
        case LOAD_AUTOOMPLETE: {
            self.load_data_type = LOAD_ROOM;
            self.googlePlacesTableViewDelegate.tableData = [GoogleParser parseAutoCompleteResponse:responseData];
            [self.googlePlacesTableView reloadData];
            break;
        }
            
        case LOAD_PLACE: {
            self.load_data_type = LOAD_ROOM;
            NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSLog(@"PLACESDETAIL:%@", response);
            GooglePlaceDetail *gpd = [GooglePlaceDetail placeDetailFromData:responseData];
            self.addressTextFieldOutlet.text = [EanPlace eanPlaceFromGooglePlaceDetail:gpd].formattedAddress;
            break;
        }
            
        default:
            break;
    }
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
    
    cell.borderViewOutlet.layer.cornerRadius = 8.0f;
    cell.borderViewOutlet.layer.borderWidth = 1.0f;
    cell.borderViewOutlet.layer.borderColor = [UIColor blackColor].CGColor;
    
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
        [self loadRoomDetailsView];
    }
}

//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
//    self.expandedIndexPath = nil;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}

#pragma mark Various methods

- (UIView *)getTableViewPopOut {
    UIView *tableViewPopout = [[UIView alloc] initWithFrame:self.rectOfCellInSuperview];
    tableViewPopout.backgroundColor = [UIColor whiteColor];
    tableViewPopout.hidden = YES;
    tableViewPopout.clipsToBounds = YES;
    [self.view addSubview:tableViewPopout];
    
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"AvailableRoomTableViewCell" owner:self options:nil];
    if (nil != views && [views count] == 1 && [views[0] isKindOfClass:[AvailableRoomTableViewCell class]]) {
        UIView *cv = ((AvailableRoomTableViewCell *) views[0]).contentView;
        cv.tag = kAvailRoomCellContViewTag;
        cv.layer.cornerRadius = 8.0f;
        cv.layer.borderColor = [UIColor blackColor].CGColor;
        cv.layer.borderWidth = 1.0f;
//        cv.backgroundColor = [UIColor greenColor];
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
    } else if (sender == self.paymentButtonOutlet) {
        [self loadPaymentDetailsView];
    }
}

//- (void)paintTheAddressLabel:(GooglePlaceDetail *)gpd {
//    self.fillAddressButtonOutlet.enabled = NO;
//    
//    if (nil == gpd) {
//        self.addressLabelOutlet.text = kNoLocationsFoundMessage;
//        GuestInfo *gi = [GuestInfo singleton];
//        gi.city = nil;
//        gi.stateProvinceCode = nil;
//        gi.countryCode = nil;
//        return;
//    }
//    
//    NSString *localityString = gpd.localityShortName ? [gpd.localityShortName stringByAppendingString:@", "] : @"";
//    NSString *stateStr = gpd.administrativeAreaLevel1ShortName ? [gpd.administrativeAreaLevel1ShortName stringByAppendingString:@", "] : @"";
//    NSString *cntryStr = gpd.countryShortName ? : @"";
//    NSString *addressString = [NSString stringWithFormat:@"%@%@%@", localityString, stateStr, cntryStr];
//    self.addressLabelOutlet.text = addressString;
//    
//    GuestInfo *gi = [GuestInfo singleton];
//    gi.city = gpd.localityShortName;
//    gi.stateProvinceCode = gpd.administrativeAreaLevel1ShortName;
//    gi.countryCode = gpd.countryShortName;
//}

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
                                              creditCardNumber:[JNKeychain loadValueForKey:kKeyDaNumber]
                                          creditCardIdentifier:@"123"
                                     creditCardExpirationMonth:[JNKeychain loadValueForKey:kKeyExpMonth]
                                      creditCardExpirationYear:[JNKeychain loadValueForKey:kKeyExpYear]
                                                      address1:gi.address1
                                                          city:gi.city
                                             stateProvinceCode:gi.stateProvinceCode
                                                   countryCode:gi.countryCode
                                                    postalCode:[JNKeychain loadValueForKey:kKeyPostalCode]];
    
    [self.navigationController pushViewController:bvc animated:YES];
}

- (void)saveDaNumber:(NSString *)daNumber {
    // TODO: validate the number
    [JNKeychain saveValue:daNumber forKey:kKeyDaNumber];
}

- (void)saveDaExpiration:(NSString *)expirationString {
    // TODO: somehow check for valid expiration?
    
    if (nil == expirationString) {
        return;
    }
    
    NSArray *expArr = [expirationString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    
    if (nil == expArr || [expArr count] != 2) {
        return;
    }
    
    NSString *expMonth = expArr[0];
    NSString *expYear = expArr[1];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM"];
    NSDate *daDate = [dateFormatter dateFromString:expMonth];
    NSString *nExpMonth = [dateFormatter stringFromDate:daDate];
    [JNKeychain saveValue:nExpMonth forKey:kKeyExpMonth];
    [JNKeychain saveValue:expYear forKey:kKeyExpYear];
}

- (void)saveNeumann:(NSString *)postalCode {
    // TODO: Rather than users (mis)typing their city, state, and country codes
    // I want to use some API (i.e. Google Places) to get them from the postal
    // code. So I will probably need to save these values to GuestInfo here as
    // well
    [JNKeychain saveValue:postalCode forKey:kKeyPostalCode];
    
//    if (nil == self.addressLabelOutlet.text
//            || [self.addressLabelOutlet.text isEqualToString:@""]
//            || [self.addressLabelOutlet.text isEqualToString:kNoLocationsFoundMessage]) {
//        [[LoadGooglePlacesData sharedInstance:self] loadPlaceDetailsWithPostalCode:postalCode];
//    }
}

#pragma mark UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.expirationOutlet) {
        [textField setInputView:self.expirationPicker];
    } /*else if (textField == self.postalOutlet) {
        [self dropPostalResultsTableView];
    }*/ else {
        ;
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    if (textField == self.postalOutlet) {
//        if (self.postalOutlet.text.length > 0) {
//            self.fillAddressButtonOutlet.enabled = YES;
//        } else {
//            self.fillAddressButtonOutlet.enabled = NO;
//        }
//    }
    return YES;
}

#pragma mark Expiration Picker and Outlet methods

- (void)setupExpirationPicker {
    self.expirationPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 300, 320, 268)];
    self.expirationPicker.dataSource = self;
    self.expirationPicker.delegate = self;
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth|NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger savedExpMonth = [[JNKeychain loadValueForKey:kKeyExpMonth] integerValue];
    if (savedExpMonth > 0 && savedExpMonth < 13) {
        [self.expirationPicker selectRow:(savedExpMonth - 1) inComponent:0 animated:NO];
    } else {
        [self.expirationPicker selectRow:([components month]) inComponent:0 animated:NO];// yes I want to select next month
    }
    
    NSInteger savedExpYear = [[JNKeychain loadValueForKey:kKeyExpYear] integerValue];
    NSInteger layerCake = savedExpYear - [components year];
    if (layerCake >= 0 && layerCake < 1000) {
        [self.expirationPicker selectRow:(savedExpYear - [components year]) inComponent:1 animated:NO];
    } else {
        [self.expirationPicker selectRow:0 inComponent:1 animated:NO];
    }
}

- (void)updateTextInExpirationOutlet {
    NSString *ms = [self pickerView:self.expirationPicker titleForRow:[self.expirationPicker selectedRowInComponent:0] forComponent:0];
    ms = [ms componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]][0];
    NSString *ys = [self pickerView:self.expirationPicker titleForRow:[self.expirationPicker selectedRowInComponent:1] forComponent:1];
    self.expirationOutlet.text = [NSString stringWithFormat:@"%@ %@", ms, ys];
}

#pragma mark UIPickerViewDataSource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (1 == component) {
        return 1000;
    } else {
        return 12;
    }
}

#pragma mark UIPickerViewDelegate methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    static NSDateComponents *components = nil;
    static NSDateFormatter* dateFormatter = nil;
    static NSDateFormatter *formatter = nil;
    
    if (nil == components) {
        components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    }
    
    if (nil == dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM"];
    }
    
    if (nil == formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMMM"];
    }
    
    if (1 == component) {
        return [NSString stringWithFormat:@"%ld", (long)([components year] + row)];
    } else {
        NSDate *wd = [dateFormatter dateFromString:[NSString stringWithFormat: @"%ld", (long)(1 + row)]];
        return [NSString stringWithFormat:@"%@ (%@)", [formatter stringFromDate:wd], [dateFormatter stringFromDate:wd]];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (1 == component) {
        return 120.0f;
    } else {
        return 200.0f;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self updateTextInExpirationOutlet];
}

#pragma mark SelectGooglePlaceDelegate method

- (void)didSelectRow:(GooglePlace *)googlePlace {
    self.load_data_type = LOAD_PLACE;
    [[LoadGooglePlacesData sharedInstance:self] loadPlaceDetails:googlePlace.placeId];
    [self.view endEditing:YES];
    [self dropPostalResultsTableView];
}

#pragma mark Animation methods

- (void)loadRoomDetailsView {
    __weak typeof(self) weakSelf = self;
    __block UIView *tvp = [self getTableViewPopOut];
    __block UIView *cv = [tvp viewWithTag:kAvailRoomCellContViewTag];
    self.rectOfAvailRoomContView = cv.frame;
    __weak UIView *rtv = self.roomsTableViewOutlet;
    __weak UIView *ibo = self.inputBookOutlet;
    
    tvp.frame = self.rectOfCellInSuperview;
    tvp.hidden = NO;
    ibo.hidden = NO;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        tvp.frame = CGRectMake(0.0f, 64.0f, 320.0f, 300.0f);
        cv.frame = CGRectMake(2.0f, 2.0f, 316.0f, 296.0f);
        rtv.transform = CGAffineTransformMakeScale(0.01, 0.01);
        ibo.transform = [weakSelf shownGuestInputTransform];
    } completion:^(BOOL finished) {
        rtv.hidden = YES;
    }];
}

- (void)compressFromDetailViews:(id)sender {
    __weak typeof(self) weakSelf = self;
    __weak UIView *db = self.doneButton;
    __weak UIView *tvp = self.doneButton.superview;
    __block UIView *cv = [tvp viewWithTag:kAvailRoomCellContViewTag];
    __weak UIView *rtv = self.roomsTableViewOutlet;
    __weak UIView *ibo = self.inputBookOutlet;
    self.expandedIndexPath = nil;
    
    rtv.hidden = NO;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        db.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
        tvp.frame = weakSelf.rectOfCellInSuperview;
        cv.frame = weakSelf.rectOfAvailRoomContView;
        rtv.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        ibo.transform = [weakSelf hiddenGuestInputTransform];
    } completion:^(BOOL finished) {
        tvp.hidden = YES;
        ibo.hidden = YES;
    }];
}

- (void)loadGuestDetailsView {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"GuestDetailsView" owner:self options:nil];
    if (nil == views || [views count] != 1) {
        return;
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dropGuestDetailsView:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dropGuestDetailsView:)];
    
    __weak UIView *guestDetailsView = views[0];
    guestDetailsView.tag = kGuestDetailsViewTag;
    guestDetailsView.frame = CGRectMake(10, 64, 300, 300);
    
    CGPoint gboCenter = [self.view convertPoint:self.guestButtonOutlet.center fromView:self.inputBookOutlet];
    CGFloat fromX = gboCenter.x - guestDetailsView.center.x;
    CGFloat fromY = gboCenter.y - guestDetailsView.center.y;
    CGAffineTransform fromTransform = CGAffineTransformMakeTranslation(fromX, fromY);
    guestDetailsView.transform = CGAffineTransformScale(fromTransform, 0.01f, 0.01f);
    
    [self.view addSubview:guestDetailsView];
    [self.firstNameOutlet becomeFirstResponder];
    GuestInfo *gi = [GuestInfo singleton];
    self.firstNameOutlet.text = gi.firstName;
    self.lastNameOutlet.text = gi.lastName;
    self.emailOutlet.text = gi.email;
    self.phoneOutlet.text = gi.phoneNumber;
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
    
    __weak UIView *guestDetailsView = [self.view viewWithTag:kGuestDetailsViewTag];
    
    CGPoint gboCenter = [self.view convertPoint:self.guestButtonOutlet.center fromView:self.inputBookOutlet];
    CGFloat toX = gboCenter.x - guestDetailsView.center.x;
    CGFloat toY = gboCenter.y - guestDetailsView.center.y;
    __block CGAffineTransform toTransform = CGAffineTransformMakeTranslation(toX, toY);
    
    //    [self.firstNameOutlet resignFirstResponder];
    [self.view endEditing:YES];
    self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
    self.navigationItem.rightBarButtonItem = nil;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        guestDetailsView.transform = CGAffineTransformScale(toTransform, 0.01f, 0.01f);
    } completion:^(BOOL finished) {
        [guestDetailsView removeFromSuperview];;
    }];
}

- (void)loadPaymentDetailsView {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"PaymentDetailsView" owner:self options:nil];
    if (nil == views || [views count] != 1) {
        return;
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dropPaymentDetailsView:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dropPaymentDetailsView:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    __weak UIView *paymentDetailsView = views[0];
    paymentDetailsView.tag = kPaymentDetailsViewTag;
    paymentDetailsView.frame = CGRectMake(10, 64, 300, 568);
    
    CGPoint pboCenter = [self.view convertPoint:self.paymentButtonOutlet.center fromView:self.inputBookOutlet];
    CGFloat fromX = pboCenter.x - paymentDetailsView.center.x;
    CGFloat fromY = pboCenter.y - paymentDetailsView.center.y;
    CGAffineTransform fromTransform = CGAffineTransformMakeTranslation(fromX, fromY);
    paymentDetailsView.transform = CGAffineTransformScale(fromTransform, 0.01f, 0.01f);
    
    [self.view addSubview:paymentDetailsView];
    
    self.addressTextFieldOutlet.delegate = nil;
    [self.addressTextFieldOutlet addTarget:self action:@selector(startEnteringCcBillAddress) forControlEvents:UIControlEventTouchDown];
    [self.addressTextFieldOutlet addTarget:self action:@selector(autoCompleteCcBillAddress) forControlEvents:UIControlEventEditingChanged];
    
    [self.ccNumberOutlet becomeFirstResponder];
    self.ccNumberOutlet.text = [JNKeychain loadValueForKey:kKeyDaNumber];
    [self updateTextInExpirationOutlet];
    GuestInfo *gi = [GuestInfo singleton];
    self.address1Outlet.text = gi.address1;
    
//    self.postalOutlet.delegate = self;
    NSString *neumannCode = [JNKeychain loadValueForKey:kKeyPostalCode];
    if (nil != neumannCode && ![neumannCode isEqualToString:@""]) {
//        self.postalOutlet.text = neumannCode;
//        self.addressLabelOutlet.text = [NSString stringWithFormat:@"%@, %@, %@", gi.city, gi.stateProvinceCode, gi.countryCode];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
//        self.postalOutlet.text = nil;
//        self.addressLabelOutlet.text = nil;
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    self.expirationOutlet.delegate = self;
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        paymentDetailsView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)dropPaymentDetailsView:(id)sender {
    if (sender == self.navigationItem.rightBarButtonItem) {
        GuestInfo *gi = [GuestInfo singleton];
        gi.address1 = self.address1Outlet.text;
        [self saveDaNumber:self.ccNumberOutlet.text];
        [self saveDaExpiration:self.expirationOutlet.text];
//        [self saveNeumann:self.postalOutlet.text];
    }
    
    [self dropPostalResultsTableView];
    
    __weak UIView *paymentDetailsView = [self.view viewWithTag:kPaymentDetailsViewTag];
    
    CGPoint pboCenter = [self.view convertPoint:self.paymentButtonOutlet.center fromView:self.inputBookOutlet];
    CGFloat toX = pboCenter.x - paymentDetailsView.center.x;
    CGFloat toY = pboCenter.y - paymentDetailsView.center.y;
    __block CGAffineTransform toTransform = CGAffineTransformMakeTranslation(toX, toY);
    
    //    [self.ccNumberOutlet resignFirstResponder];
    [self.view endEditing:YES];
    self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
    self.navigationItem.rightBarButtonItem = nil;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        paymentDetailsView.transform = CGAffineTransformScale(toTransform, 0.01f, 0.01f);
    } completion:^(BOOL finished) {
        [paymentDetailsView removeFromSuperview];;
    }];
}

- (void)loadPostalResultsTableView {
    __weak UITableView *prtv = self.googlePlacesTableView;
    __weak UIView *ccco = self.ccContainerOutlet;
    prtv.transform = CGAffineTransformMakeTranslation(0.0f, 400.0f);
    [self.view addSubview:self.googlePlacesTableView];
    [UIView animateWithDuration:kAnimationDuration animations:^{
        prtv.transform = CGAffineTransformMakeTranslation(0.0f, 0.0f);
        ccco.transform = CGAffineTransformMakeTranslation(0.0f, -120.0f);
    } completion:^(BOOL finished) {
    }];
}

- (void)dropPostalResultsTableView {
    if (nil == self.googlePlacesTableView) {
        return;
    }
    
    __weak UITableView *prtv = self.googlePlacesTableView;
    __weak UIView *ccco = self.ccContainerOutlet;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        prtv.transform = CGAffineTransformMakeTranslation(0.0f, 400.0f);
        ccco.transform = CGAffineTransformMakeTranslation(0.0f, 0.0f);
    } completion:^(BOOL finished) {
        [prtv removeFromSuperview];
    }];
}

@end
