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
#import <AudioToolbox/AudioToolbox.h>
#import "BKCardNumberField.h"

typedef NS_ENUM(NSUInteger, LOAD_DATA) {
    LOAD_ROOM = 0,
    LOAD_AUTOOMPLETE = 1,
    LOAD_PLACE = 2
};

NSTimeInterval const kAnimationDuration = 0.6f;
NSUInteger const kGuestDetailsViewTag = 51;
NSUInteger const kPaymentDetailsViewTag = 52;
NSUInteger const kAvailRoomCellTag = 13456;
NSUInteger const kAvailRoomCellContViewTag = 19191;
NSUInteger const kAvailRoomBorderViewTag = 13;
NSUInteger const kNightlyRateViewTag = 19;
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

@property (weak, nonatomic) IBOutlet BKCardNumberField *ccNumberOutlet;
@property (weak, nonatomic) IBOutlet UITextField *addressTextFieldOutlet;
@property (weak, nonatomic) IBOutlet UITextField *expirationOutlet;
@property (weak, nonatomic) IBOutlet UITextField *cardholderOutlet;
@property (nonatomic, strong) UIView *expirationInputView;
@property (nonatomic, strong) UIPickerView *expirationPicker;
@property (nonatomic, strong) UIButton *expirationNext;
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
@property (nonatomic) BOOL showingGooglePlacesTableView;

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
//    [self dropGooglePlacesTableView];
//}

- (void)startEnteringCcBillAddress {
    NSLog(@"");
    
    if (nil == self.googlePlacesTableView) {
        self.googlePlacesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 134, 320, 218)];
        self.googlePlacesTableView.layer.borderWidth = 2.0f;
        self.googlePlacesTableView.layer.borderColor = self.view.tintColor.CGColor;
        if (nil == self.googlePlacesTableViewDelegate) {
            self.googlePlacesTableViewDelegate = [[GooglePlaceTableViewDelegateImplementation alloc] init];
            self.googlePlacesTableViewDelegate.delegate = self;
        }
        self.googlePlacesTableView.dataSource = self.googlePlacesTableViewDelegate;
        self.googlePlacesTableView.delegate = self.googlePlacesTableViewDelegate;
    }
    
//    [self.view endEditing:YES];
    [self.addressTextFieldOutlet becomeFirstResponder];
    [self loadGooglePlacesTableView];
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
    
//    EanAvailabilityHotelRoomResponse *room = [EanAvailabilityHotelRoomResponse roomFromDict:[self.tableData objectAtIndex:indexPath.row]];
    
    EanAvailabilityHotelRoomResponse *room = [self.tableData objectAtIndex:indexPath.row];
    
    cell.roomTypeDescriptionOutlet.text = room.roomTypeDescription;
    
    NSNumberFormatter *currencyStyle = kPriceRoundOffFormatter(room.currencyCode);
//    [currencyStyle setLocale:locale];
    NSString *currency = [currencyStyle stringFromNumber:room.nightlyRateToPresent];
    
    cell.rateOutlet.text = currency;
    
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
//    tableViewPopout.hidden = YES;
    tableViewPopout.clipsToBounds = YES;
    [self.view addSubview:tableViewPopout];
    
    UIView *cellV = [[UIView alloc] initWithFrame:tableViewPopout.bounds];
    cellV.tag = kAvailRoomCellTag;
    [tableViewPopout addSubview:cellV];
    UIView *cv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cellV.bounds.size.width, cellV.bounds.size.height - 1)];
    cv.tag = kAvailRoomCellContViewTag;
    [cellV addSubview:cv];
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, 316, 95)];
    borderView.layer.borderColor = [UIColor blackColor].CGColor;
    borderView.layer.borderWidth = 1.0f;
    borderView.layer.cornerRadius = 8.0f;
    borderView.tag = kAvailRoomBorderViewTag;
    [cv addSubview:borderView];
    
    //    EanAvailabilityHotelRoomResponse *room = [EanAvailabilityHotelRoomResponse roomFromDict:[self.tableData objectAtIndex:self.expandedIndexPath.row]];
    
    EanAvailabilityHotelRoomResponse *room = [self.tableData objectAtIndex:self.expandedIndexPath.row];
    
    UILabel *rtd = [[UILabel alloc] initWithFrame:CGRectMake(3, 8, 244, 63)];
    rtd.lineBreakMode = NSLineBreakByWordWrapping;
    rtd.numberOfLines = 2;
    rtd.text = room.roomTypeDescription;
    [borderView addSubview:rtd];
    
    UILabel *rateLabel = [[UILabel alloc] initWithFrame:CGRectMake(256, 26, 56, 28)];
    rateLabel.textColor = UIColorFromRGB(0x0D9C03);
    rateLabel.textAlignment = NSTextAlignmentRight;
//    [rateLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
    [rateLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18.0f]];
    NSNumberFormatter *currencyStyle = kPriceRoundOffFormatter(room.currencyCode);
    //    [currencyStyle setLocale:locale];
    NSString *currency = [currencyStyle stringFromNumber:room.nightlyRateToPresent];
    rateLabel.text = currency;
    [borderView addSubview:rateLabel];
    
    self.doneButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 50)];
    [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.doneButton.backgroundColor = [UIColor whiteColor];
    [self.doneButton addTarget:self action:@selector(dropRoomDetailsView:) forControlEvents:UIControlEventTouchUpInside];
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
    
    self.selectedRoom = [self.tableData objectAtIndex:self.expandedIndexPath.row];
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
    if (textField != self.addressTextFieldOutlet) {
        [self dropGooglePlacesTableView];
    }
    
    if (textField == self.ccNumberOutlet) {
        
    } else if (textField == self.addressTextFieldOutlet) {
        [self startEnteringCcBillAddress];
    } else if (textField == self.expirationOutlet) {
        [textField setInputView:self.expirationInputView];
    } else if (textField == self.cardholderOutlet) {
        
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.ccNumberOutlet) {
        
    } else if (textField == self.addressTextFieldOutlet) {
        [self autoCompleteCcBillAddress];
    } else if (textField == self.expirationOutlet) {
        
    } else if (textField == self.cardholderOutlet) {
        [self validateCardholder];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.ccNumberOutlet) {
        [self.addressTextFieldOutlet becomeFirstResponder];
    } else if (textField == self.addressTextFieldOutlet) {
        [self dropGooglePlacesTableView];
        [self.expirationOutlet becomeFirstResponder];
    } else if (textField == self.expirationOutlet) {
        [self.cardholderOutlet becomeFirstResponder];
    } else if (textField == self.cardholderOutlet) {
        [self.ccNumberOutlet becomeFirstResponder];
    }
    
    if (textField == self.firstNameOutlet) {
        [self.lastNameOutlet becomeFirstResponder];
    } else if (textField == self.lastNameOutlet) {
        [self.emailOutlet becomeFirstResponder];
    } else if (textField == self.emailOutlet) {
        [self.phoneOutlet becomeFirstResponder];
    } else if (textField == self.phoneOutlet) {
        [self.firstNameOutlet becomeFirstResponder];
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField == self.addressTextFieldOutlet) {
        self.googlePlacesTableViewDelegate.tableData = nil;
        [self.googlePlacesTableView reloadData];
    } else if (textField == self.cardholderOutlet) {
        self.cardholderOutlet.backgroundColor = [UIColor whiteColor];
    }
    
    return YES;
}

#pragma mark Expiration Picker and Outlet methods

- (void)tdExpirNext:(id)sender {
    AudioServicesPlaySystemSound(0x450);
    ((UIView *)sender).backgroundColor = [UIColor whiteColor];
}

- (void)tuiExpirNext:(id)sender {
    ((UIView *) sender).backgroundColor = UIColorFromRGB(0xc4c4c4);
    [self.cardholderOutlet becomeFirstResponder];
}

- (void)tuoExpirNext:(id)sender {
    ((UIView *) sender).backgroundColor = UIColorFromRGB(0xc4c4c4);
}

- (void)setupExpirationPicker {
    self.expirationInputView = [[UIView alloc] initWithFrame:CGRectMake(0, 270, 320, 298)];
    self.expirationInputView.backgroundColor = [UIColor whiteColor];
    
    self.expirationNext = [[UIButton alloc] initWithFrame:CGRectMake(242, 257, 75, 38)];
    self.expirationNext.backgroundColor = UIColorFromRGB(0xc4c4c4);
    self.expirationNext.layer.cornerRadius = 4.0f;
    self.expirationNext.layer.masksToBounds = NO;
    self.expirationNext.layer.borderWidth = 0.8f;
    self.expirationNext.layer.borderColor = UIColorFromRGB(0xb5b5b5).CGColor;
    
    self.expirationNext.layer.shadowColor = [UIColor blackColor].CGColor;
    self.expirationNext.layer.shadowOpacity = 0.8;
    self.expirationNext.layer.shadowRadius = 1;
    self.expirationNext.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    
    [self.expirationNext setTitle:@"Next" forState:UIControlStateNormal];
    self.expirationNext.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [self.expirationNext setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.expirationNext addTarget:self action:@selector(tdExpirNext:) forControlEvents:UIControlEventTouchDown];
    [self.expirationNext addTarget:self action:@selector(tuiExpirNext:) forControlEvents:UIControlEventTouchUpInside];
    [self.expirationNext addTarget:self action:@selector(tuoExpirNext:) forControlEvents:UIControlEventTouchUpOutside];
    [self.expirationInputView addSubview:self.expirationNext];
    
    self.expirationPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 20, 320, 268)];
    self.expirationPicker.backgroundColor = UIColorFromRGB(0xe3e3e3);
    [self.expirationInputView addSubview:self.expirationPicker];
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
//    [self.view endEditing:YES];
//    [self.expirationOutlet becomeFirstResponder];
    [self dropGooglePlacesTableView];
}

#pragma mark Animation methods

- (void)loadRoomDetailsView {
    __weak typeof(self) weakSelf = self;
    __block UIView *tvp = [self getTableViewPopOut];
    __weak UIView *cv = [tvp viewWithTag:kAvailRoomCellContViewTag];
    __weak UIView *borderView = [cv viewWithTag:kAvailRoomBorderViewTag];
    __weak UIView *rtv = self.roomsTableViewOutlet;
    __weak UIView *ibo = self.inputBookOutlet;
    
    [self.view addSubview:tvp];
    tvp.frame = self.rectOfCellInSuperview;
    self.rectOfAvailRoomContView = cv.frame;
    tvp.hidden = NO;
    ibo.hidden = NO;
    __block UIButton *doneB = self.doneButton;
    doneB.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0.0f, -(tvp.frame.size.height/3)), 0.01f, 0.01f);
    [UIView animateWithDuration:kAnimationDuration animations:^{
        tvp.frame = CGRectMake(0.0f, 64.0f, 320.0f, 300.0f);
        cv.frame = tvp.bounds;
        borderView.frame = CGRectMake(2.0f, 2.0f, cv.frame.size.width - 4.0f, cv.frame.size.height - 4.0f);
        rtv.transform = CGAffineTransformMakeScale(0.01, 0.01);
        ibo.transform = [weakSelf shownGuestInputTransform];
        doneB.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, 0), 1.0f, 1.0f);
    } completion:^(BOOL finished) {
        rtv.hidden = YES;
    }];
}

- (void)dropRoomDetailsView:(id)sender {
    __weak typeof(self) weakSelf = self;
    __weak UIView *db = self.doneButton;
    __weak UIView *tvp = self.doneButton.superview;
    __weak UIView *cv = [tvp viewWithTag:kAvailRoomCellContViewTag];
    __weak UIView *borderView = [cv viewWithTag:kAvailRoomBorderViewTag];
    __weak UIView *rtv = self.roomsTableViewOutlet;
    __weak UIView *ibo = self.inputBookOutlet;
    self.expandedIndexPath = nil;
    
    rtv.hidden = NO;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        db.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0.0f, -(tvp.frame.size.height/6)), 0.01f, 0.01f);
        tvp.frame = weakSelf.rectOfCellInSuperview;
        cv.frame = weakSelf.rectOfAvailRoomContView;
        borderView.frame = CGRectMake(2.0f, 2.0f, weakSelf.rectOfAvailRoomContView.size.width - 4.0f, weakSelf.rectOfAvailRoomContView.size.height - 4.0f);
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
    
    self.firstNameOutlet.delegate = self;
    self.lastNameOutlet.delegate = self;
    self.emailOutlet.delegate = self;
    self.phoneOutlet.delegate = self;
    
    __weak UIView *guestDetailsView = views[0];
    guestDetailsView.tag = kGuestDetailsViewTag;
    guestDetailsView.frame = CGRectMake(0, 64, 320, 568);
    
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
    paymentDetailsView.frame = CGRectMake(0, 64, 320, 568);
    
    CGPoint pboCenter = [self.view convertPoint:self.paymentButtonOutlet.center fromView:self.inputBookOutlet];
    CGFloat fromX = pboCenter.x - paymentDetailsView.center.x;
    CGFloat fromY = pboCenter.y - paymentDetailsView.center.y;
    CGAffineTransform fromTransform = CGAffineTransformMakeTranslation(fromX, fromY);
    paymentDetailsView.transform = CGAffineTransformScale(fromTransform, 0.01f, 0.01f);
    
    [self.view addSubview:paymentDetailsView];
    
    self.ccNumberOutlet.delegate = self;
    self.addressTextFieldOutlet.delegate = self;
    self.expirationOutlet.delegate = self;
    self.cardholderOutlet.delegate = self;
    
    [self.ccNumberOutlet becomeFirstResponder];
    self.ccNumberOutlet.showsCardLogo = YES;
    self.ccNumberOutlet.text = [JNKeychain loadValueForKey:kKeyDaNumber];
    [self updateTextInExpirationOutlet];
//    GuestInfo *gi = [GuestInfo singleton];
//    self.address1Outlet.text = gi.address1;
    
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
//        GuestInfo *gi = [GuestInfo singleton];
//        gi.address1 = self.address1Outlet.text;
        [self saveDaNumber:self.ccNumberOutlet.text];
        [self saveDaExpiration:self.expirationOutlet.text];
//        [self saveNeumann:self.postalOutlet.text];
    }
    
    [self dropGooglePlacesTableView];
    
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

- (void)loadGooglePlacesTableView {
    if (self.showingGooglePlacesTableView) {
        return;
    }
    
    self.showingGooglePlacesTableView = YES;
    
    __weak UITableView *gptv = self.googlePlacesTableView;
    gptv.transform = CGAffineTransformMakeTranslation(0.0f, 400.0f);
    [self.view addSubview:self.googlePlacesTableView];
    [UIView animateWithDuration:kAnimationDuration animations:^{
        gptv.transform = CGAffineTransformMakeTranslation(0.0f, 0.0f);
    } completion:^(BOOL finished) {
    }];
}

- (void)dropGooglePlacesTableView {
    if (nil == self.googlePlacesTableView || !self.showingGooglePlacesTableView) {
        return;
    }
    
    self.showingGooglePlacesTableView = NO;
    
    __weak UITableView *gptv = self.googlePlacesTableView;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        gptv.transform = CGAffineTransformMakeTranslation(0.0f, 400.0f);
    } completion:^(BOOL finished) {
        [gptv removeFromSuperview];
    }];
}

#pragma mark Validation methods

- (BOOL)validateCreditCardNumber {
    return YES;
}

- (BOOL)validateBillingAddress {
    return YES;
}

- (BOOL)validateExpiration {
    return YES;
}

- (BOOL)validateCardholder {
    NSArray *ch = [self.cardholderOutlet.text componentsSeparatedByString:@" "];
    if ([ch count] != 2) {
        self.cardholderOutlet.backgroundColor = [UIColor colorWithRed:255 green:0 blue:0 alpha:0.5f];
        return NO;
    }
    
    self.cardholderOutlet.backgroundColor = [UIColor colorWithRed:0 green:255 blue:0 alpha:0.5f];
    return YES;
}

@end
