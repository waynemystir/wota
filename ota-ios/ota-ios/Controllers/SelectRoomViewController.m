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
#import "PaymentDetails.h"
#import "AppEnvironment.h"
#import "GoogleParser.h"
#import "GooglePlaces.h"
#import "GooglePlaceDetail.h"
#import "GooglePlaceTableViewDelegateImplementation.h"
#import "LoadGooglePlacesData.h"
#import "EanPlace.h"
#import <AudioToolbox/AudioToolbox.h>
#import "WotaCardNumberField.h"
#import "PTKCardNumber.h"
#import "SelectBedTypeDelegateImplementation.h"
#import "SelectSmokingPreferenceDelegateImplementation.h"
#import "WotaButton.h"

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

@interface SelectRoomViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, SelectGooglePlaceDelegate, SelectBedTypeDelegate, SelectSmokingPrefDelegate>

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

@property (weak, nonatomic) IBOutlet WotaCardNumberField *ccNumberOutlet;
@property (weak, nonatomic) IBOutlet UITextField *addressTextFieldOutlet;
@property (weak, nonatomic) IBOutlet UITextField *expirationOutlet;
@property (weak, nonatomic) IBOutlet UITextField *cardholderOutlet;
@property (nonatomic, strong) UIView *expirationInputView;
@property (nonatomic, strong) UIPickerView *expirationPicker;
@property (weak, nonatomic) IBOutlet UIButton *deleteCardOutlet;
@property (weak, nonatomic) IBOutlet UIButton *cancelDeletionOutlet;
@property (nonatomic, strong) UIButton *expirationNext;
@property (weak, nonatomic) IBOutlet UIView *ccContainerOutlet;

@property (nonatomic, strong) EanHotelRoomAvailabilityResponse *eanHrar;
@property (nonatomic, strong) EanAvailabilityHotelRoomResponse *selectedRoom;
@property (nonatomic, strong) NSArray *tableData;
@property (nonatomic, strong) NSIndexPath *expandedIndexPath;
@property (nonatomic) CGRect rectOfCellInSuperview;
@property (nonatomic) CGRect rectOfAvailRoomContView;
@property (nonatomic, strong) WotaButton *bedTypeButton;
@property (nonatomic, strong) WotaButton *smokingButton;
@property (nonatomic, strong) UIView *bedTypePickerContainer;
@property (nonatomic, strong) UIButton *bedTypePickerDone;
@property (nonatomic, strong) UIPickerView *bedTypePickerView;
@property (nonatomic, strong) SelectBedTypeDelegateImplementation *bedTypePickerDelegate;
@property (nonatomic) BOOL isBedTypePickerShowing;
@property (nonatomic, strong) UIPickerView *smokingPrefPickerView;
@property (nonatomic, strong) SelectSmokingPreferenceDelegateImplementation *smokePrefDelegImplem;

@property (nonatomic, strong) UITableView *googlePlacesTableView;
@property (nonatomic, strong) GooglePlaceTableViewDelegateImplementation *googlePlacesTableViewDelegate;
@property (nonatomic) BOOL showingGooglePlacesTableView;
@property (nonatomic, strong) EanPlace *selectedBillingAddress;

@property (nonatomic) BOOL isValidCreditCard;
@property (nonatomic) BOOL isValidBillingAddress;
@property (nonatomic) BOOL isValidExpiration;
@property (nonatomic) BOOL isValidCardHolder;

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
    [self setupBedTypePicker];
    
    self.inputBookOutlet.hidden = YES;
//    self.inputBookOutlet.frame = CGRectMake(10.0f, 412.0f, 300.0f, 0.0f);
    self.inputBookOutlet.transform = [self hiddenGuestInputTransform];
    self.inputBookOutlet.layer.cornerRadius = 6.0f;
    self.inputBookOutlet.layer.borderWidth = 1.0f;
    self.inputBookOutlet.layer.borderColor = [UIColor blackColor].CGColor;
    
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
            self.selectedBillingAddress = [EanPlace eanPlaceFromGooglePlaceDetail:gpd];
            [self validateBillingAddressWithNoGoColor:YES];
            self.addressTextFieldOutlet.text = self.selectedBillingAddress.formattedAddress;
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
    
    EanAvailabilityHotelRoomResponse *room = [self.tableData objectAtIndex:indexPath.row];
    
    cell.roomTypeDescriptionOutlet.text = room.roomTypeDescription;
    
    NSNumberFormatter *currencyStyle = kPriceRoundOffFormatter(room.currencyCode);
//    [currencyStyle setLocale:locale];
    NSString *currency = [currencyStyle stringFromNumber:room.nightlyRateToPresent];
    
    cell.rateOutlet.text = currency;
    
    cell.nonrefundOutlet.text = room.nonRefundableString;
    
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
    tableViewPopout.autoresizesSubviews = YES;
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
    
    UILabel *nonreundLabel = [[UILabel alloc] initWithFrame:CGRectMake(176, 69, 136, 21)];
    nonreundLabel.backgroundColor = [UIColor colorWithRed:255/255.0f green:141/255.0f blue:9/255.0f alpha:1.0f];
    nonreundLabel.font = [UIFont systemFontOfSize:15.0f];
    nonreundLabel.textAlignment = NSTextAlignmentRight;
    nonreundLabel.text = room.nonRefundableString;
    [borderView addSubview:nonreundLabel];
    
    self.bedTypeButton = [WotaButton wbWithFrame:CGRectMake(5, 264, 186, 30)];
    [self.bedTypeButton setTitle:room.selectedBedType.bedTypeDescription forState:UIControlStateNormal];
    [self.bedTypeButton addTarget:self action:@selector(clickBedType:) forControlEvents:UIControlEventTouchUpInside];
    [tableViewPopout addSubview:self.bedTypeButton];
    
    self.smokingButton = [WotaButton wbWithFrame:CGRectMake(194, 264, 120, 30)];
    [self.smokingButton setTitle:[SelectSmokingPreferenceDelegateImplementation smokingPrefStringForEanSmokeCode:room.selectedSmokingPreference] forState:UIControlStateNormal];
    [self.smokingButton addTarget:self action:@selector(clickSmokingPref:) forControlEvents:UIControlEventTouchUpInside];
    [tableViewPopout addSubview:self.smokingButton];
    
//    self.doneButton = [WotaButton wbWithFrame:CGRectMake(194, 264, 120, 30)];
//    [self.doneButton setTitle:@"Different Room" forState:UIControlStateNormal];
//    [self.doneButton addTarget:self action:@selector(dropRoomDetailsView:) forControlEvents:UIControlEventTouchUpInside];
//    [tableViewPopout addSubview:self.doneButton];
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

- (void)clickBedType:(id)sender {
    self.bedTypePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 162)];
    self.bedTypePickerView.backgroundColor = UIColorFromRGB(0xe3e3e3);
    self.bedTypePickerDelegate = [SelectBedTypeDelegateImplementation new];
    self.bedTypePickerDelegate.bedTypeDelegate = self;
    EanAvailabilityHotelRoomResponse *room = [self.tableData objectAtIndex:self.expandedIndexPath.row];
    self.bedTypePickerDelegate.pickerData = room.bedTypesArray;
    self.bedTypePickerView.dataSource = self.bedTypePickerDelegate;
    self.bedTypePickerView.delegate = self.bedTypePickerDelegate;
    NSUInteger sbti = [self.bedTypePickerDelegate.pickerData indexOfObject:room.selectedBedType];
    [self.bedTypePickerView selectRow:sbti inComponent:0 animated:NO];
    
    [self.bedTypePickerContainer addSubview:self.bedTypePickerView];
    self.isBedTypePickerShowing = YES;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.bedTypePickerContainer.frame = CGRectMake(0, 364, 320, 204);
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)clickSmokingPref:(id)sender {
    self.smokingPrefPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 162)];
    self.smokingPrefPickerView.backgroundColor = UIColorFromRGB(0xe3e3e3);
    self.smokePrefDelegImplem = [SelectSmokingPreferenceDelegateImplementation new];
    self.smokePrefDelegImplem.smokePrefDelegate = self;
    EanAvailabilityHotelRoomResponse *room = [self.tableData objectAtIndex:self.expandedIndexPath.row];
    self.smokePrefDelegImplem.pickerData = room.smokingPreferencesArray;
    self.smokingPrefPickerView.dataSource = self.smokePrefDelegImplem;
    self.smokingPrefPickerView.delegate = self.smokePrefDelegImplem;
    NSUInteger sspi = [self.smokePrefDelegImplem.pickerData indexOfObject:room.selectedSmokingPreference];
    [self.smokingPrefPickerView selectRow:sspi inComponent:0 animated:NO];
    
    [self.bedTypePickerContainer addSubview:self.smokingPrefPickerView];
    self.isBedTypePickerShowing = YES;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.bedTypePickerContainer.frame = CGRectMake(0, 364, 320, 204);
    } completion:^(BOOL finished) {
        ;
    }];
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

- (void)bookIt {
    if (nil == self.expandedIndexPath) {
        return;
    }
    
    self.selectedRoom = [self.tableData objectAtIndex:self.expandedIndexPath.row];
    SelectionCriteria *sc = [SelectionCriteria singleton];
    GuestInfo *gi = [GuestInfo singleton];
    PaymentDetails *pd = [PaymentDetails card1];
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
                                                room1BedTypeId:self.selectedRoom.selectedBedType.bedTypeId
                                        room1SmokingPreference:self.selectedRoom.selectedSmokingPreference
                                       affiliateConfirmationId:[NSUUID UUID]
                                                         email:gi.email
                                                     firstName:pd.cardHolderFirstName
                                                      lastName:pd.cardHolderLastName
                                                     homePhone:gi.phoneNumber
                                                creditCardType:pd.eanCardType
                                              creditCardNumber:@"5401999999999999"/*pd.cardNumber*/
                                          creditCardIdentifier:@"123"
                                     creditCardExpirationMonth:pd.expirationMonth
                                      creditCardExpirationYear:pd.expirationYear
                                                      address1:pd.billingAddress.apiAddress1
                                                          city:pd.billingAddress.apiCity
                                             stateProvinceCode:nil/*pd.billingAddress.apiStateProvCode*/
                                                   countryCode:pd.billingAddress.apiCountryCode
                                                    postalCode:pd.billingAddress.apiPostalCode];
    
    [self.navigationController pushViewController:bvc animated:YES];
}

- (void)saveDaExpiration {
    if (nil == self.expirationOutlet.text) {
        return;
    }
    
    NSArray *expArr = [self.expirationOutlet.text componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    
    if (nil == expArr || [expArr count] != 2) {
        return;
    }
    
    NSString *expMonth = expArr[0];
    NSString *expYear = expArr[1];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM"];
    NSDate *daDate = [dateFormatter dateFromString:expMonth];
    NSString *nExpMonth = [dateFormatter stringFromDate:daDate];
    
    [PaymentDetails card1].expirationMonth = nExpMonth;
    [PaymentDetails card1].expirationYear = expYear;
}

- (void)addInputAccessoryViewToCardNumber {
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    self.ccNumberOutlet.inputAccessoryView = numberToolbar;
}

-(void)doneWithNumberPad {
    AudioServicesPlaySystemSound(0x450);
    [self textFieldShouldReturn:self.ccNumberOutlet];
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.ccNumberOutlet) {
        [self addInputAccessoryViewToCardNumber];
    }
    return YES;
}

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
        NSString *cn = nil;
        if ([string isEqualToString:@""]) {
            NSUInteger lastCharIndex = [((WotaCardNumberField *) textField).cardNumber length] - 1; // I assume string is not empty
            NSRange wr = [((WotaCardNumberField *) textField).cardNumber rangeOfComposedCharacterSequenceAtIndex: lastCharIndex];

            cn = [((WotaCardNumberField *) textField).cardNumber stringByReplacingCharactersInRange:wr withString:string];
        } else {
            cn = [((WotaCardNumberField *) textField).cardNumber stringByAppendingString:string];
        }
        [self validateCreditCardNumber:cn];
    } else if (textField == self.addressTextFieldOutlet) {
        [self autoCompleteCcBillAddress];
        [self loadGooglePlacesTableView];
    } else if (textField == self.expirationOutlet) {
        
    } else if (textField == self.cardholderOutlet) {
        NSString *ch = [textField.text stringByReplacingCharactersInRange:range withString:string];
        [self validateCardholder:ch];
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
    if (textField == self.ccNumberOutlet) {
        self.isValidCreditCard = NO;
        [self enableOrDisableRightBarButtonItem];
        self.ccNumberOutlet.backgroundColor = [UIColor whiteColor];
    } else if (textField == self.addressTextFieldOutlet) {
        self.googlePlacesTableViewDelegate.tableData = nil;
        [self.googlePlacesTableView reloadData];
        [self loadGooglePlacesTableView];
        self.isValidBillingAddress = NO;
        [self isWeGood];
        self.addressTextFieldOutlet.backgroundColor = [UIColor whiteColor];
    } else if (textField == self.cardholderOutlet) {
        self.isValidCardHolder = NO;
        [self isWeGood];
        self.cardholderOutlet.backgroundColor = [UIColor whiteColor];
    }
    
    return YES;
}

#pragma mark Expiration Picker and Outlet methods

- (void)tdBedTypeDone:(id)sender {
    ((UIButton *)sender).backgroundColor = [UIColor whiteColor];
    AudioServicesPlaySystemSound(0x450);
}

- (void)tuiBedTypeDone:(id)sender {
    if (!self.isBedTypePickerShowing) {
        return;
    }
    
    ((UIButton *) sender).backgroundColor = UIColorFromRGB(0xc4c4c4);
    
    self.isBedTypePickerShowing = NO;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.bedTypePickerContainer.frame = CGRectMake(0, 600, 320, 204);
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)tuoBedTypeDone:(id)sender {
    ((UIButton *) sender).backgroundColor = UIColorFromRGB(0xc4c4c4);
}

- (void)setupBedTypePicker {
    self.bedTypePickerContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 600, 320, 204)];
    self.bedTypePickerContainer.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.bedTypePickerContainer];
    
    self.bedTypePickerDone = [[UIButton alloc] initWithFrame:CGRectMake(242, 163, 75, 38)];
    self.bedTypePickerDone.backgroundColor = UIColorFromRGB(0xc4c4c4);
    self.bedTypePickerDone.layer.cornerRadius = 4.0f;
    self.bedTypePickerDone.layer.masksToBounds = NO;
    self.bedTypePickerDone.layer.borderWidth = 0.8f;
    self.bedTypePickerDone.layer.borderColor = UIColorFromRGB(0xb5b5b5).CGColor;
    
    self.bedTypePickerDone.layer.shadowColor = [UIColor blackColor].CGColor;
    self.bedTypePickerDone.layer.shadowOpacity = 0.8;
    self.bedTypePickerDone.layer.shadowRadius = 1;
    self.bedTypePickerDone.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    
    [self.bedTypePickerDone setTitle:@"Done" forState:UIControlStateNormal];
    self.bedTypePickerDone.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [self.bedTypePickerDone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.bedTypePickerDone addTarget:self action:@selector(tdBedTypeDone:) forControlEvents:UIControlEventTouchDown];
    [self.bedTypePickerDone addTarget:self action:@selector(tuiBedTypeDone:) forControlEvents:UIControlEventTouchUpInside];
    [self.bedTypePickerDone addTarget:self action:@selector(tuoBedTypeDone:) forControlEvents:UIControlEventTouchUpOutside];
    [self.bedTypePickerContainer addSubview:self.bedTypePickerDone];
}

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
    NSInteger savedExpMonth = [[PaymentDetails card1].expirationMonth integerValue];
    if (savedExpMonth > 0 && savedExpMonth < 13) {
        [self.expirationPicker selectRow:savedExpMonth inComponent:0 animated:NO];
    } else {
        [self.expirationPicker selectRow:0 inComponent:0 animated:NO];
    }
    
    NSInteger savedExpYear = [[PaymentDetails card1].expirationYear integerValue];
    NSInteger layerCake = savedExpYear - [components year];
    if (layerCake >= 0 && layerCake < 1000) {
        [self.expirationPicker selectRow:(savedExpYear - [components year] + 1) inComponent:1 animated:NO];
    } else {
        [self.expirationPicker selectRow:0 inComponent:1 animated:NO];
    }
}

- (void)updateTextInExpirationOutlet {
    NSString *ms = [self pickerView:self.expirationPicker titleForRow:[self.expirationPicker selectedRowInComponent:0] forComponent:0];
    ms = [ms componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]][0];
    NSString *ys = [self pickerView:self.expirationPicker titleForRow:[self.expirationPicker selectedRowInComponent:1] forComponent:1];
    
    if (nil == ms || nil == ys) {
        self.expirationOutlet.text = nil;
    } else {
        self.expirationOutlet.text = [NSString stringWithFormat:@"%@ %@", ms, ys];
    }
    
    [self validateExpiration];
}

#pragma mark UIPickerViewDataSource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (1 == component) {
        return 1000;
    } else {
        return 13;
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
        if (row == 0) {
            return nil;
        }
        
        return [NSString stringWithFormat:@"%ld", (long)([components year] + row - 1)];
    } else {
        if (row == 0) {
            return nil;
        }
        
        NSDate *wd = [dateFormatter dateFromString:[NSString stringWithFormat: @"%ld", (long)(row)]];
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

#pragma mark SelectBedTypeDelegate method

- (void)didSelectBedType:(EanBedType *)eanBedType {
    EanAvailabilityHotelRoomResponse *room = [self.tableData objectAtIndex:self.expandedIndexPath.row];
    room.selectedBedType = eanBedType;
    [self.bedTypeButton setTitle:eanBedType.bedTypeDescription forState:UIControlStateNormal];
}

#pragma mark SelectSmokingPreferenceDelegate method

- (void)didSelectSmokingPref:(NSString *)eanSmokeCode {
    EanAvailabilityHotelRoomResponse *room = [self.tableData objectAtIndex:self.expandedIndexPath.row];
    room.selectedSmokingPreference = eanSmokeCode;
    [self.smokingButton setTitle:[SelectSmokingPreferenceDelegateImplementation smokingPrefStringForEanSmokeCode:eanSmokeCode] forState:UIControlStateNormal];
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
    
    UIBarButtonItem *lbbi = [[UIBarButtonItem alloc] initWithTitle:@"Different Room" style:UIBarButtonItemStyleDone target:self action:@selector(dropRoomDetailsView:)];
    [self.navigationItem setLeftBarButtonItem:lbbi animated:YES];
    
    self.bedTypeButton.alpha = self.smokingButton.alpha/* = self.doneButton.alpha*/ = 0.0f;
    self.bedTypeButton.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0.0f, -(tvp.frame.size.height/0.55)), 0.001f, 0.001f);
    self.smokingButton.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0.0f, -(tvp.frame.size.height/0.55f)), 0.001f, 0.001f);
//    self.doneButton.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0.0f, -(tvp.frame.size.height/0.55f)), 0.001f, 0.001f);
    [UIView animateWithDuration:kAnimationDuration animations:^{
        tvp.frame = CGRectMake(0.0f, 64.0f, 320.0f, 300.0f);
        cv.frame = tvp.bounds;
        borderView.frame = CGRectMake(2.0f, 2.0f, cv.frame.size.width - 4.0f, cv.frame.size.height - 4.0f);
        rtv.transform = CGAffineTransformMakeScale(0.01, 0.01);
        ibo.transform = [weakSelf shownGuestInputTransform];
        weakSelf.bedTypeButton.alpha = weakSelf.smokingButton.alpha/* = weakSelf.doneButton.alpha*/ = 1.0f;
        weakSelf.bedTypeButton.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, 0), 1.0f, 1.0f);
        weakSelf.smokingButton.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, 0), 1.0f, 1.0f);
//        weakSelf.doneButton.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, 0), 1.0f, 1.0f);
    } completion:^(BOOL finished) {
        rtv.hidden = YES;
    }];
}

- (void)dropRoomDetailsView:(id)sender {
    __weak typeof(self) weakSelf = self;
//    __weak UIView *tvp = self.doneButton.superview;
    __weak UIView *tvp = self.bedTypeButton.superview;
    __weak UIView *cv = [tvp viewWithTag:kAvailRoomCellContViewTag];
    __weak UIView *borderView = [cv viewWithTag:kAvailRoomBorderViewTag];
    __weak UIView *rtv = self.roomsTableViewOutlet;
    __weak UIView *ibo = self.inputBookOutlet;
    self.expandedIndexPath = nil;
    
    rtv.hidden = NO;
    [self tuiBedTypeDone:nil];
    [self.navigationItem setLeftBarButtonItem:self.navigationItem.backBarButtonItem animated:YES];
    [UIView animateWithDuration:kAnimationDuration animations:^{
        weakSelf.bedTypeButton.alpha = weakSelf.smokingButton.alpha/* = weakSelf.doneButton.alpha*/ = 0.0f;
        weakSelf.bedTypeButton.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0.0f, -(tvp.frame.size.height/1.5f)), 0.001f, 0.001f);
        weakSelf.smokingButton.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0.0f, -(tvp.frame.size.height/1.5f)), 0.001f, 0.001f);
//        weakSelf.doneButton.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0.0f, -(tvp.frame.size.height/1.5f)), 0.001f, 0.001f);
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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Different Room" style:UIBarButtonItemStyleDone target:self action:@selector(dropRoomDetailsView:)];
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
    
    PaymentDetails *pd = [PaymentDetails card1];
    
    self.ccNumberOutlet.showsCardLogo = YES;
    self.ccNumberOutlet.cardNumber = pd.cardNumber;
    
    self.selectedBillingAddress = pd.billingAddress;
    self.addressTextFieldOutlet.text = self.selectedBillingAddress.formattedAddress;
    
    [self updateTextInExpirationOutlet];
    
    if (nil != pd.cardHolderFirstName && nil != pd.cardHolderLastName) {
        self.cardholderOutlet.text = [NSString stringWithFormat:@"%@ %@", pd.cardHolderFirstName, pd.cardHolderLastName];
    }
    
    [self validateCreditCardNumber:self.ccNumberOutlet.cardNumber];
    [self validateBillingAddressWithNoGoColor:NO];
    [self validateCardholder:self.cardholderOutlet.text];
    
    if ([self isWeGood]) {
        self.deleteCardOutlet.hidden = NO;
        [self.deleteCardOutlet addTarget:self action:@selector(initiateDeleteCard:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    __weak typeof(self) wes = self;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        paymentDetailsView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        [wes.ccNumberOutlet becomeFirstResponder];
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)dropPaymentDetailsView:(id)sender {
    [self.view endEditing:YES];
    PaymentDetails *pd = [PaymentDetails card1];
    
    if (sender == self.navigationItem.rightBarButtonItem) {
        pd.cardNumber = self.ccNumberOutlet.cardNumber;
        pd.eanCardType = self.ccNumberOutlet.eanType;
        pd.billingAddress = self.selectedBillingAddress;
        [self saveDaExpiration];
        
        NSArray *chn = [self.cardholderOutlet.text componentsSeparatedByString:@" "];
        if ([chn count] >= 2) {
            pd.cardHolderFirstName = [self.cardholderOutlet.text componentsSeparatedByString:@" "][0];
            pd.cardHolderLastName = [self.cardholderOutlet.text componentsSeparatedByString:@" "][1];
        }
    }
    
    if (sender == self.deleteCardOutlet) {
        self.ccNumberOutlet.cardNumber = nil;
        self.selectedBillingAddress = nil;
        [self.expirationPicker selectRow:0 inComponent:0 animated:NO];
        [self.expirationPicker selectRow:0 inComponent:1 animated:NO];
        self.expirationOutlet.text = nil;
        self.cardholderOutlet.text = nil;
        [PaymentDetails deleteCard:pd];
    }
    
    [self dropGooglePlacesTableView];
    
    __weak UIView *paymentDetailsView = [self.view viewWithTag:kPaymentDetailsViewTag];
    
    CGPoint pboCenter = [self.view convertPoint:self.paymentButtonOutlet.center fromView:self.inputBookOutlet];
    CGFloat toX = pboCenter.x - paymentDetailsView.center.x;
    CGFloat toY = pboCenter.y - paymentDetailsView.center.y;
    __block CGAffineTransform toTransform = CGAffineTransformMakeTranslation(toX, toY);
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Different Room" style:UIBarButtonItemStyleDone target:self action:@selector(dropRoomDetailsView:)];
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

- (void)enableOrDisableRightBarButtonItem {
    if ([self isWeGood]) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (BOOL)isWeGood {
    return self.isValidCreditCard && self.isValidBillingAddress && self.isValidExpiration && self.isValidCardHolder;
}

- (void)validateCreditCardNumber:(NSString *)cardNumber {
    if ([[PTKCardNumber cardNumberWithString:cardNumber] isValid]) {
        self.ccNumberOutlet.backgroundColor = kColorGoodToGo();
        self.isValidCreditCard = YES;
    } else {
        self.ccNumberOutlet.backgroundColor = [UIColor whiteColor];
        self.isValidCreditCard = NO;
    }
    
    [self enableOrDisableRightBarButtonItem];
}

- (void)validateBillingAddressWithNoGoColor:(BOOL)withNoGoColor {
    ADDRESS_VALIDITY_REASONS avr = [self.selectedBillingAddress isValidToSubmitToEanApiAsBillingAddress];
    
    switch (avr) {
        case VALID_ADDRESS: {
            self.addressTextFieldOutlet.backgroundColor = kColorGoodToGo();
            self.isValidBillingAddress = YES;
            break;
        }
        default: {
            if (withNoGoColor) {
                self.addressTextFieldOutlet.backgroundColor = kColorNoGo();
            } else {
                self.addressTextFieldOutlet.backgroundColor = [UIColor whiteColor];
            }
            self.isValidBillingAddress = NO;
            break;
        }
    }
    
    [self enableOrDisableRightBarButtonItem];
}

- (void)validateExpiration {
    if (nil == self.expirationOutlet.text || 0 == [self.expirationOutlet.text length]
            || [self.expirationOutlet.text isEqualToString:@""]) {
        self.expirationOutlet.backgroundColor = [UIColor whiteColor];
        self.isValidExpiration = NO;
        [self enableOrDisableRightBarButtonItem];
        return;
    }
    
    NSArray *expArr = [self.expirationOutlet.text componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    
    if (nil == expArr || [expArr count] != 2) {
        self.expirationOutlet.backgroundColor = kColorNoGo();
        self.isValidExpiration = NO;
        [self enableOrDisableRightBarButtonItem];
        return;
    }
    
    NSString *expMonth = expArr[0];
    NSString *expYear = expArr[1];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM"];
    NSDate *daDate = [dateFormatter dateFromString:expMonth];
    NSString *nExpMonth = [dateFormatter stringFromDate:daDate];
    
    NSInteger intExpMonth = [nExpMonth integerValue];
    NSInteger intExpYear = [expYear integerValue];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth|NSCalendarUnitYear fromDate:[NSDate date]];
    
    if (intExpMonth <= 0 || intExpMonth >= 13 || intExpYear < [components year]) {
        self.expirationOutlet.backgroundColor = kColorNoGo();
        self.isValidExpiration = NO;
    } else if (intExpYear > [components year]) {
        self.expirationOutlet.backgroundColor = kColorGoodToGo();
        self.isValidExpiration = YES;
    } else if (intExpMonth >= [components month]) {
        self.expirationOutlet.backgroundColor = kColorGoodToGo();
        self.isValidExpiration = YES;
    } else {
        self.expirationOutlet.backgroundColor = kColorNoGo();
        self.isValidExpiration = NO;
    }
    
    [self enableOrDisableRightBarButtonItem];
}

- (void)validateCardholder:(NSString *)cardHolder {
    NSArray *ch = [cardHolder componentsSeparatedByString:@" "];
    if ([ch count] != 2 || [ch[1] length] < 2) {
        self.cardholderOutlet.backgroundColor = [UIColor whiteColor];
        self.isValidCardHolder = NO;
    } else {
        self.cardholderOutlet.backgroundColor = kColorGoodToGo();
        self.isValidCardHolder = YES;
    }
    
    [self enableOrDisableRightBarButtonItem];
}

#pragma mark Card Deletion Selectors

- (void)initiateDeleteCard:(id)sender {
    self.ccNumberOutlet.userInteractionEnabled = NO;
    self.addressTextFieldOutlet.userInteractionEnabled = NO;
    self.expirationOutlet.userInteractionEnabled = NO;
    self.cardholderOutlet.userInteractionEnabled = NO;
    
    self.cancelDeletionOutlet.transform = CGAffineTransformMakeTranslation(300, 0);
    self.cancelDeletionOutlet.hidden = NO;
    [self.cancelDeletionOutlet addTarget:self action:@selector(cancelDeleteCard:) forControlEvents:UIControlEventTouchUpInside];
    
    [UIView animateWithDuration:0.4f animations:^{
        self.cancelDeletionOutlet.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
        ;
    }];
    
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.ccNumberOutlet.cardLogoImageView.alpha = 0.2f;
    
    self.ccNumberOutlet.backgroundColor = [UIColor grayColor];
    self.addressTextFieldOutlet.backgroundColor = [UIColor grayColor];
    self.expirationOutlet.backgroundColor = [UIColor grayColor];
    self.cardholderOutlet.backgroundColor = [UIColor grayColor];
    
    self.ccNumberOutlet.textColor = [UIColor lightGrayColor];
    self.addressTextFieldOutlet.textColor = [UIColor lightGrayColor];
    self.expirationOutlet.textColor = [UIColor lightGrayColor];
    self.cardholderOutlet.textColor = [UIColor lightGrayColor];
    
    [self.deleteCardOutlet setTitle:@"Confirm Deletion" forState:UIControlStateNormal];
    [self.deleteCardOutlet removeTarget:self action:@selector(initiateDeleteCard:) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteCardOutlet addTarget:self action:@selector(dropPaymentDetailsView:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)cancelDeleteCard:(id)sender {
    self.ccNumberOutlet.userInteractionEnabled = YES;
    self.addressTextFieldOutlet.userInteractionEnabled = YES;
    self.expirationOutlet.userInteractionEnabled = YES;
    self.cardholderOutlet.userInteractionEnabled = YES;
    
    [UIView animateWithDuration:0.4f animations:^{
        self.cancelDeletionOutlet.transform = CGAffineTransformMakeTranslation(300, 0);
    } completion:^(BOOL finished) {
        self.cancelDeletionOutlet.hidden = YES;
    }];
    
    self.navigationItem.leftBarButtonItem.enabled = YES;
    
    [self validateCreditCardNumber:self.ccNumberOutlet.cardNumber];
    [self validateBillingAddressWithNoGoColor:NO];
    [self validateExpiration];
    [self validateCardholder:self.cardholderOutlet.text];
    
    self.ccNumberOutlet.cardLogoImageView.alpha = 1.0f;
    
    self.ccNumberOutlet.textColor = [UIColor blackColor];
    self.addressTextFieldOutlet.textColor = [UIColor blackColor];
    self.expirationOutlet.textColor = [UIColor blackColor];
    self.cardholderOutlet.textColor = [UIColor blackColor];
    
    self.deleteCardOutlet.hidden = NO;
    [self.deleteCardOutlet setTitle:@"Delete This Card" forState:UIControlStateNormal];
    [self.deleteCardOutlet removeTarget:self action:@selector(dropPaymentDetailsView:) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteCardOutlet addTarget:self action:@selector(initiateDeleteCard:) forControlEvents:UIControlEventTouchUpInside];
}

@end
