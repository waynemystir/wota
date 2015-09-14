//
//  SelectRoomViewController.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/28/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
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
#import "AppDelegate.h"
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
#import <SDWebImage/UIImageView+WebCache.h>
#import "WotaTappableView.h"
#import "NightlyRateTableViewDelegateImplementation.h"
#import "NavigationView.h"
#import "CountryPicker.h"
#import "StatePickerView.h"
#import "NetworkProblemResponder.h"
#import "PreBookConfirmView.h"

NSUInteger const kLoadDropRoomDetailsAnimationCurve = UIViewAnimationOptionCurveEaseInOut;
NSTimeInterval const kSrAnimationDuration = 0.58;
NSTimeInterval const kSrQuickAnimationDuration = 0.36;

typedef NS_ENUM(NSUInteger, VIEW_DETAILS_TYPE) {
    GUEST_DETAILS,
    PAYMENT_DETAILS,
    PREBOOK_CONFIRM
};

NSUInteger const kGuestDetailsViewTag = 51;
NSUInteger const kPaymentDetailsViewTag = 52;
NSUInteger const kAvailRoomCellContViewTag = 19191;
NSUInteger const kAvailRoomBorderViewTag = 13;
NSUInteger const kNightlyRateViewTag = 19;
NSUInteger const kRoomImageViewTag = 171717;
NSUInteger const kImageViewBottomCoverTag = 1717171;
NSUInteger const kPriceGradientCoverTag = 171718;
NSUInteger const kRoomTypeDescViewTag = 171719;
NSUInteger const kRoomValueAddTag = 1717199;
NSUInteger const kRoomRateViewTag = 171720;
NSUInteger const kRoomPerNightTag = 171721;
NSUInteger const kRoomNonRefundViewTag = 171722;
NSUInteger const kRoomBedTypeButtonTag = 171723;
NSUInteger const kRoomSmokingButtonTag = 171724;
NSUInteger const kRoomTypeDescrLongTag = 171725;
NSUInteger const kRoomTotalViewTag = 171726;
NSUInteger const kRoomTotalAmountTag = 171727;
NSUInteger const kBottomGradientCoverTag = 171728;
NSUInteger const kRoomNonRefundLongTag = 171729;
NSUInteger const kPriceDetailsPopupTag = 171730;
NSUInteger const kInfoDetailPopupRoomDetailsTag = 171731;
NSUInteger const kInfoDetailPopupCancelPolicTag = 171732;
NSUInteger const kInfoDetailPopupGuestDetailTag = 171733;
NSUInteger const kInfoDetailPopupPaymeDetailTag = 171734;
NSUInteger const kInfoDetailPopupValueAddDetTag = 1717344;
NSUInteger const kWhyThisInfoTag = 171735;
NSUInteger const kCardSecurityTag = 171736;
NSUInteger const kPickerContainerDoneButton = 171737;
NSUInteger const kFlagViewTag = 51974123;
NSUInteger const kCVVViewTag = 171738;
NSUInteger const kCVVOverlayTag = 171739;
NSUInteger const kPromoLabelTag = 171740;
NSUInteger const kPickerContainerDisclaimer = 171741;

@interface SelectRoomViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, SelectBedTypeDelegate, SelectSmokingPrefDelegate, NavigationDelegate, CountryPickerDelegate, StatePickerDelegate, PreBookConfirmDelegate>

@property (nonatomic) VIEW_DETAILS_TYPE view_details_type;

@property (nonatomic, strong) PaymentDetails *paymentDetails;

@property (nonatomic) BOOL preparedToDropSpinner;
@property (nonatomic) BOOL alreadyDroppedSpinner;
@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, strong) NSString *hotelName;
@property (nonatomic, strong) NSString *locationString;
@property (weak, nonatomic) IBOutlet UITableView *roomsTableViewOutlet;
@property (weak, nonatomic) IBOutlet UIView *inputBookOutlet;
@property (weak, nonatomic) IBOutlet UIButton *bookButtonOutlet;
@property (weak, nonatomic) IBOutlet WotaTappableView *guestButtonOutlet;
@property (weak, nonatomic) IBOutlet WotaTappableView *paymentButtonOutlet;

@property (weak, nonatomic) IBOutlet UITextField *firstNameOutlet;
@property (weak, nonatomic) IBOutlet UITextField *lastNameOutlet;
@property (weak, nonatomic) IBOutlet UITextField *emailOutlet;
@property (weak, nonatomic) IBOutlet UITextField *confirmEmailOutlet;
@property (weak, nonatomic) IBOutlet UITextField *phoneCountryContainer;
@property (weak, nonatomic) IBOutlet UITextField *phoneOutlet;
@property (weak, nonatomic) IBOutlet UIView *belowEmailContainerOutlet;
@property (weak, nonatomic) IBOutlet WotaButton *deleteUserOutlet;
@property (weak, nonatomic) IBOutlet WotaButton *cancelUserDeletionOutlet;

@property (weak, nonatomic) IBOutlet WotaCardNumberField *ccNumberOutlet;
@property (weak, nonatomic) IBOutlet UITextField *addressTextFieldOutlet;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *countryTextField;
@property (weak, nonatomic) IBOutlet UITextField *stateTextField;
@property (weak, nonatomic) IBOutlet UITextField *postalTextField;
@property (weak, nonatomic) IBOutlet UITextField *expirationOutlet;
@property (weak, nonatomic) IBOutlet UITextField *cardholderFirstOutlet;
@property (weak, nonatomic) IBOutlet UITextField *cardholderLastOutlet;
@property (nonatomic, strong) UIView *expirationInputView;
@property (nonatomic, strong) UIPickerView *expirationPicker;
@property (nonatomic, strong) UIButton *expirationNext;
@property (weak, nonatomic) IBOutlet UIView *ccContainerOutlet;

@property (nonatomic, strong) UIView *guestDetailsView;
@property (nonatomic, strong) UIView *paymentDetailsView;

@property (nonatomic, strong) EanHotelRoomAvailabilityResponse *eanHrar;
@property (nonatomic, strong) EanAvailabilityHotelRoomResponse *selectedRoom;
@property (nonatomic, strong) NSArray *tableData;
@property (nonatomic, strong) NSIndexPath *expandedIndexPath;
@property (nonatomic) CGRect rectOfCellInSuperview;
@property (nonatomic) CGRect rectOfAvailRoomContView;
@property (nonatomic, strong) WotaButton *bedTypeButton;
@property (nonatomic, strong) WotaButton *smokingButton;
@property (nonatomic, strong) UIView *pickerViewContainer;
@property (nonatomic, strong) UIButton *pickerViewDoneButton;
@property (nonatomic, strong) UILabel *pickerViewDisclaimerLabel;
@property (nonatomic, strong) UIPickerView *bedTypePickerView;
@property (nonatomic, strong) SelectBedTypeDelegateImplementation *bedTypePickerDelegate;
@property (nonatomic) BOOL isPickerContainerShowing;
@property (nonatomic, strong) UIPickerView *smokingPrefPickerView;
@property (nonatomic, strong) SelectSmokingPreferenceDelegateImplementation *smokePrefDelegImplem;
@property (nonatomic, strong) UIView *overlayDisable;
@property (nonatomic, strong) UIView *overlayDisableNav;
@property (nonatomic, strong) CountryPicker *countryPicker;
@property (nonatomic, strong) UIView *countryPickerContainer;
@property (nonatomic, strong) UIButton *countryPickerNextBtn;
@property (nonatomic, strong) NSString *selectedInternationalCallingCountryCode;
@property (nonatomic, strong) StatePickerView *statePicker;
@property (nonatomic, strong) UIView *statePickerContainer;
@property (nonatomic, strong) UIButton *statePickerNextBtn;

@property (nonatomic) BOOL isValidFirstName;
@property (nonatomic) BOOL isValidLastName;
@property (nonatomic) BOOL isValidEmail;
@property (nonatomic) BOOL isValidConfirmEmail;
@property (nonatomic) BOOL isValidPhone;

@property (nonatomic) BOOL isValidCreditCard;
@property (nonatomic, readonly) BOOL isValidBillingAddress;
@property (nonatomic) BOOL isValidStreetAddress;
@property (nonatomic) BOOL isValidCity;
@property (nonatomic) BOOL isValidState;
@property (nonatomic) BOOL isValidPostalCode;
@property (nonatomic) BOOL isValidExpiration;
@property (nonatomic) BOOL isValidCardHolderFirst;
@property (nonatomic) BOOL isValidCardHolderLast;

@property (nonatomic, strong) NSArray *bottomGradientColors;
@property (nonatomic, strong) NSArray *bottomsUpGradientColors;
@property (nonatomic, strong) NSArray *priceGradientColors;
@property (nonatomic, strong) UIView *tableViewPopOut;

@property (nonatomic, strong) NSDictionary *infoPopupTagDict;
@property (nonatomic, strong) NSDictionary *infoPopupHeadingDict;
@property (nonatomic, strong) UIView *currentFirstResponder;

@property (nonatomic, strong) NightlyRateTableViewDelegateImplementation *nrtvd;

@property (nonatomic, strong) PreBookConfirmView *preBookConfirmView;
@property (weak, nonatomic) IBOutlet UITextField *cvvTextField;
@property (weak, nonatomic) IBOutlet WotaButton *purchaseButton;
@property (weak, nonatomic) IBOutlet WotaButton *cancelPurchaseButton;

@property (nonatomic, strong) NSTimer *selectRoomLifeTimer;

- (IBAction)justPushIt:(id)sender;

@end

@implementation SelectRoomViewController

- (id)init {
    if (self = [super initWithNibName:@"SelectRoomView" bundle:nil]) {
        _bottomGradientColors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:1 alpha:0].CGColor, (id)[UIColor colorWithWhite:1 alpha:0].CGColor, (id)[UIColor colorWithWhite:1 alpha:0].CGColor, (id)[UIColor colorWithWhite:1 alpha:0].CGColor, (id)[UIColor colorWithWhite:1 alpha:1].CGColor, nil];
        _bottomsUpGradientColors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:1 alpha:0].CGColor, (id)[UIColor colorWithWhite:1 alpha:0].CGColor, (id)[UIColor colorWithWhite:1 alpha:0.1f].CGColor, (id)[UIColor colorWithWhite:1 alpha:0.2].CGColor, (id)[UIColor colorWithWhite:1 alpha:0.3f].CGColor, (id)[UIColor colorWithWhite:1 alpha:0.4f].CGColor, (id)[UIColor colorWithWhite:1 alpha:0.5f].CGColor, (id)[UIColor colorWithWhite:1 alpha:0.6f].CGColor, (id)[UIColor colorWithWhite:1 alpha:0.7f].CGColor, (id)[UIColor colorWithWhite:1 alpha:0.8f].CGColor, (id)[UIColor colorWithWhite:1 alpha:0.9f].CGColor, (id)[UIColor colorWithWhite:1 alpha:1.0f].CGColor, nil];
        _priceGradientColors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:1 alpha:0].CGColor, (id)[UIColor colorWithWhite:1 alpha:0].CGColor, (id)[UIColor colorWithWhite:1 alpha:0].CGColor, (id)[UIColor colorWithWhite:1 alpha:0].CGColor, (id)[UIColor colorWithWhite:1 alpha:0].CGColor, (id)[UIColor colorWithWhite:1 alpha:0].CGColor, (id)[UIColor colorWithWhite:1 alpha:0].CGColor, (id)[UIColor colorWithWhite:1 alpha:0].CGColor, (id)[UIColor colorWithWhite:1 alpha:0].CGColor, (id)[UIColor colorWithWhite:1 alpha:0].CGColor, (id)[UIColor colorWithWhite:1 alpha:0].CGColor, (id)[UIColor colorWithWhite:1 alpha:0].CGColor, (id)[UIColor colorWithWhite:1 alpha:0].CGColor, (id)[UIColor colorWithWhite:1 alpha:0].CGColor, (id)[UIColor colorWithWhite:1 alpha:0.1f].CGColor, (id)[UIColor colorWithWhite:1 alpha:0.2].CGColor, (id)[UIColor colorWithWhite:1 alpha:0.3f].CGColor, (id)[UIColor colorWithWhite:1 alpha:0.4f].CGColor, (id)[UIColor colorWithWhite:1 alpha:0.5f].CGColor, (id)[UIColor colorWithWhite:1 alpha:0.6f].CGColor, (id)[UIColor colorWithWhite:1 alpha:0.7f].CGColor, (id)[UIColor colorWithWhite:1 alpha:0.8f].CGColor, (id)[UIColor colorWithWhite:1 alpha:0.9f].CGColor, (id)[UIColor colorWithWhite:1 alpha:1.0f].CGColor, nil];
        
        NSMutableDictionary *mutInfoPopupDict = [NSMutableDictionary dictionary];
        [mutInfoPopupDict setObject:@(kInfoDetailPopupRoomDetailsTag) forKey:@(kRoomTypeDescrLongTag)];
        [mutInfoPopupDict setObject:@(kInfoDetailPopupCancelPolicTag) forKey:@(kRoomNonRefundLongTag)];
        [mutInfoPopupDict setObject:@(kInfoDetailPopupGuestDetailTag) forKey:@(kWhyThisInfoTag)];
        [mutInfoPopupDict setObject:@(kInfoDetailPopupPaymeDetailTag) forKey:@(kCardSecurityTag)];
        [mutInfoPopupDict setObject:@(kInfoDetailPopupValueAddDetTag) forKey:@(kRoomValueAddTag)];
        _infoPopupTagDict = [NSDictionary dictionaryWithDictionary:mutInfoPopupDict];
        
        NSMutableDictionary *mutInfoPopupHeadingDict = [NSMutableDictionary dictionary];
        [mutInfoPopupHeadingDict setObject:@"Room Details" forKey:@(kRoomTypeDescrLongTag)];
        [mutInfoPopupHeadingDict setObject:@"Cancellation Policy" forKey:@(kRoomNonRefundLongTag)];
        [mutInfoPopupHeadingDict setObject:@"Guest Information" forKey:@(kWhyThisInfoTag)];
        [mutInfoPopupHeadingDict setObject:@"Payment Information" forKey:@(kCardSecurityTag)];
        [mutInfoPopupHeadingDict setObject:@"Complimentary" forKey:@(kRoomValueAddTag)];
        _infoPopupHeadingDict = [NSDictionary dictionaryWithDictionary:mutInfoPopupHeadingDict];
        
        _selectRoomLifeTimer = [NSTimer timerWithTimeInterval:(60 * 20) target:self selector:@selector(removeThisControllerFromNavigationStack:) userInfo:nil repeats:NO];
        
        [[NSRunLoop currentRunLoop] addTimer:_selectRoomLifeTimer forMode:NSDefaultRunLoopMode];
    }
    return self;
}

- (void)removeThisControllerFromNavigationStack:(id)sender {
    if (self == self.navigationController.visibleViewController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        NSMutableArray *controllers = [self.navigationController.viewControllers mutableCopy];
        [controllers removeObject:self];
        self.navigationController.viewControllers = [NSArray arrayWithArray:controllers];
    }
}

- (void)didReceiveMemoryWarning {
    NSLog(@"%@:didReceiveMemoryWarning", self.class);
}

- (void)dealloc {
    if ([_selectRoomLifeTimer isValid]) {
        [_selectRoomLifeTimer invalidate];
        _selectRoomLifeTimer = nil;
    }
}

- (id)initWithPlaceholderImage:(UIImage *)placeholderImage
                     hotelName:(NSString *)hotelName
                  locationName:(NSString *)locationName {
    if (self = [self init]) {
        _placeholderImage = placeholderImage;
        _hotelName = hotelName;
        _locationString = locationName;
    }
    
    return self;
}

- (void)loadView {
    [super loadView];
    NavigationView *nv = [[NavigationView alloc] initWithDelegate:self];
    nv.animationDuration = kSrAnimationDuration;
    [self.view addSubview:nv];
    [self.view bringSubviewToFront:nv];
    nv.whereToLabel.text = self.hotelName;
    
    [self loadDaSpinner];
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
    
    [self initializeTheTableViewPopOut];
    [self setupExpirationPicker];
    [self setupCountryPicker];
    [self setupStatePicker];
    [self setupPickerViewContainer];
    self.overlayDisable = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    self.overlayDisable.backgroundColor = [UIColor blackColor];
    self.overlayDisable.alpha = 0.8f;
    self.overlayDisable.userInteractionEnabled = YES;
    self.overlayDisableNav = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
    self.overlayDisable.backgroundColor = [UIColor blackColor];
    self.overlayDisable.alpha = 0.95f;
    self.overlayDisable.userInteractionEnabled = YES;
    
    self.inputBookOutlet.hidden = YES;
//    self.inputBookOutlet.frame = CGRectMake(10.0f, 412.0f, 300.0f, 0.0f);
    self.inputBookOutlet.transform = [self hiddenGuestInputTransform];
//    self.inputBookOutlet.layer.cornerRadius = WOTA_CORNER_RADIUS;
//    self.inputBookOutlet.layer.borderWidth = 1.0f;
//    self.inputBookOutlet.layer.borderColor = [UIColor blackColor].CGColor;
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
//    self.guestButtonOutlet.titleLabel.adjustsFontSizeToFitWidth = YES;
//    self.guestButtonOutlet.titleLabel.numberOfLines = 1;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(loadGuestDetailsView)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    tap.cancelsTouchesInView = NO;
    [self.guestButtonOutlet addGestureRecognizer:tap];
    [self updateGuestDetailsButtonTitle];
    
    UITapGestureRecognizer *tapPay = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadPaymentDetailsView)];
    tapPay.numberOfTapsRequired = 1;
    tapPay.numberOfTouchesRequired = 1;
    tapPay.cancelsTouchesInView = NO;
    [self.paymentButtonOutlet addGestureRecognizer:tapPay];
    [self updatePaymentDetailsButtonTitle];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)updatePaymentDetailsButtonTitle {
    PaymentDetails *pd = self.paymentDetails;
    UILabel *pdLabel = (UILabel *) [self.paymentButtonOutlet viewWithTag:271493618];
    UIImageView *cdLabel = (UIImageView *) [self.paymentButtonOutlet viewWithTag:582948375];
    if ([pd.cardNumber length] > 0) {
        cdLabel.hidden = NO;
//        cdLabel.text = [@"Card\n" stringByAppendingString:pd.lastFour];
        cdLabel.image = pd.cardImage;
        pdLabel.hidden = YES;
    } else {
        cdLabel.hidden = YES;
//        cdLabel.text = @"";
        cdLabel.image = nil;
        pdLabel.hidden = NO;
        pdLabel.text = @"Payment Details";
    }
}

- (void)updateGuestDetailsButtonTitle {
    GuestInfo *gi = [GuestInfo singleton];
    UILabel *gdLabel = (UILabel *) [self.guestButtonOutlet viewWithTag:91917314];
    UILabel *fnLabel = (UILabel *) [self.guestButtonOutlet viewWithTag:901572957];
    UILabel *lnLabel = (UILabel *) [self.guestButtonOutlet viewWithTag:4206971046];
    if (([gi.firstName length] > 0) && ([gi.lastName length] > 0)) {
        fnLabel.hidden = NO;
        fnLabel.text = gi.firstName;
        lnLabel.hidden = NO;
        lnLabel.text = gi.lastName;
        gdLabel.hidden = YES;
    } else {
        fnLabel.hidden = YES;
        lnLabel.hidden = YES;
        fnLabel.text = @"";
        lnLabel.text = @"";
        gdLabel.hidden = NO;
        gdLabel.text = @"Guest Details";
    }
}

//- (void)keyboardWillShow:(id)sender {
//    [self dropGooglePlacesTableView];
//}

#pragma mark NavigationDelegate methods

- (void)clickBack {
    _preparedToDropSpinner = YES;
    [self dropDaSpinner];
    if ([_selectRoomLifeTimer isValid]) {
        [_selectRoomLifeTimer invalidate];
        _selectRoomLifeTimer = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickCancel {
    [self dropRoomDetailsView:nil];
}

- (void)clickSecondCancel {
    switch (_view_details_type) {
        case GUEST_DETAILS: {
            [self dropGuestDetailsView:nil];
            break;
        }
        case PAYMENT_DETAILS: {
            [self dropPaymentDetailsView:nil];
            break;
        }
        case PREBOOK_CONFIRM: {
            [self dropBookConfirmView];
            break;
        }
        default:
            break;
    }
}

- (void)clickRight {
    switch (_view_details_type) {
        case GUEST_DETAILS: {
            [self dropGuestDetailsView:@"FromRightNav"];
            break;
        }
        case PAYMENT_DETAILS: {
            [self dropPaymentDetailsView:@"FromRightNav"];
            break;
        }
        default:
            break;
    }
}

- (void)clickTitle {
//    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark LoadDataProtocol methods

- (void)requestFinished:(NSData *)responseData dataType:(LOAD_DATA_TYPE)dataType {
    switch (dataType) {
        case LOAD_EAN_AVAILABLE_ROOMS: {
            _preparedToDropSpinner = YES;
            self.eanHrar = [EanHotelRoomAvailabilityResponse eanObjectFromApiResponseData:responseData];
            if (self.eanHrar.hotelRoomArray.count > 0) {
                self.tableData = self.eanHrar.hotelRoomArray;
                [self.roomsTableViewOutlet reloadData];
                NSArray *fa = [[NSBundle mainBundle] loadNibNamed:@"SelectRoomFooterView" owner:self options:nil];
                UIView *fv = fa.firstObject;
                NSArray *ia = [[NSBundle mainBundle] loadNibNamed:@"ImageDisclaimerView" owner:nil options:nil];
                UIView *iv = ia.firstObject;
                iv.frame = CGRectMake(0, 85, 320, 105);
                UIView *wes = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 210)];
                wes.backgroundColor = [UIColor clearColor];
                [wes addSubview:fv];
                [wes addSubview:iv];
                self.roomsTableViewOutlet.tableFooterView = wes;
            } else {
                UILabel *noRooms = [[UILabel alloc] initWithFrame:CGRectMake(30, 200, 260, 200)];
                noRooms.numberOfLines = 3;
                noRooms.lineBreakMode = NSLineBreakByWordWrapping;
                noRooms.textAlignment = NSTextAlignmentCenter;
                noRooms.text = @"No rooms available. Please change the dates or the number of guests and try again.";
                noRooms.textColor = [UIColor blackColor];
                noRooms.backgroundColor = [UIColor whiteColor];
                [self.view addSubview:noRooms];
                [self.view bringSubviewToFront:noRooms];
                self.roomsTableViewOutlet.tableFooterView = nil;
            }
            [self dropDaSpinner];
            break;
        }
            
        default:
            break;
    }
}

- (void)requestTimedOut:(LOAD_DATA_TYPE)dataType {
    __weak typeof(self) wes = self;
    if (wes.navigationController.visibleViewController == self) {
        _preparedToDropSpinner = YES;
        [self dropDaSpinner];
        [NetworkProblemResponder launchWithSuperView:self.view headerTitle:nil messageString:nil completionCallback:^{
            [wes.navigationController popViewControllerAnimated:YES];
        }];
    } else {
        UILabel *toh = [[UILabel alloc] initWithFrame:CGRectMake(30, 170, 260, 45)];
        toh.numberOfLines = 1;
        toh.textAlignment = NSTextAlignmentCenter;
        toh.text = @"Request Timed Out";
        toh.textColor = [UIColor blackColor];
        toh.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:toh];
        [self.view bringSubviewToFront:toh];
        
        UILabel *timeOut = [[UILabel alloc] initWithFrame:CGRectMake(30, 220, 260, 200)];
        timeOut.numberOfLines = 3;
        timeOut.lineBreakMode = NSLineBreakByWordWrapping;
        timeOut.textAlignment = NSTextAlignmentCenter;
        timeOut.text = @"We were unable to perform the request. Please check your connection and try again.";
        timeOut.textColor = [UIColor blackColor];
        timeOut.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:timeOut];
        [self.view bringSubviewToFront:timeOut];
    }
}

- (void)requestFailedOffline {
    [self dropDaSpinner];
    __weak typeof(self) wes = self;
    [NetworkProblemResponder launchWithSuperView:self.view headerTitle:@"Network Error" messageString:@"The network could not be reached. Please check your connection and try again." completionCallback:^{
        [wes.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)requestFailedCredentials {
    [NetworkProblemResponder launchWithSuperView:self.view headerTitle:@"System Error" messageString:@"Sorry for the inconvenience. We are experiencing a technical issue. Please try again shortly." completionCallback:^{
    }];
}

- (void)requestFailed {
    [NetworkProblemResponder launchWithSuperView:self.view headerTitle:@"An Error Occurred" messageString:@"Please try again." completionCallback:^{
    }];
}

#pragma mark Table View Data Source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSString *cellIdentifier = @"AvailableRoomCellIdentifier";
//    AvailableRoomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    
//    if (nil == cell) {
//        [tableView registerNib:[UINib nibWithNibName:@"AvailableRoomTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
//        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    }
    
    AvailableRoomTableViewCell *cell = [[NSBundle mainBundle] loadNibNamed:@"AvailableRoomTableViewCell" owner:nil options:nil].firstObject;
    
    // Set these so that the cell expansion and compression work well
    // Curtesy of http://stackoverflow.com/questions/10220565/expanding-uitableviewcell
    cell.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    cell.clipsToBounds = YES;
    
    cell.borderViewOutlet.layer.cornerRadius = WOTA_CORNER_RADIUS;
    cell.borderViewOutlet.layer.borderWidth = 1.0f;
    cell.borderViewOutlet.layer.borderColor = [UIColor blackColor].CGColor;
    cell.borderViewOutlet.layer.masksToBounds = YES;
    
    EanAvailabilityHotelRoomResponse *room = [self.tableData objectAtIndex:indexPath.row];
    
    cell.roomTypeDescriptionOutlet.text = room.roomType.roomTypeDescrition;
    if ([cell.roomTypeDescriptionOutlet.text length] > 32) {
        cell.roomTypeDescriptionOutlet.font = [UIFont boldSystemFontOfSize:18.0f];
    } else {
        cell.roomTypeDescriptionOutlet.font = [UIFont boldSystemFontOfSize:19.0f];
    }
    
    if (room.valueAddArray.count > 0) {
        cell.valueAddOutlet.hidden = NO;
    } else {
        cell.valueAddOutlet.hidden = YES;
    }
    
//    NSNumberFormatter *currencyStyle = kPriceRoundOffFormatter(room.rateInfo.currencyCode);
//    NSString *currency = [currencyStyle stringFromNumber:room.rateInfo.nightlyRateToPresent];
    NSNumberFormatter *currencyStyle = kPriceRoundOffFormatter(room.rateInfo.chargeableRateInfo.currencyCode);
    NSString *currency = [currencyStyle stringFromNumber:room.rateInfo.chargeableRateInfo.averageRate];
    
    cell.rateOutlet.text = currency;
    
    cell.perNightOutlet.text = room.rateInfo.chargeableRateInfo.nightlyRateTypeDescription;
    
    cell.nonrefundOutlet.clipsToBounds = YES;
    cell.nonrefundOutlet.layer.cornerRadius = WOTA_CORNER_RADIUS;
    cell.nonrefundOutlet.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.nonrefundOutlet.layer.borderWidth = 0.5f;
    cell.nonrefundOutlet.text = room.rateInfo.nonRefundableString;
    
//    [self addRoomImageGradient:cell.roomImageViewOutlet];
    [cell.roomImageViewOutlet setImageWithURL:[NSURL URLWithString:room.roomImage.imageUrl] placeholderImage:self.placeholderImage];
    
    NSString *discount = room.rateInfo.chargeableRateInfo.discountPercentString;
    if (room.rateInfo.promo && !stringIsEmpty(discount)) {
        UILabel *promoLabel = [[UILabel alloc] initWithFrame:CGRectMake(280, -6, 60, 27)];
        promoLabel.tag = 87326401;
        promoLabel.backgroundColor = kTheColorOfMoney();
        promoLabel.text = [NSString stringWithFormat:@"\n-%@", discount];
        promoLabel.textColor = [UIColor whiteColor];
        promoLabel.textAlignment = NSTextAlignmentCenter;
        promoLabel.font = [UIFont boldSystemFontOfSize:11.0f];
        promoLabel.numberOfLines = 2;
        promoLabel.transform = CGAffineTransformMakeRotation((M_PI * 45 / 180.0));
        [cell.contentView.subviews.firstObject addSubview:promoLabel];
    } else {
        UIView *w = [cell.contentView.subviews.firstObject viewWithTag:87326401];
        [w removeFromSuperview];
    }
    
    [self addPriceGradient:cell.priceGradientOutlet];
    [self addBottomGradient:cell.bottomGradientOutlet];
    
    return cell;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
    return 130.0f;
}

#pragma mark Various methods

- (UIView *)tableViewPopOut {
    _tableViewPopOut.frame = self.rectOfCellInSuperview;
    
    UIView *cv = [_tableViewPopOut viewWithTag:kAvailRoomCellContViewTag];
    cv.frame = CGRectMake(0, 0, 320, 129);
    
    EanAvailabilityHotelRoomResponse *room = [self.tableData objectAtIndex:self.expandedIndexPath.row];
    
    UIImageView *roomImageView = (UIImageView *) [_tableViewPopOut viewWithTag:kRoomImageViewTag];
    [roomImageView setImageWithURL:[NSURL URLWithString:room.roomImage.imageUrl] placeholderImage:self.placeholderImage];
    
    UILabel *rtd = (UILabel *) [_tableViewPopOut viewWithTag:kRoomTypeDescViewTag];
    rtd.text = room.roomType.roomTypeDescrition;
    if ([rtd.text length] > 32) {
        rtd.font = [UIFont boldSystemFontOfSize:18.0f];
    } else {
        rtd.font = [UIFont boldSystemFontOfSize:19.0f];
    }
    
    UIImageView *valueAdd = (UIImageView *) [_tableViewPopOut viewWithTag:kRoomValueAddTag];
    if (room.valueAddArray.count > 0) {
        valueAdd.hidden = NO;
    } else {
        valueAdd.hidden = YES;
    }
    
    UILabel *rateLabel = (UILabel *) [_tableViewPopOut viewWithTag:kRoomRateViewTag];
    NSNumberFormatter *currencyStyle = kPriceRoundOffFormatter(room.rateInfo.chargeableRateInfo.currencyCode);
    NSString *currency = [currencyStyle stringFromNumber:room.rateInfo.chargeableRateInfo.averageRate];
    rateLabel.text = currency;
    
    UIView *totalContainer = [_tableViewPopOut viewWithTag:kRoomTotalViewTag];
    
    UILabel *totalLabel = (UILabel *) [totalContainer viewWithTag:kRoomTotalAmountTag];
    NSNumberFormatter *twoDigit = kPriceTwoDigitFormatter(room.rateInfo.chargeableRateInfo.currencyCode);
    NSString *totalAmt = [twoDigit stringFromNumber:room.rateInfo.totalPlusHotelFees];
    totalLabel.text = totalAmt;
    
    UILabel *perNightLabel = (UILabel *) [_tableViewPopOut viewWithTag:kRoomPerNightTag];
    perNightLabel.text = room.rateInfo.chargeableRateInfo.nightlyRateTypeDescription;
    
    UILabel *nonrefundLabel = (UILabel *) [_tableViewPopOut viewWithTag:kRoomNonRefundViewTag];
    nonrefundLabel.text = room.rateInfo.nonRefundableString;
    
    UILabel *nonreundLongLabel = (UILabel *) [_tableViewPopOut viewWithTag:kRoomNonRefundLongTag];
    nonreundLongLabel.text = room.rateInfo.nonRefundableLongString;
    
    UILabel *rtdL = (UILabel *) [_tableViewPopOut viewWithTag:kRoomTypeDescrLongTag];
    rtdL.text = [NSString stringWithFormat:@"%@%@", room.roomType.descriptionLongStripped, self.eanHrar.checkInInstructionsStripped];
    
    UILabel *promoLabel = (UILabel *) [_tableViewPopOut viewWithTag:kPromoLabelTag];
    NSString *discount = room.rateInfo.chargeableRateInfo.discountPercentString;
    if (room.rateInfo.promo && !stringIsEmpty(discount)) {
        promoLabel.text = [NSString stringWithFormat:@"\n-%@", discount];
        promoLabel.hidden = NO;
    } else {
        promoLabel.text = @"";
        promoLabel.hidden = YES;
    }
    
    [self.bedTypeButton setTitle:room.selectedBedType.bedTypeDescription forState:UIControlStateNormal];
    [self.smokingButton setTitle:[SelectSmokingPreferenceDelegateImplementation smokingPrefStringForEanSmokeCode:room.selectedSmokingPreference] forState:UIControlStateNormal];
    
    return _tableViewPopOut;
}

- (void)initializeTheTableViewPopOut {
    UIView *tableViewPopout = [[UIView alloc] initWithFrame:self.rectOfCellInSuperview];
    tableViewPopout.backgroundColor = [UIColor whiteColor];
//    tableViewPopout.hidden = YES;
    tableViewPopout.clipsToBounds = YES;
    tableViewPopout.autoresizesSubviews = YES;
    [self.view addSubview:tableViewPopout];
    
    UIView *cv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 129)];
    cv.tag = kAvailRoomCellContViewTag;
    [tableViewPopout addSubview:cv];
    
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, 316, 125)];
    borderView.layer.borderColor = [UIColor blackColor].CGColor;
    borderView.layer.borderWidth = 1.0f;
    borderView.layer.cornerRadius = WOTA_CORNER_RADIUS;
    borderView.layer.masksToBounds = YES;
    borderView.clipsToBounds = YES;
    borderView.tag = kAvailRoomBorderViewTag;
    [cv addSubview:borderView];
    
    UIImageView *roomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -71, 316, 210)];
    roomImageView.tag = kRoomImageViewTag;
    roomImageView.clipsToBounds = YES;
    roomImageView.contentMode = UIViewContentModeScaleAspectFill;
    [borderView addSubview:roomImageView];
    
    UIView *imageViewBottomCover = [[UIView alloc] initWithFrame:CGRectMake(0, 84, 316, 55)];
    imageViewBottomCover.tag = kImageViewBottomCoverTag;
    imageViewBottomCover.backgroundColor = [UIColor whiteColor];
    [borderView addSubview:imageViewBottomCover];
    
    UIView *priceGradientCover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 316, 84)];
    priceGradientCover.tag = kPriceGradientCoverTag;
    priceGradientCover.clipsToBounds = YES;
    [self addPriceGradient:priceGradientCover];
    [borderView addSubview:priceGradientCover];
    
    UIView *bottomGradientCover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 316, 84)];
    bottomGradientCover.tag = kBottomGradientCoverTag;
    bottomGradientCover.clipsToBounds = YES;
    [self addBottomGradient:bottomGradientCover];
    [borderView addSubview:bottomGradientCover];
    
    UIView *bottomsUpGradientCover = [[UIView alloc] initWithFrame:CGRectMake(0, 190, 316, 20)];
    bottomsUpGradientCover.clipsToBounds = YES;
    [self addBottomsUpGradient:bottomsUpGradientCover];
    [borderView addSubview:bottomsUpGradientCover];
    
    UILabel *rtd = [[UILabel alloc] initWithFrame:CGRectMake(3, 71, 190, 53)];
    rtd.tag = kRoomTypeDescViewTag;
    rtd.lineBreakMode = NSLineBreakByWordWrapping;
    rtd.numberOfLines = 2;
    rtd.font = [UIFont boldSystemFontOfSize:19.0f];
    [borderView addSubview:rtd];
    
    WotaTappableView *vaContainer = [[WotaTappableView alloc] initWithFrame:CGRectMake(294, 52, 19, 19)];
    vaContainer.playClickSound = NO;
    [vaContainer addGestureRecognizer:[self loadInfoPopupTapGesture]];
    vaContainer.tag = kRoomValueAddTag;
    vaContainer.borderColor = [UIColor clearColor];
    vaContainer.tapColor = kTheColorOfMoney();
    vaContainer.untapColor = [UIColor clearColor];
    UIImageView *valueAdd = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plus"]];
    valueAdd.frame = vaContainer.bounds;
    valueAdd.userInteractionEnabled = NO;
    valueAdd.backgroundColor = [UIColor clearColor];
    [vaContainer addSubview:valueAdd];
    [borderView addSubview:vaContainer];
    
    UILabel *rateLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 69, 112, 22)];
    rateLabel.tag = kRoomRateViewTag;
    rateLabel.textColor = kTheColorOfMoney();
    rateLabel.textAlignment = NSTextAlignmentRight;
//    [rateLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
    [rateLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18.0f]];
    rateLabel.minimumScaleFactor = 0.5f;
    rateLabel.adjustsFontSizeToFitWidth = YES;
    [borderView addSubview:rateLabel];
    
    UILabel *perNightLabel = [[UILabel alloc] initWithFrame:CGRectMake(262, 87, 50, 15)];
    perNightLabel.tag = kRoomPerNightTag;
    perNightLabel.textAlignment = NSTextAlignmentRight;
    [perNightLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [borderView addSubview:perNightLabel];
    
    WotaTappableView *totalView = [[WotaTappableView alloc] initWithFrame:CGRectMake(142, 240, 171, 40)];
    totalView.tapColor = kTheColorOfMoney();
    totalView.untapColor = [UIColor clearColor];
    totalView.tag = kRoomTotalViewTag;
    totalView.userInteractionEnabled = YES;
    totalView.backgroundColor = [UIColor clearColor];
//    totalView.layer.cornerRadius = WOTA_CORNER_RADIUS;
//    totalView.layer.borderColor = UIColorFromRGB(0x0D9C03).CGColor;
    totalView.borderColor = kTheColorOfMoney();
//    totalView.layer.borderWidth = 0.5f;
    [borderView addSubview:totalView];
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadPriceDetailsPopup:)];
    tapper.numberOfTapsRequired = 1;
    tapper.numberOfTouchesRequired = 1;
    tapper.cancelsTouchesInView = NO;
    [totalView addGestureRecognizer:tapper];
    
    UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 11, 144, 33)];
    totalLabel.tag = kRoomTotalAmountTag;
    totalLabel.lineBreakMode = NSLineBreakByClipping;
    totalLabel.textColor = kTheColorOfMoney();
    totalLabel.textAlignment = NSTextAlignmentRight;
    [totalLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:21.0f]];
    totalLabel.minimumScaleFactor = 0.5f;
    totalLabel.adjustsFontSizeToFitWidth = YES;
    [totalView addSubview:totalLabel];

    UILabel *totalInquiry = [[UILabel alloc] initWithFrame:CGRectMake(148, 12, 22, 33)];
    totalInquiry.text = @"ℹ️";
    totalInquiry.textAlignment = NSTextAlignmentRight;
    [totalView addSubview:totalInquiry];
    
    UILabel *totalWithTaxLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 0, 103, 16)];
    totalWithTaxLabel.lineBreakMode = NSLineBreakByClipping;
    totalWithTaxLabel.text = @"Total With Tax";
    totalWithTaxLabel.textAlignment = NSTextAlignmentRight;
    totalWithTaxLabel.textColor = kTheColorOfMoney();
    totalWithTaxLabel.textAlignment = NSTextAlignmentCenter;
    [totalWithTaxLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0f]];
    [totalView addSubview:totalWithTaxLabel];
    
    UILabel *nonreundLabel = [[UILabel alloc] initWithFrame:CGRectMake(198, 104, 118, 21)];
    nonreundLabel.clipsToBounds = YES;
    nonreundLabel.lineBreakMode = NSLineBreakByClipping;
    nonreundLabel.layer.cornerRadius = WOTA_CORNER_RADIUS;
    nonreundLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    nonreundLabel.layer.borderWidth = 0.5f;
    //    nonreundLabel.backgroundColor = [UIColor colorWithRed:255/255.0f green:141/255.0f blue:9/255.0f alpha:1.0f];
    nonreundLabel.tag = kRoomNonRefundViewTag;
    nonreundLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    nonreundLabel.textAlignment = NSTextAlignmentCenter;
    [borderView addSubview:nonreundLabel];
    
    UILabel *nonreundLongLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 242, 136, 36)];
    nonreundLongLabel.clipsToBounds = YES;
    nonreundLongLabel.userInteractionEnabled = YES;
    nonreundLongLabel.lineBreakMode = NSLineBreakByWordWrapping;
    nonreundLongLabel.numberOfLines = 2;
    nonreundLongLabel.layer.cornerRadius = WOTA_CORNER_RADIUS;
    nonreundLongLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    nonreundLongLabel.layer.borderWidth = 0.5f;
    nonreundLongLabel.tag = kRoomNonRefundLongTag;
    nonreundLongLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    nonreundLongLabel.textAlignment = NSTextAlignmentCenter;
    [borderView addSubview:nonreundLongLabel];
    
    UILabel *rtdL = [[UILabel alloc] initWithFrame:CGRectMake(3, 278, 312, 82)];
    rtdL.tag = kRoomTypeDescrLongTag;
    rtdL.userInteractionEnabled = YES;
    rtdL.lineBreakMode = NSLineBreakByWordWrapping;
    rtdL.numberOfLines = 5;
    rtdL.font = [UIFont systemFontOfSize:12.0f];
    [borderView addSubview:rtdL];
    
    UILabel *promoLabel = [[UILabel alloc] initWithFrame:CGRectMake(280, -6, 60, 27)];
    promoLabel.tag = kPromoLabelTag;
    promoLabel.backgroundColor = kTheColorOfMoney();
    promoLabel.textColor = [UIColor whiteColor];
    promoLabel.textAlignment = NSTextAlignmentCenter;
    promoLabel.font = [UIFont boldSystemFontOfSize:11.0f];
    promoLabel.numberOfLines = 2;
    promoLabel.transform = CGAffineTransformMakeRotation((M_PI * 45 / 180.0));
    [borderView addSubview:promoLabel];
    
    [rtdL addGestureRecognizer:[self loadInfoPopupTapGesture]];
    [nonreundLongLabel addGestureRecognizer:[self loadInfoPopupTapGesture]];
    
    self.bedTypeButton = [WotaButton wbWithFrame:CGRectMake(5, 364, 186, 30)];
    [self.bedTypeButton addTarget:self action:@selector(clickBedType:) forControlEvents:UIControlEventTouchUpInside];
    [tableViewPopout addSubview:self.bedTypeButton];
    
    self.smokingButton = [WotaButton wbWithFrame:CGRectMake(194, 364, 120, 30)];
    [self.smokingButton addTarget:self action:@selector(clickSmokingPref:) forControlEvents:UIControlEventTouchUpInside];
    [tableViewPopout addSubview:self.smokingButton];
    
    self.tableViewPopOut = tableViewPopout;
}

- (UITapGestureRecognizer *)loadInfoPopupTapGesture {
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadInfoDetailsPopup:)];
    tgr.numberOfTapsRequired = 1;
    tgr.numberOfTapsRequired = 1;
    tgr.cancelsTouchesInView = NO;
    return tgr;
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
    self.pickerViewDisclaimerLabel.text = @"Bed type not guaranteed";
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
    
    self.overlayDisable.alpha = 0.0f;
    [self.view addSubview:self.overlayDisable];
    [self.view bringSubviewToFront:self.overlayDisable];
    [self.pickerViewContainer addSubview:self.bedTypePickerView];
    [self.view bringSubviewToFront:self.pickerViewContainer];
    self.isPickerContainerShowing = YES;
    [UIView animateWithDuration:kSrQuickAnimationDuration animations:^{
        self.overlayDisable.alpha = 0.8f;
        self.pickerViewContainer.frame = CGRectMake(0, 364, 320, 204);
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)clickSmokingPref:(id)sender {
    self.pickerViewDisclaimerLabel.text = @"Smoking preference not guaranteed";
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
    
    self.overlayDisable.alpha = 0.0f;
    [self.view addSubview:self.overlayDisable];
    [self.view bringSubviewToFront:self.overlayDisable];
    [self.pickerViewContainer addSubview:self.smokingPrefPickerView];
    [self.view bringSubviewToFront:self.pickerViewContainer];
    self.isPickerContainerShowing = YES;
    [UIView animateWithDuration:kSrQuickAnimationDuration animations:^{
        self.overlayDisable.alpha = 0.8f;
        self.pickerViewContainer.frame = CGRectMake(0, 364, 320, 204);
    } completion:^(BOOL finished) {
        ;
    }];
}

- (IBAction)justPushIt:(id)sender {
    if (sender == self.bookButtonOutlet) {
        BOOL guestGood = [self validateGuestDetails];
        BOOL paymtGood = [self isWeGoodForCredit];
        if (guestGood && paymtGood) [self loadBookConfirmView];
        else if (!guestGood && !paymtGood) {
            [NetworkProblemResponder launchWithSuperView:self.view headerTitle:@"Missing Information" messageString:@"Please fill in the requested information for Guest Details and Payment Details." completionCallback:nil];
        } else if (!guestGood) {
            [NetworkProblemResponder launchWithSuperView:self.view headerTitle:@"Missing Guest Details" messageString:@"Please fill in the requested information for Guest Details." completionCallback:nil];
        } else {
            [NetworkProblemResponder launchWithSuperView:self.view headerTitle:@"Missing Payment Details" messageString:@"Please fill in the requested information for Payment Details." completionCallback:nil];
        }
    }
}

- (void)bookIt {
    [self dropCVVView];
    [self dropBookConfirmView];
    
    if (!self.expandedIndexPath)
        return;
    
    self.selectedRoom = [self.tableData objectAtIndex:self.expandedIndexPath.row];
    SelectionCriteria *sc = [SelectionCriteria singleton];
    GuestInfo *gi = [GuestInfo singleton];
    PaymentDetails *pd = self.paymentDetails;
    BookViewController *bvc = [BookViewController new];
    NSUUID *aci = [NSUUID UUID];
    bvc.affiliateConfirmationId = aci;
    
    NSString *creditCardNumber = inProductionMode() ? pd.cardNumber : @"5401999999999999";
    NSString *creditCardIdentifier = inProductionMode() ? self.cvvTextField.text : @"123";
    
    [[LoadEanData sharedInstance:bvc] bookHotelRoomWithHotelId:self.eanHrar.hotelId
                                                   arrivalDate:sc.arrivalDateEanString
                                                 departureDate:sc.returnDateEanString
                                                  supplierType:self.selectedRoom.supplierType
                                                       rateKey:self.selectedRoom.rateInfo.roomGroup.rateKey
                                                  roomTypeCode:self.selectedRoom.roomType.roomCode
                                                      rateCode:self.selectedRoom.rateCode
                                                chargeableRate:[self.selectedRoom.rateInfo.chargeableRateInfo.total floatValue]
                                                numberOfAdults:sc.numberOfAdults
                                                childTravelers:[ChildTraveler childTravelers]
                                                room1FirstName:gi.apiFirstName
                                                 room1LastName:gi.apiLastName
                                                room1BedTypeId:self.selectedRoom.selectedBedType.bedTypeId
                                        room1SmokingPreference:self.selectedRoom.selectedSmokingPreference
                                       affiliateConfirmationId:aci
                                                         email:gi.apiEmail
                                                     firstName:pd.cardHolderFirstName
                                                      lastName:pd.cardHolderLastName
                                                     homePhone:gi.apiPhoneNumber
                                                creditCardType:pd.eanCardType
                                              creditCardNumber:creditCardNumber
                                          creditCardIdentifier:creditCardIdentifier
                                     creditCardExpirationMonth:pd.expirationMonth
                                      creditCardExpirationYear:pd.expirationYear
                                                      address1:pd.billingAddress.apiAddress1
                                                          city:pd.billingAddress.apiCity
                                             stateProvinceCode:pd.billingAddress.stateProvinceCode
                                                   countryCode:pd.billingAddress.apiCountryCode
                                                    postalCode:pd.billingAddress.apiPostalCode];
    
    self.paymentDetails = nil;
    [self updatePaymentDetailsButtonTitle];
    self.ccNumberOutlet.cardNumber = @"";
    [self.navigationController pushViewController:bvc animated:YES];
}

- (void)saveDaExpiration {
    if (stringIsEmpty(self.expirationOutlet.text)) return;
    
    NSArray *expArr = [self.expirationOutlet.text componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    
    if ([expArr count] != 2) return;
    
    NSString *expMonth = expArr[0];
    NSString *expYear = expArr[1];
    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"MM"];
//    NSDate *daDate = [dateFormatter dateFromString:expMonth];
//    NSString *nExpMonth = [dateFormatter stringFromDate:daDate];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM"];
    dateFormatter.locale = [NSLocale currentLocale];
    NSDate *daDate = [dateFormatter dateFromString:expMonth];
    NSInteger nExpMonth = [[NSCalendar currentCalendar] component:NSCalendarUnitMonth fromDate:daDate];
    
    self.paymentDetails.expirationMonth = [NSString stringWithFormat: @"%ld", (long)nExpMonth];
    self.paymentDetails.expirationYear = expYear;
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

- (void)addInputAccessoryViewToPhoneNumber {
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithPhoneNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    self.phoneOutlet.inputAccessoryView = numberToolbar;
}

-(void)doneWithPhoneNumberPad {
    AudioServicesPlaySystemSound(0x450);
    [self textFieldShouldReturn:self.phoneOutlet];
}

- (NSArray *)parseTextFieldText:(NSString *)text {
    // Curtesy of http://stackoverflow.com/questions/12136970/removing-multiple-spaces-in-nsstring
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"  +" options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *trimmedText = [regex stringByReplacingMatchesInString:text options:0 range:NSMakeRange(0, [text length]) withTemplate:@" "];
    NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [trimmedText componentsSeparatedByCharactersInSet:ws];
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.ccNumberOutlet) {
        [self addInputAccessoryViewToCardNumber];
    }
    
    else if (textField == self.phoneOutlet) {
        [self addInputAccessoryViewToPhoneNumber];
    }
    
    else if (textField == self.emailOutlet && !self.isValidEmail && nil != self.confirmEmailOutlet.delegate) {
        self.confirmEmailOutlet.text = @"";
        self.confirmEmailOutlet.backgroundColor = [UIColor whiteColor];
        self.isValidConfirmEmail = NO;
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.currentFirstResponder = textField;
    textField.layer.cornerRadius = 6.0f;
    textField.layer.borderWidth = 1.0f;
    textField.layer.borderColor = kWotaColorOne().CGColor;
    
    if (textField == self.phoneCountryContainer) {
        [textField setInputView:self.countryPickerContainer];
    }
    
    else if (textField == self.ccNumberOutlet) {
        
    } else if (textField == self.expirationOutlet) {
        [textField setInputView:self.expirationInputView];
    } else if (textField == self.cardholderFirstOutlet) {
        
    } else if (textField == self.addressTextFieldOutlet) {
        
    } else if (textField == self.countryTextField) {
        [textField setInputView:self.countryPickerContainer];
    } else if (textField == self.stateTextField) {
        [textField setInputView:self.statePickerContainer];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    textField.layer.cornerRadius = 0.0f;
    textField.layer.borderWidth = 0.0f;
    textField.layer.borderColor = [UIColor clearColor].CGColor;
}

- (BOOL)checkMaxLenTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string maxLength:(NSUInteger)maxLength checkAlpha:(BOOL)checkAlpha allowNumbers:(BOOL)allowNumbers successBlock:(void(^)(void))successBlock {
    
    if (checkAlpha) {
//        NSCharacterSet *dc = [[NSCharacterSet characterSetWithCharactersInString:@"-abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"] invertedSet];
        NSMutableCharacterSet *ac = allowNumbers ? [NSMutableCharacterSet alphanumericCharacterSet] : [NSMutableCharacterSet letterCharacterSet];
        [ac formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
//        [ac formUnionWithCharacterSet:[NSCharacterSet symbolCharacterSet]];
        [ac formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([string rangeOfCharacterFromSet:[ac invertedSet]].location != NSNotFound)
            return NO;
    }
    
    // http://stackoverflow.com/questions/433337/set-the-maximum-character-length-of-a-uitextfield
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length) {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if (newLength <= maxLength) {
        if (successBlock) successBlock();
        return YES;
    } else {
        return NO;
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
        
        NSString *sa = [textField.text stringByReplacingCharactersInRange:range withString:string];
        [self validateStreetAddress:sa];
        return YES;
        
    } else if (textField == self.cityTextField) {
        
        return [self checkMaxLenTextField:textField
            shouldChangeCharactersInRange:range
                        replacementString:string
                                maxLength:100
                               checkAlpha:YES
                             allowNumbers:YES
                             successBlock:^{
                                 NSString *city = [textField.text stringByReplacingCharactersInRange:range withString:string];
                                 [self validateCity:city];
                             }];
        
    } else if (textField == self.countryTextField) {
        
        return YES;
        
    } else if (textField == self.stateTextField) {
        
        NSString *state = [textField.text stringByReplacingCharactersInRange:range withString:string];
        [self validateState:state];
        return YES;
        
    } else if (textField == self.postalTextField) {
        
        NSString *pc = [textField.text stringByReplacingCharactersInRange:range withString:string];
        [self validatePostalCode:pc];
        return YES;
        
    } else if (textField == self.expirationOutlet) {
        
    } else if (textField == self.cardholderFirstOutlet) {
        
        return [self checkMaxLenTextField:textField
            shouldChangeCharactersInRange:range
                        replacementString:string
                                maxLength:MAX_FIRST_NAME_LENGTH
                               checkAlpha:YES
                             allowNumbers:NO
                             successBlock:^{
                                 NSString *ch = [textField.text stringByReplacingCharactersInRange:range withString:string];
                                 [self validateCardholder:ch];
                             }];
        
    } else if (textField == self.cardholderLastOutlet) {
        
        return [self checkMaxLenTextField:textField
            shouldChangeCharactersInRange:range
                        replacementString:string
                                maxLength:MAX_LAST_NAME_LENGTH
                               checkAlpha:YES
                             allowNumbers:NO
                             successBlock:^{
                                 NSString *ch = [textField.text stringByReplacingCharactersInRange:range withString:string];
                                 [self validateCardholderLast:ch];
                             }];
        
    }
    
    else if (textField == self.firstNameOutlet) {
        
        return [self checkMaxLenTextField:textField
            shouldChangeCharactersInRange:range
                        replacementString:string
                                maxLength:MAX_FIRST_NAME_LENGTH
                               checkAlpha:YES
                             allowNumbers:NO
                             successBlock:^{
                                 NSString *fn = [textField.text stringByReplacingCharactersInRange:range withString:string];
                                 [self validateFirstName:fn];
                             }];
        
    } else if (textField == self.lastNameOutlet) {
        
        return [self checkMaxLenTextField:textField
            shouldChangeCharactersInRange:range
                        replacementString:string
                                maxLength:MAX_LAST_NAME_LENGTH
                               checkAlpha:YES
                             allowNumbers:NO
                             successBlock:^{
                                 NSString *ln = [textField.text stringByReplacingCharactersInRange:range withString:string];
                                 [self validateLastName:ln];
                             }];
        
    } else if (textField == self.emailOutlet) {
        
        if ([string rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location != NSNotFound)
            return NO;
        
        return [self checkMaxLenTextField:textField
            shouldChangeCharactersInRange:range
                        replacementString:string
                                maxLength:MAX_EMAIL_LENGTH
                               checkAlpha:NO
                             allowNumbers:YES
                             successBlock:^{
                                 NSString *em = [textField.text stringByReplacingCharactersInRange:range withString:string];
                                 [self validateEmailAddress:em withNoGoColor:NO];
                             }];
        
    } else if (textField == self.confirmEmailOutlet) {
        
        if (self.isValidEmail) {
            NSString *em = [textField.text stringByReplacingCharactersInRange:range withString:string];
            [self validateConfirmEmailAddress:em whileLeaving:NO];
        } else {
            self.confirmEmailOutlet.placeholder = @"Please enter a valid email above";
            return NO;
        }
        
    } else if (textField == self.phoneOutlet) {
        
        NSString *ph = [textField.text stringByReplacingCharactersInRange:range withString:string];
        [self validatePhone:ph];
        
    }
    
    else if (textField == self.cvvTextField) {
        
        if (!self.paymentDetails || !self.paymentDetails.eanCardType) return NO;
        
        int minLength = [self.paymentDetails.eanCardType isEqualToString:@"AX"] ? 4 : 3;
        
        if(range.length + range.location > textField.text.length)
            return NO;
        
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        if (newLength >= minLength) self.purchaseButton.enabled = YES;
        else self.purchaseButton.enabled = NO;
        
        return YES;
        
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.ccNumberOutlet) {
        [self.expirationOutlet becomeFirstResponder];
    } else if (textField == self.expirationOutlet) {
        [self.cardholderFirstOutlet becomeFirstResponder];
    } else if (textField == self.cardholderFirstOutlet) {
        [self.cardholderLastOutlet becomeFirstResponder];
    } else if (textField == self.cardholderLastOutlet) {
        [self.addressTextFieldOutlet becomeFirstResponder];
    } else if (textField == self.addressTextFieldOutlet) {
        [self.cityTextField becomeFirstResponder];
    } else if (textField == self.cityTextField) {
        [self.countryTextField becomeFirstResponder];
    } else if (textField == self.countryTextField) {
        
        NSString *cc = self.countryTextField.text;
        if ([cc isEqualToString:@"US"] || [cc isEqualToString:@"CA"] || [cc isEqualToString:@"AU"]) {
            [self.stateTextField becomeFirstResponder];
        } else {
            [self.postalTextField becomeFirstResponder];
        }
        
    } else if (textField == self.stateTextField) {
        [self.postalTextField becomeFirstResponder];
    } else if (textField == self.postalTextField) {
        [self.ccNumberOutlet becomeFirstResponder];
    }
    
    else if (textField == self.firstNameOutlet) {
        [self.lastNameOutlet becomeFirstResponder];
    } else if (textField == self.lastNameOutlet) {
        [self.emailOutlet becomeFirstResponder];
    } else if (textField == self.emailOutlet) {
        
        [self validateEmailAddress:self.emailOutlet.text withNoGoColor:YES];
        
        if (nil == self.confirmEmailOutlet.delegate) {
            [self.phoneCountryContainer becomeFirstResponder];
        } else {
            [self.confirmEmailOutlet becomeFirstResponder];
        }
        
    } else if (textField == self.confirmEmailOutlet) {
        [self validateConfirmEmailAddress:self.confirmEmailOutlet.text whileLeaving:YES];
        [self.phoneCountryContainer becomeFirstResponder];
    } else if (textField == self.phoneCountryContainer) {
        [self.phoneOutlet becomeFirstResponder];
    } else if (textField == self.phoneOutlet) {
        [self.firstNameOutlet becomeFirstResponder];
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField == self.ccNumberOutlet) {
        self.isValidCreditCard = NO;
        [self enableOrDisableRightBarButtonItemForPayment];
        self.ccNumberOutlet.backgroundColor = [UIColor whiteColor];
    } else if (textField == self.cardholderFirstOutlet) {
        self.isValidCardHolderFirst = NO;
        [self enableOrDisableRightBarButtonItemForPayment];
        self.cardholderFirstOutlet.backgroundColor = [UIColor whiteColor];
    } else if (textField == self.cardholderLastOutlet) {
        self.isValidCardHolderLast = NO;
        [self enableOrDisableRightBarButtonItemForPayment];
        self.cardholderLastOutlet.backgroundColor = [UIColor whiteColor];
    } else if (textField == self.addressTextFieldOutlet) {
        self.isValidStreetAddress = NO;
        [self enableOrDisableRightBarButtonItemForPayment];
        self.addressTextFieldOutlet.backgroundColor = [UIColor whiteColor];
    } else if (textField == self.cityTextField) {
        self.isValidCity = NO;
        [self enableOrDisableRightBarButtonItemForPayment];
        self.cityTextField.backgroundColor = [UIColor whiteColor];
    } else if (textField == self.stateTextField) {
        self.isValidState = NO;
        [self enableOrDisableRightBarButtonItemForPayment];
        self.stateTextField.backgroundColor = [UIColor whiteColor];
    } else if (textField == self.postalTextField) {
        self.isValidPostalCode = NO;
        [self enableOrDisableRightBarButtonItemForPayment];
        self.postalTextField.backgroundColor = [UIColor whiteColor];
    }
    
    else if (textField == self.firstNameOutlet) {
        self.isValidFirstName = NO;
        [self enableOrDisableRightBarButtonItemForGuest];
    } else if (textField == self.lastNameOutlet) {
        self.isValidLastName = NO;
        [self enableOrDisableRightBarButtonItemForGuest];
    } else if (textField == self.emailOutlet) {
        self.isValidEmail = NO;
        self.emailOutlet.backgroundColor = [UIColor whiteColor];
        [self enableOrDisableRightBarButtonItemForGuest];
    } else if (textField == self.confirmEmailOutlet) {
        self.isValidConfirmEmail = NO;
        self.confirmEmailOutlet.backgroundColor = [UIColor whiteColor];
        [self enableOrDisableRightBarButtonItemForGuest];
    } else if (textField == self.phoneOutlet) {
        self.isValidPhone = NO;
        [self enableOrDisableRightBarButtonItemForGuest];
    }
    
    return YES;
}

#pragma mark Expiration Picker and Outlet methods

- (void)tdBedTypeDone:(id)sender {
    ((UIButton *)sender).backgroundColor = [UIColor whiteColor];
    AudioServicesPlaySystemSound(0x450);
}

- (void)tuiBedTypeDone:(id)sender {
    if (!self.isPickerContainerShowing) {
        return;
    }
    
    ((UIButton *) sender).backgroundColor = UIColorFromRGB(0xc4c4c4);
    
    if ([self.pickerViewDoneButton.titleLabel.text isEqualToString:@"Next"]) {
        [self.phoneOutlet becomeFirstResponder];
    }
    
    self.isPickerContainerShowing = NO;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:kSrQuickAnimationDuration animations:^{
        weakSelf.overlayDisable.alpha = 0.0f;
        weakSelf.pickerViewContainer.frame = CGRectMake(0, 600, 320, 204);
    } completion:^(BOOL finished) {
        [weakSelf.overlayDisable removeFromSuperview];
        if ([weakSelf.pickerViewDoneButton.titleLabel.text isEqualToString:@"Next"]) {
            [weakSelf.pickerViewDoneButton setTitle:@"Done" forState:UIControlStateNormal];
        }
        for (UIView *v in weakSelf.pickerViewContainer.subviews)
            if (v.tag != kPickerContainerDoneButton && v.tag != kPickerContainerDisclaimer) [v removeFromSuperview];
    }];
}

- (void)tuoBedTypeDone:(id)sender {
    ((UIButton *) sender).backgroundColor = UIColorFromRGB(0xc4c4c4);
}

- (void)setupPickerViewContainer {
    self.pickerViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 600, 320, 204)];
    self.pickerViewContainer.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.pickerViewContainer];
    
    self.pickerViewDoneButton = [[UIButton alloc] initWithFrame:CGRectMake(242, 163, 75, 38)];
    self.pickerViewDoneButton.tag = kPickerContainerDoneButton;
    self.pickerViewDoneButton.backgroundColor = UIColorFromRGB(0xc4c4c4);
    self.pickerViewDoneButton.layer.cornerRadius = 4.0f;
    self.pickerViewDoneButton.layer.masksToBounds = NO;
    self.pickerViewDoneButton.layer.borderWidth = 0.8f;
    self.pickerViewDoneButton.layer.borderColor = UIColorFromRGB(0xb5b5b5).CGColor;
    
    self.pickerViewDoneButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.pickerViewDoneButton.layer.shadowOpacity = 0.8;
    self.pickerViewDoneButton.layer.shadowRadius = 1;
    self.pickerViewDoneButton.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    
    [self.pickerViewDoneButton setTitle:@"Done" forState:UIControlStateNormal];
    self.pickerViewDoneButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [self.pickerViewDoneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.pickerViewDoneButton addTarget:self action:@selector(tdBedTypeDone:) forControlEvents:UIControlEventTouchDown];
    [self.pickerViewDoneButton addTarget:self action:@selector(tuiBedTypeDone:) forControlEvents:UIControlEventTouchUpInside];
    [self.pickerViewDoneButton addTarget:self action:@selector(tuoBedTypeDone:) forControlEvents:UIControlEventTouchUpOutside];
    [self.pickerViewContainer addSubview:self.pickerViewDoneButton];
    
    self.pickerViewDisclaimerLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 165, 223, 38)];
    self.pickerViewDisclaimerLabel.tag = kPickerContainerDisclaimer;
    self.pickerViewDisclaimerLabel.backgroundColor = [UIColor clearColor];
    self.pickerViewDisclaimerLabel.textAlignment = NSTextAlignmentLeft;
    self.pickerViewDisclaimerLabel.textColor = [UIColor blackColor];
    self.pickerViewDisclaimerLabel.text = @"Smoking preference not guaranteed";
    self.pickerViewDisclaimerLabel.font = [UIFont systemFontOfSize:13.0f];
    [self.pickerViewContainer addSubview:self.pickerViewDisclaimerLabel];
}

- (void)tdExpirNext:(id)sender {
    AudioServicesPlaySystemSound(0x450);
    ((UIView *)sender).backgroundColor = [UIColor whiteColor];
}

- (void)tuiExpirNext:(id)sender {
    ((UIView *) sender).backgroundColor = UIColorFromRGB(0xc4c4c4);
    [self.cardholderFirstOutlet becomeFirstResponder];
}

- (void)tuiStatePickerNext:(id)sender {
    ((UIView *) sender).backgroundColor = UIColorFromRGB(0xc4c4c4);
    [self.postalTextField becomeFirstResponder];
}

- (void)tuiCountryPickerNext:(id)sender {
    ((UIView *) sender).backgroundColor = UIColorFromRGB(0xc4c4c4);
    UIView *guestDetailsView = [self.view viewWithTag:kGuestDetailsViewTag];
    UIView *paymentDetailsView = [self.view viewWithTag:kPaymentDetailsViewTag];
    if (guestDetailsView) [self.phoneOutlet becomeFirstResponder];
    if (paymentDetailsView) {
        NSString *cc = self.countryTextField.text;
        if ([cc isEqualToString:@"US"] || [cc isEqualToString:@"CA"] || [cc isEqualToString:@"AU"]) {
            [self.stateTextField becomeFirstResponder];
        } else {
            [self.postalTextField becomeFirstResponder];
        }
    }
}

- (void)tuoExpirNext:(id)sender {
    ((UIView *) sender).backgroundColor = UIColorFromRGB(0xc4c4c4);
}

- (void)setupStatePicker {
    self.statePickerContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 361, 320, 207)];
    self.statePickerContainer.backgroundColor = [UIColor whiteColor];
    
    self.statePickerNextBtn = [[UIButton alloc] initWithFrame:CGRectMake(242, 166, 75, 38)];
    self.statePickerNextBtn.backgroundColor = UIColorFromRGB(0xc4c4c4);
    self.statePickerNextBtn.layer.cornerRadius = 4.0f;
    self.statePickerNextBtn.layer.masksToBounds = NO;
    self.statePickerNextBtn.layer.borderWidth = 0.8f;
    self.statePickerNextBtn.layer.borderColor = UIColorFromRGB(0xb5b5b5).CGColor;
    
    self.statePickerNextBtn.layer.shadowColor = [UIColor blackColor].CGColor;
    self.statePickerNextBtn.layer.shadowOpacity = 0.8;
    self.statePickerNextBtn.layer.shadowRadius = 1;
    self.statePickerNextBtn.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    
    [self.statePickerNextBtn setTitle:@"Next" forState:UIControlStateNormal];
    self.statePickerNextBtn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [self.statePickerNextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.statePickerNextBtn addTarget:self action:@selector(tdExpirNext:) forControlEvents:UIControlEventTouchDown];
    [self.statePickerNextBtn addTarget:self action:@selector(tuiStatePickerNext:) forControlEvents:UIControlEventTouchUpInside];
    [self.statePickerNextBtn addTarget:self action:@selector(tuoExpirNext:) forControlEvents:UIControlEventTouchUpOutside];
    [self.statePickerContainer addSubview:self.statePickerNextBtn];
    
    self.statePicker = [[StatePickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 162)];
    self.statePicker.backgroundColor = UIColorFromRGB(0xe3e3e3);;
    self.statePicker.stateDelegate = self;
    [self.statePickerContainer addSubview:self.statePicker];
}

- (void)setupCountryPicker {
    self.countryPickerContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 361, 320, 207)];
    self.countryPickerContainer.backgroundColor = [UIColor whiteColor];
    
    self.countryPickerNextBtn = [[UIButton alloc] initWithFrame:CGRectMake(242, 166, 75, 38)];
    self.countryPickerNextBtn.backgroundColor = UIColorFromRGB(0xc4c4c4);
    self.countryPickerNextBtn.layer.cornerRadius = 4.0f;
    self.countryPickerNextBtn.layer.masksToBounds = NO;
    self.countryPickerNextBtn.layer.borderWidth = 0.8f;
    self.countryPickerNextBtn.layer.borderColor = UIColorFromRGB(0xb5b5b5).CGColor;
    
    self.countryPickerNextBtn.layer.shadowColor = [UIColor blackColor].CGColor;
    self.countryPickerNextBtn.layer.shadowOpacity = 0.8;
    self.countryPickerNextBtn.layer.shadowRadius = 1;
    self.countryPickerNextBtn.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    
    [self.countryPickerNextBtn setTitle:@"Next" forState:UIControlStateNormal];
    self.countryPickerNextBtn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [self.countryPickerNextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.countryPickerNextBtn addTarget:self action:@selector(tdExpirNext:) forControlEvents:UIControlEventTouchDown];
    [self.countryPickerNextBtn addTarget:self action:@selector(tuiCountryPickerNext:) forControlEvents:UIControlEventTouchUpInside];
    [self.countryPickerNextBtn addTarget:self action:@selector(tuoExpirNext:) forControlEvents:UIControlEventTouchUpOutside];
    [self.countryPickerContainer addSubview:self.countryPickerNextBtn];
    
    self.countryPicker = [[CountryPicker alloc] initWithFrame:CGRectMake(0, 0, 320, 162)];
    self.countryPicker.backgroundColor = UIColorFromRGB(0xe3e3e3);;
    self.countryPicker.delegate = self;
    [self.countryPickerContainer addSubview:self.countryPicker];
    
//    if (!self.guestDetailsView) {
//        return;
//    }
//    
//    [self setupInternationalCallingCodes];
}

- (void)setupInternationalCallingCodes {
    self.selectedInternationalCallingCountryCode = [GuestInfo singleton].countryCode;
    NSString *callingCodesPath = [[NSBundle mainBundle] pathForResource:@"InternationalCallingCodes" ofType:@"plist"];
    NSDictionary *callingCodesDict = [NSDictionary dictionaryWithContentsOfFile:callingCodesPath];
    id iccCountryCode = [callingCodesDict objectForKey:[self.selectedInternationalCallingCountryCode lowercaseString]];
    NSString *countryCode = nil;
    
    if (nil == iccCountryCode || [iccCountryCode isEqualToString:@""]) {
        countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    } else {
        countryCode = [self.selectedInternationalCallingCountryCode uppercaseString];
    }
    
    UIImageView *flagView = (UIImageView *) [self.phoneCountryContainer.leftView viewWithTag:kFlagViewTag];
    
    NSString *pathForImageResource = [NSString stringWithFormat:@"CountryPicker.bundle/%@", countryCode];
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:pathForImageResource ofType:@"png"];
    if (nil != imagePath && ![imagePath isEqualToString:@""]) {
        UIImage *image = [UIImage imageNamed:imagePath];
        if (nil != image) {
            flagView.image = image;
        }
    }
    
    id callingCode = [callingCodesDict objectForKey:[countryCode lowercaseString]];
    if (nil != callingCode && [callingCode isKindOfClass:[NSString class]]) {
        self.phoneCountryContainer.text = [@"+" stringByAppendingString:callingCode];
    }
    
    [self.countryPicker setSelectedCountryCode:countryCode];
}

- (void)setTheCountryCode:(NSString *)code setPicker:(BOOL)setPicker {
    NSString *countryCode = nil;
    
    if (!code || [code isEqualToString:@""]) {
        countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    } else {
        countryCode = [code uppercaseString];
    }
    
    if ([countryCode isEqualToString:@"US"] || [countryCode isEqualToString:@"CA"] || [countryCode isEqualToString:@"AU"]) {
        self.statePicker.country = countryCode;
        [self.statePicker reloadAllComponents];
        
        if ([countryCode isEqualToString:self.paymentDetails.billingAddress.countryCode]) {
            self.statePicker.selectedStateAbbr = self.stateTextField.text = self.paymentDetails.billingAddress.stateProvinceCode;
        } else {
            self.stateTextField.text = nil;
        }
        
        self.stateTextField.hidden = NO;
    } else {
        self.stateTextField.text = nil;
        self.stateTextField.hidden = YES;
    }
    
    NSString *pathForImageResource = [NSString stringWithFormat:@"CountryPicker.bundle/%@", countryCode];
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:pathForImageResource ofType:@"png"];
    if (imagePath && ![imagePath isEqualToString:@""]) {
        UIImage *image = [UIImage imageNamed:imagePath];
        if (image) {
            UIImageView *flagView = (UIImageView *) [self.countryTextField.leftView viewWithTag:kFlagViewTag];
            flagView.image = image;
        }
    }
    
    self.countryTextField.text = countryCode;
    [self validateState:self.stateTextField.text];
    [self validatePostalCode:self.postalTextField.text];
    if (setPicker) [self.countryPicker setSelectedCountryCode:countryCode];
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
    
//    [self setExpirationOutletTextAndPickerValues];
}

- (void)setExpirationOutletTextAndPickerValues {
    BOOL monthIsGood = NO;
    BOOL yearIsGood = NO;
    
    NSInteger savedExpMonth = [self.paymentDetails.expirationMonth integerValue];
    if (savedExpMonth > 0 && savedExpMonth < 13) {
        monthIsGood = YES;
        [self.expirationPicker selectRow:savedExpMonth inComponent:0 animated:NO];
    } else {
        [self.expirationPicker selectRow:0 inComponent:0 animated:NO];
    }
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth|NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger savedExpYear = [self.paymentDetails.expirationYear integerValue];
    NSInteger layerCake = savedExpYear - [components year];
    if (layerCake >= 0 && layerCake < 1000) {
        yearIsGood = YES;
        [self.expirationPicker selectRow:(savedExpYear - [components year] + 1) inComponent:1 animated:NO];
    } else {
        [self.expirationPicker selectRow:0 inComponent:1 animated:NO];
    }
    
    if (self.paymentDetails.cardNumber && monthIsGood && yearIsGood) {
        NSArray *monthSymbols = [[[NSDateFormatter alloc] init] monthSymbols];
        NSInteger mnInt = savedExpMonth - 1;
        self.expirationOutlet.text = [NSString stringWithFormat:@"%@ %@", monthSymbols[mnInt], self.paymentDetails.expirationYear];
    } else {
        self.expirationOutlet.text = nil;
    }
}

- (void)updateTextInExpirationOutlet {
    NSString *ms = [self pickerView:self.expirationPicker titleForRow:[self.expirationPicker selectedRowInComponent:0] forComponent:0];
    ms = [ms componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]][0];
    NSString *ys = [self pickerView:self.expirationPicker titleForRow:[self.expirationPicker selectedRowInComponent:1] forComponent:1];
    
    if (!ms || !ys) {
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

#pragma mark CountryPickerDelegate method

- (void)countryPicker:(CountryPicker *)picker didSelectCountryWithName:(NSString *)name code:(NSString *)code {
    UIView *guestDetailsView = [self.view viewWithTag:kGuestDetailsViewTag];
    UIView *paymentDetailsView = [self.view viewWithTag:kPaymentDetailsViewTag];
    
    if (guestDetailsView) {
        NSString *callingCodesPath = [[NSBundle mainBundle] pathForResource:@"InternationalCallingCodes" ofType:@"plist"];
        NSDictionary *callingCodesDict = [NSDictionary dictionaryWithContentsOfFile:callingCodesPath];
        
        UIImageView *flagView = (UIImageView *) [self.phoneCountryContainer.leftView viewWithTag:kFlagViewTag];
        
        NSString *pathForImageResource = [NSString stringWithFormat:@"CountryPicker.bundle/%@", code];
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:pathForImageResource ofType:@"png"];
        if (nil != imagePath && ![imagePath isEqualToString:@""]) {
            UIImage *image = [UIImage imageNamed:imagePath];
            if (nil != image) {
                flagView.image = image;
            }
        }
        
        id callingCode = [callingCodesDict objectForKey:[code lowercaseString]];
        if (nil != callingCode && [callingCode isKindOfClass:[NSString class]]) {
            self.phoneCountryContainer.text = [@"+" stringByAppendingString:callingCode];
        }
        
        self.selectedInternationalCallingCountryCode = code;
    }
    
    if (paymentDetailsView) {
        [self setTheCountryCode:code setPicker:NO];
    }
}

#pragma mark StatePickerDelegate method

- (void)statePicker:(StatePickerView *)picker didSelectStateWithName:(NSString *)name code:(NSString *)code {
    self.stateTextField.text = code;
    [self validateState:code];
}

#pragma mark PreBookConfirmDelegate methods

- (void)clickTotalAmountLbl {
    [self loadPriceDetailsPopup:nil];
}

- (void)clickAcknowledgeCancellationPolicyLbl {
    __weak UIView *nrl = [self.view viewWithTag:kRoomNonRefundLongTag];
    [self loadInfoDetailsPopup:nrl.gestureRecognizers.firstObject];
}

- (void)cancelBooking {
    [self dropBookConfirmView];
}

- (void)confirmBooking {
    [self loadCVVView];
}

#pragma mark Animation methods

- (void)loadDaSpinner {
    if (_preparedToDropSpinner) {
        return;
    }
    
    AppDelegate *ad = [[UIApplication sharedApplication] delegate];
    [ad loadDaSpinner];
    [self performSelector:@selector(dropDaSpinner) withObject:nil afterDelay:0.7f];
}

- (void)dropDaSpinner {
    if (!_preparedToDropSpinner) {
        return;
    }
    AppDelegate *ad = [[UIApplication sharedApplication] delegate];
    [ad dropDaSpinnerAlreadyWithForce:NO];
}

- (void)loadRoomDetailsView {
    __weak typeof(self) weakSelf = self;
    __weak UIView *tvp = self.tableViewPopOut;
    __weak UIView *cv = [tvp viewWithTag:kAvailRoomCellContViewTag];
    __weak UIView *borderView = [cv viewWithTag:kAvailRoomBorderViewTag];
    __weak UIView *riv = [borderView viewWithTag:kRoomImageViewTag];
    __weak UIView *ivc = [borderView viewWithTag:kImageViewBottomCoverTag];
    __weak UIView *gic = [borderView viewWithTag:kPriceGradientCoverTag];
    __weak UIView *cgc = [borderView viewWithTag:kBottomGradientCoverTag];
    __weak UIView *rtd = [borderView viewWithTag:kRoomTypeDescViewTag];
    __weak UIView *vap = [borderView viewWithTag:kRoomValueAddTag];
    __weak UIView *vai = vap.subviews.firstObject;
    __weak UIView *rtl = [borderView viewWithTag:kRoomRateViewTag];
    __weak UIView *tal = [borderView viewWithTag:kRoomTotalViewTag];
    __weak UIView *pnt = [borderView viewWithTag:kRoomPerNightTag];
    __weak UIView *nrl = [borderView viewWithTag:kRoomNonRefundViewTag];
    __weak UIView *nrr = [borderView viewWithTag:kRoomNonRefundLongTag];
    __weak UIView *rtdl = [borderView viewWithTag:kRoomTypeDescrLongTag];
    __weak UIView *rtv = self.roomsTableViewOutlet;
    __weak UIView *ibo = self.inputBookOutlet;
    
    [self.view addSubview:tvp];
    tvp.frame = self.rectOfCellInSuperview;
    self.rectOfAvailRoomContView = cv.frame;
    tvp.hidden = NO;
    ibo.hidden = NO;
    
    NavigationView *nv = (NavigationView *) [self.view viewWithTag:kNavigationViewTag];
    [self.view bringSubviewToFront:nv];
    [nv animateToCancel];
    
    self.bedTypeButton.alpha = self.smokingButton.alpha = rtdl.alpha = 0.0f;
    tal.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(60.0f, -(tvp.frame.size.height/0.80f)), 0.001f, 0.001f);
    nrr.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0.0f, -(tvp.frame.size.height/0.95f)), 0.001f, 0.001f);
    rtdl.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0.0f, -(tvp.frame.size.height/1.0f)), 0.001f, 0.001f);
    self.bedTypeButton.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0.0f, -(tvp.frame.size.height/0.55)), 0.001f, 0.001f);
    self.smokingButton.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0.0f, -(tvp.frame.size.height/0.55f)), 0.001f, 0.001f);
    
    [UIView animateWithDuration:kSrAnimationDuration delay:0.0 options:kLoadDropRoomDetailsAnimationCurve animations:^{
        tvp.frame = CGRectMake(0.0f, 64.0f, 320.0f, 400.0f);
        cv.frame = CGRectMake(0, 0, tvp.bounds.size.width, tvp.bounds.size.height);
        borderView.frame = CGRectMake(2.0f, 2.0f, cv.frame.size.width - 4.0f, cv.frame.size.height - 4.0f);
        riv.frame = CGRectMake(0, 0, 316, 210);
        ivc.frame = CGRectMake(0, 210, 316, 61);
        gic.frame = CGRectMake(0, 210, 316, 30);
        cgc.frame = CGRectMake(0, 126, 316, 84);
        rtd.frame = CGRectMake(3, 188, 190, 53);
        vap.frame = CGRectMake(284, 207, 27, 27);
        vai.frame = vap.bounds;
        rtl.frame = CGRectMake(200, 230, 112, 22);
        rtl.alpha = 0.0f;
        tal.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, 0), 1.0f, 1.0f);
        tal.alpha = 1.0f;
        pnt.frame = CGRectMake(262, 248, 50, 15);
        pnt.alpha = 0.0f;
        nrl.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0.0f, 160), 0.001f, 0.001f);
        nrr.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, 0), 1.0f, 1.0f);
        rtdl.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, 0), 1.0f, 1.0f);
        rtv.transform = CGAffineTransformMakeScale(0.01, 0.01);
        ibo.transform = [weakSelf shownGuestInputTransform];
        weakSelf.bedTypeButton.alpha = weakSelf.smokingButton.alpha = rtdl.alpha = 1.0f;
        weakSelf.bedTypeButton.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, 0), 1.0f, 1.0f);
        weakSelf.smokingButton.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, 0), 1.0f, 1.0f);
    } completion:^(BOOL finished) {
        rtv.hidden = YES;
    }];
}

- (void)dropRoomDetailsView:(id)sender {
    __weak typeof(self) weakSelf = self;
    __weak UIView *tvp = self.bedTypeButton.superview;
    __weak UIView *cv = [tvp viewWithTag:kAvailRoomCellContViewTag];
    __weak UIView *borderView = [cv viewWithTag:kAvailRoomBorderViewTag];
    __weak UIView *riv = [borderView viewWithTag:kRoomImageViewTag];
    __weak UIView *ivc = [borderView viewWithTag:kImageViewBottomCoverTag];
    __weak UIView *gic = [borderView viewWithTag:kPriceGradientCoverTag];
    __weak UIView *cgc = [borderView viewWithTag:kBottomGradientCoverTag];
    __weak UIView *rtd = [borderView viewWithTag:kRoomTypeDescViewTag];
    __weak UIView *vap = [borderView viewWithTag:kRoomValueAddTag];
    __weak UIView *vai = vap.subviews.firstObject;
    __weak UIView *rtl = [borderView viewWithTag:kRoomRateViewTag];
    __weak UIView *tal = [borderView viewWithTag:kRoomTotalViewTag];
    __weak UIView *pnt = [borderView viewWithTag:kRoomPerNightTag];
    __weak UIView *nrl = [borderView viewWithTag:kRoomNonRefundViewTag];
    __weak UIView *nrr = [borderView viewWithTag:kRoomNonRefundLongTag];
    __weak UIView *rtdl = [borderView viewWithTag:kRoomTypeDescrLongTag];
    __weak UIView *rtv = self.roomsTableViewOutlet;
    __weak UIView *ibo = self.inputBookOutlet;
    self.expandedIndexPath = nil;
    
    rtv.hidden = NO;
    [self tuiBedTypeDone:nil];
    NavigationView *nv = (NavigationView *) [self.view viewWithTag:kNavigationViewTag];
    [self.view bringSubviewToFront:nv];
    [nv animateToBack];
    
    [UIView animateWithDuration:kSrAnimationDuration delay:0.0 options:kLoadDropRoomDetailsAnimationCurve animations:^{
        weakSelf.bedTypeButton.alpha = weakSelf.smokingButton.alpha = rtdl.alpha = 0.0f;
        tal.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(80.0f, -(tvp.frame.size.height/2.3f)), 0.001f, 0.001f);
        nrr.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0.0f, -(tvp.frame.size.height/2.9f)), 0.001f, 0.001f);
        rtdl.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0.0f, -(tvp.frame.size.height/1.9f)), 0.001f, 0.001f);
        weakSelf.bedTypeButton.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0.0f, -(tvp.frame.size.height/1.5f)), 0.001f, 0.001f);
        weakSelf.smokingButton.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0.0f, -(tvp.frame.size.height/1.5f)), 0.001f, 0.001f);
        tvp.frame = weakSelf.rectOfCellInSuperview;
        cv.frame = weakSelf.rectOfAvailRoomContView;
        borderView.frame = CGRectMake(2.0f, 2.0f, weakSelf.rectOfAvailRoomContView.size.width - 4.0f, weakSelf.rectOfAvailRoomContView.size.height - 4.0f);
        riv.frame = CGRectMake(0, -71, 316, 210);
        ivc.frame = CGRectMake(0, 84, 316, 55);
        gic.frame = CGRectMake(0, 0, 316, 84);
//        cgc.alpha = 0.0f;
        cgc.frame = CGRectMake(0, 0, 316, 84);
        rtd.frame = CGRectMake(3, 71, 190, 53);
        vap.frame = CGRectMake(294, 52, 19, 19);
        vai.frame = vap.bounds;
        rtl.frame = CGRectMake(200, 69, 112, 22);
        rtl.alpha = 1.0f;
        pnt.frame = CGRectMake(262, 87, 50, 15);
        pnt.alpha = 1.0f;
        nrl.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, 0), 1.0f, 1.0f);
        rtv.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        ibo.transform = [weakSelf hiddenGuestInputTransform];
    } completion:^(BOOL finished) {
        tvp.hidden = YES;
        ibo.hidden = YES;
    }];
}

- (void)loadGuestDetailsView {
    __weak UIView *guestDetailsView = self.guestDetailsView;
    [self.view addSubview:guestDetailsView];
    guestDetailsView.frame = CGRectMake(0, 64, 320, 568);
    guestDetailsView.backgroundColor = kWotaColorOne();
    [[guestDetailsView subviews] makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:(id)kWotaColorOne()];
    
    NavigationView *nv = (NavigationView *) [self.view viewWithTag:kNavigationViewTag];
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    b.frame = nv.titleView.bounds;
    b.tag = kWhyThisInfoTag;
    [b addTarget:self action:@selector(loadInfoDetailsPopup:) forControlEvents:UIControlEventTouchUpInside];
    [b setShowsTouchWhenHighlighted:YES];
    [b setTitle:@"Why this info ℹ️" forState:UIControlStateNormal];
    [nv replaceTitleViewContainer:b];
    [nv animateToSecondCancel];
    [nv rightViewAddCheckMark];
    
    CGPoint gboCenter = [self.view convertPoint:self.guestButtonOutlet.center fromView:self.inputBookOutlet];
    CGFloat fromX = gboCenter.x - guestDetailsView.center.x;
    CGFloat fromY = gboCenter.y - guestDetailsView.center.y;
    CGAffineTransform fromTransform = CGAffineTransformMakeTranslation(fromX, fromY);
    guestDetailsView.transform = CGAffineTransformScale(fromTransform, 0.01f, 0.01f);
    
    GuestInfo *gi = [GuestInfo singleton];
    self.firstNameOutlet.text = gi.firstName;
    self.lastNameOutlet.text = gi.lastName;
    self.emailOutlet.text = gi.email;
    self.phoneOutlet.text = gi.phoneNumber;
    
    [self validateFirstName:self.firstNameOutlet.text];
    [self validateLastName:self.lastNameOutlet.text];
    [self validateEmailAddress:self.emailOutlet.text withNoGoColor:NO];
    if (self.isValidEmail) {
        self.belowEmailContainerOutlet.frame = CGRectMake(0, 74, 316, 138);
        [guestDetailsView sendSubviewToBack:self.belowEmailContainerOutlet];
        self.isValidConfirmEmail = YES;
        [self enableOrDisableRightBarButtonItemForGuest];
        self.confirmEmailOutlet.delegate = nil;
    } else {
        self.belowEmailContainerOutlet.frame = CGRectMake(0, 109, 316, 138);
        self.confirmEmailOutlet.delegate = self;
    }
    [self validatePhone:self.phoneOutlet.text];
    
    [self setupInternationalCallingCodes];
    
    if ([self isWeGoodForGuest]) {
        self.deleteUserOutlet.hidden = NO;
        [self.deleteUserOutlet removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [self.deleteUserOutlet addTarget:self action:@selector(initiateDeleteUser:) forControlEvents:UIControlEventTouchUpInside ];
        [self.deleteUserOutlet setTitle:@"Delete This Guest" forState:UIControlStateNormal];
    } else {
        self.deleteUserOutlet.hidden = YES;
        self.cancelUserDeletionOutlet.hidden = YES;
    }
    
    self.firstNameOutlet.userInteractionEnabled = YES;
    self.lastNameOutlet.userInteractionEnabled = YES;
    self.emailOutlet.userInteractionEnabled = YES;
    self.confirmEmailOutlet.userInteractionEnabled = YES;
    self.phoneOutlet.userInteractionEnabled = YES;
    self.phoneCountryContainer.userInteractionEnabled = YES;
    
    self.firstNameOutlet.textColor = [UIColor blackColor];
    self.lastNameOutlet.textColor = [UIColor blackColor];
    self.emailOutlet.textColor = [UIColor blackColor];
    self.confirmEmailOutlet.textColor = [UIColor blackColor];
    self.phoneOutlet.textColor = [UIColor blackColor];
    self.phoneCountryContainer.textColor = [UIColor blackColor];
    UIImageView *flagView = (UIImageView *) [self.phoneCountryContainer.leftView viewWithTag:kFlagViewTag];
    flagView.backgroundColor = [UIColor clearColor];
    flagView.alpha = 1.0f;
    
    __weak typeof(self) wes = self;
    _view_details_type = GUEST_DETAILS;
    [UIView animateWithDuration:kSrAnimationDuration animations:^{
        guestDetailsView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        guestDetailsView.backgroundColor = [UIColor whiteColor];
        [[guestDetailsView subviews] makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:(id)[UIColor whiteColor]];
        [[wes.belowEmailContainerOutlet subviews] makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:(id)[UIColor whiteColor]];
    } completion:^(BOOL finished) {
        [self.firstNameOutlet becomeFirstResponder];
    }];
}

- (void)dropGuestDetailsView:(id)sender {
    __weak UIView *guestDetailsView = self.guestDetailsView;
    GuestInfo *gi = [GuestInfo singleton];
    if ([sender isKindOfClass:[NSString class]] && [sender isEqualToString:@"FromRightNav"]) {
        gi.firstName = self.firstNameOutlet.text;
        gi.lastName = self.lastNameOutlet.text;
        gi.email = self.emailOutlet.text;
        gi.phoneNumber = self.phoneOutlet.text;
        NSString *icc = [self.phoneCountryContainer.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
        gi.internationalCallingCode = icc;
        gi.countryCode = self.selectedInternationalCallingCountryCode;
        [self updateGuestDetailsButtonTitle];
    }
    
    if (sender == self.deleteUserOutlet) {
        self.firstNameOutlet.text = nil;
        self.lastNameOutlet.text = nil;
        self.emailOutlet.text = nil;
        self.phoneOutlet.text = nil;
        self.confirmEmailOutlet.text = nil;
        [GuestInfo deleteGuest:gi];
        [self updateGuestDetailsButtonTitle];
        [self.deleteUserOutlet setTitle:@"Delete This Guest" forState:UIControlStateNormal];
    }
    
    CGPoint gboCenter = [self.view convertPoint:self.guestButtonOutlet.center fromView:self.inputBookOutlet];
    CGFloat toX = gboCenter.x - guestDetailsView.center.x;
    CGFloat toY = gboCenter.y - guestDetailsView.center.y;
    __block CGAffineTransform toTransform = CGAffineTransformMakeTranslation(toX, toY);
    
    [self.view endEditing:YES];
    
    NavigationView *nv = (NavigationView *) [self.view viewWithTag:kNavigationViewTag];
    [nv animateRevertToFirstCancel];
    [nv animateRevertToWhereToContainer:kWhyThisInfoTag];
    [nv rightViewRemoveCheckMark];
    
    [UIView animateWithDuration:kSrAnimationDuration animations:^{
        guestDetailsView.transform = CGAffineTransformScale(toTransform, 0.01f, 0.01f);
        guestDetailsView.backgroundColor = kWotaColorOne();
        [[guestDetailsView subviews] makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:(id)kWotaColorOne()];
    } completion:^(BOOL finished) {
        [guestDetailsView removeFromSuperview];
        guestDetailsView.transform = CGAffineTransformIdentity;
    }];
}

- (void)loadPaymentDetailsView {
    NavigationView *nv = (NavigationView *) [self.view viewWithTag:kNavigationViewTag];
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    b.frame = nv.titleView.bounds;
    b.tag = kCardSecurityTag;
    [b addTarget:self action:@selector(loadInfoDetailsPopup:) forControlEvents:UIControlEventTouchUpInside];
    [b setShowsTouchWhenHighlighted:YES];
    [b setTitle:@"Card Security ℹ️" forState:UIControlStateNormal];
    [nv replaceTitleViewContainer:b];
    [nv animateToSecondCancel];
    [nv rightViewAddCheckMark];
    
    __weak UIView *paymentDetailsView = self.paymentDetailsView;
    paymentDetailsView.frame = CGRectMake(0, 64, 320, 568);
    paymentDetailsView.backgroundColor = kWotaColorOne();
    [[paymentDetailsView subviews] makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:(id)kWotaColorOne()];
    
    CGPoint pboCenter = [self.view convertPoint:self.paymentButtonOutlet.center fromView:self.inputBookOutlet];
    CGFloat fromX = pboCenter.x - paymentDetailsView.center.x;
    CGFloat fromY = pboCenter.y - paymentDetailsView.center.y;
    CGAffineTransform fromTransform = CGAffineTransformMakeTranslation(fromX, fromY);
    paymentDetailsView.transform = CGAffineTransformScale(fromTransform, 0.01f, 0.01f);
    
    [self.view addSubview:paymentDetailsView];
    
    PaymentDetails *pd = self.paymentDetails = self.paymentDetails ? : [PaymentDetails new];
    
    self.ccNumberOutlet.showsCardLogo = YES;
    self.ccNumberOutlet.cardNumber = pd.cardNumber ? : @"";
    self.cardholderFirstOutlet.text = pd.cardHolderFirstName;
    self.cardholderLastOutlet.text = pd.cardHolderLastName;
    self.addressTextFieldOutlet.text = pd.billingAddress.address1;
    self.cityTextField.text = pd.billingAddress.city;
//    self.stateTextField.text = pd.billingAddress.stateProvinceCode;
    self.postalTextField.text = pd.billingAddress.postalCode;
    [self setTheCountryCode:pd.billingAddress.countryCode setPicker:YES];
    [self setExpirationOutletTextAndPickerValues];
    
//    if (nil != pd.cardHolderFirstName && nil != pd.cardHolderLastName) {
//        self.cardholderFirstOutlet.text = [NSString stringWithFormat:@"%@ %@", pd.cardHolderFirstName, pd.cardHolderLastName];
//    }
    
    [self validateCreditCardNumber:self.ccNumberOutlet.cardNumber];
    [self validateExpiration];
    [self validateCardholder:self.cardholderFirstOutlet.text];
    [self validateCardholderLast:self.cardholderLastOutlet.text];
    [self validateStreetAddress:self.addressTextFieldOutlet.text];
    [self validateCity:self.cityTextField.text];
    [self validateState:self.stateTextField.text];
    [self validatePostalCode:self.postalTextField.text];
    
    _view_details_type = PAYMENT_DETAILS;
    __weak typeof(self) wes = self;
    [UIView animateWithDuration:kSrAnimationDuration animations:^{
        paymentDetailsView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        paymentDetailsView.backgroundColor = [UIColor whiteColor];
        [[paymentDetailsView subviews] makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:(id)[UIColor whiteColor]];
    } completion:^(BOOL finished) {
        [wes.ccNumberOutlet becomeFirstResponder];
    }];
}

- (void)dropPaymentDetailsView:(id)sender {
    [self.view endEditing:YES];
    PaymentDetails *pd = self.paymentDetails;
    
    if ([sender isKindOfClass:[NSString class]] && [sender isEqualToString:@"FromRightNav"]) {
        pd.cardNumber = self.ccNumberOutlet.cardNumber;
        pd.cardImage = self.ccNumberOutlet.cardLogoImageView.image;
        [self updatePaymentDetailsButtonTitle];
        pd.eanCardType = self.ccNumberOutlet.eanType;
        pd.cardHolderFirstName = self.cardholderFirstOutlet.text;
        pd.cardHolderLastName = self.cardholderLastOutlet.text;
        pd.billingAddress.address1 = self.addressTextFieldOutlet.text;
        pd.billingAddress.city = self.cityTextField.text;
        pd.billingAddress.countryCode = self.countryTextField.text;
        pd.billingAddress.stateProvinceCode = self.stateTextField.text;
        pd.billingAddress.postalCode = self.postalTextField.text;
        [self saveDaExpiration];
        
//        NSArray *chn = [self parseTextFieldText:self.cardholderFirstOutlet.text];
//        if ([chn count] >= 2) {
//            pd.cardHolderFirstName = chn[0];
//            pd.cardHolderLastName = chn[1];
//        }
    }
    
//    if (sender == self.deleteCardOutlet) {
//        self.ccNumberOutlet.cardNumber = nil;
//        self.selectedBillingAddress = nil;
//        [self.expirationPicker selectRow:0 inComponent:0 animated:NO];
//        [self.expirationPicker selectRow:0 inComponent:1 animated:NO];
//        self.expirationOutlet.text = nil;
//        self.cardholderOutlet.text = nil;
//        [PaymentDetails deleteCard:pd];
//        [self updatePaymentDetailsButtonTitle];
//    }
    
    __weak UIView *paymentDetailsView = self.paymentDetailsView;
    
    CGPoint pboCenter = [self.view convertPoint:self.paymentButtonOutlet.center fromView:self.inputBookOutlet];
    CGFloat toX = pboCenter.x - paymentDetailsView.center.x;
    CGFloat toY = pboCenter.y - paymentDetailsView.center.y;
    __block CGAffineTransform toTransform = CGAffineTransformMakeTranslation(toX, toY);
    
    NavigationView *nv = (NavigationView *) [self.view viewWithTag:kNavigationViewTag];
    [nv animateRevertToFirstCancel];
    [nv animateRevertToWhereToContainer:kCardSecurityTag];
    [nv rightViewRemoveCheckMark];
    
    [UIView animateWithDuration:kSrAnimationDuration animations:^{
        paymentDetailsView.backgroundColor = kWotaColorOne();
        [[paymentDetailsView subviews] makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:(id)kWotaColorOne()];
        paymentDetailsView.transform = CGAffineTransformScale(toTransform, 0.01f, 0.01f);
    } completion:^(BOOL finished) {
        [paymentDetailsView removeFromSuperview];
        paymentDetailsView.transform = CGAffineTransformIdentity;
    }];
}

- (void)loadBookConfirmView {
    NavigationView *nv = (NavigationView *) [self.view viewWithTag:kNavigationViewTag];
    [nv animateToSecondCancel];
    _view_details_type = PREBOOK_CONFIRM;
    
    if (!_preBookConfirmView) {
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"PreBookConfirmView" owner:nil options:nil];
        _preBookConfirmView = views.firstObject;
        [_preBookConfirmView setupTheView];
        _preBookConfirmView.preBookDelegate = self;
        _preBookConfirmView.hotelNameLabel.text = _hotelName;
        _preBookConfirmView.cityStateCountryLabel.text = [self.locationString stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
    }
    
    __weak UIView *pbcv = _preBookConfirmView;
    
    EanAvailabilityHotelRoomResponse *room = [self.tableData objectAtIndex:self.expandedIndexPath.row];
    _preBookConfirmView.roomDescriptionLabel.text = room.roomType.roomTypeDescrition;
    NSNumberFormatter *twoDigit = kPriceTwoDigitFormatter(room.rateInfo.chargeableRateInfo.currencyCode);
    NSString *totalAmt = [twoDigit stringFromNumber:room.rateInfo.chargeableRateInfo.total];
    _preBookConfirmView.totalChargesLabel.text = totalAmt;
    
    CGPoint pboCenter = [self.view convertPoint:self.bookButtonOutlet.center fromView:self.inputBookOutlet];
    CGFloat fromX = pboCenter.x - _preBookConfirmView.center.x;
    CGFloat fromY = pboCenter.y - _preBookConfirmView.center.y;
    CGAffineTransform fromTransform = CGAffineTransformMakeTranslation(fromX, fromY);
    _preBookConfirmView.transform = CGAffineTransformScale(fromTransform, 0.01f, 0.01f);
    
    _preBookConfirmView.checkMark.hidden = YES;
    _preBookConfirmView.confirmButton.enabled = NO;
    _preBookConfirmView.acknowledged = NO;
    [self.view addSubview:_preBookConfirmView];
    
    [UIView animateWithDuration:kSrAnimationDuration animations:^{
        pbcv.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        pbcv.backgroundColor = [UIColor whiteColor];
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)dropBookConfirmView {
    __weak UIView *pbcv = _preBookConfirmView;
    
    CGPoint pboCenter = [self.view convertPoint:self.bookButtonOutlet.center fromView:self.inputBookOutlet];
    CGFloat toX = pboCenter.x - pbcv.center.x;
    CGFloat toY = pboCenter.y - pbcv.center.y;
    __block CGAffineTransform toTransform = CGAffineTransformMakeTranslation(toX, toY);
    
    NavigationView *nv = (NavigationView *) [self.view viewWithTag:kNavigationViewTag];
    [nv animateRevertToFirstCancel];
    [nv animateRevertToWhereToContainer:kCardSecurityTag];
    [nv rightViewRemoveCheckMark];
    
    [UIView animateWithDuration:kSrAnimationDuration animations:^{
        pbcv.transform = CGAffineTransformScale(toTransform, 0.01f, 0.01f);
    } completion:^(BOOL finished) {
        [pbcv removeFromSuperview];
        pbcv.transform = CGAffineTransformIdentity;
    }];
}

- (void)loadCVVView {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"CVVView" owner:self options:nil];
    __weak UIView *cvvView = views.firstObject;
    cvvView.tag = kCVVViewTag;
    cvvView.frame = CGRectMake(20, 80, 280, 230);
    cvvView.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
    [_purchaseButton addTarget:self action:@selector(bookIt) forControlEvents:UIControlEventTouchUpInside];
    [_cancelPurchaseButton addTarget:self action:@selector(dropCVVView) forControlEvents:UIControlEventTouchUpInside];
    _purchaseButton.enabled = NO;
    _cvvTextField.delegate = self;
    cvvView.layer.cornerRadius = WOTA_CORNER_RADIUS;
    
    UIView *ol = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    ol.tag = kCVVOverlayTag;
    ol.backgroundColor = [UIColor blackColor];
    ol.alpha = 0.0f;
    ol.userInteractionEnabled = YES;
    
    [self.view addSubview:ol];
    [self.view bringSubviewToFront:ol];
    [self.view addSubview:cvvView];
    [self.view bringSubviewToFront:cvvView];
    
    [UIView animateWithDuration:kSrQuickAnimationDuration animations:^{
        ol.alpha = 0.7f;
        cvvView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    } completion:^(BOOL finished) {
        [_cvvTextField becomeFirstResponder];
    }];
}

- (void)dropCVVView {
    __weak UIView *cvvView = [self.view viewWithTag:kCVVViewTag];
    __weak UIView *ol = [self.view viewWithTag:kCVVOverlayTag];
    [self.view endEditing:YES];
    [UIView animateWithDuration:kSrQuickAnimationDuration animations:^{
        ol.alpha = 0.0f;
        cvvView.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
    } completion:^(BOOL finished) {
        [ol removeFromSuperview];
        [cvvView removeFromSuperview];
    }];
}

- (void)loadInfoDetailsPopup:(id)sender {
    AudioServicesPlaySystemSound(0x450);
    __block UIView *wayne = [[UIView alloc] initWithFrame:CGRectMake(10, 100, 300, 356)];
    
    NSNumber *daTag = nil;
    UIView *ov = nil;
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        daTag = [NSNumber numberWithInteger:((UITapGestureRecognizer *)sender).view.tag];
        ov = ((UITapGestureRecognizer *)sender).view;
    } else if ([sender isKindOfClass:[UIButton class]]) {
        daTag = [NSNumber numberWithInteger:((UIButton *)sender).tag];
        ov = sender;
    }
    
    wayne.tag = [[self.infoPopupTagDict objectForKey:daTag] integerValue];
    
    wayne.backgroundColor = [UIColor whiteColor];
    wayne.layer.cornerRadius = 8.0f;
    wayne.layer.borderColor = [UIColor blackColor].CGColor;
    wayne.layer.borderWidth = 3.0f;
    
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(13, 12, 200, 30)];
    l.text = [self.infoPopupHeadingDict objectForKey:daTag];
    l.textColor = [UIColor blackColor];
    l.textAlignment = NSTextAlignmentLeft;
    l.backgroundColor = [UIColor clearColor];
    l.font = [UIFont boldSystemFontOfSize:19.0f];
    [wayne addSubview:l];
    
    WotaButton *b = [WotaButton wbWithFrame:CGRectMake(244, 6, 50, 30)];
    [b setTitle:@"Done" forState:UIControlStateNormal];
    [b addTarget:self action:@selector(dropInfoDetailsPopup) forControlEvents:UIControlEventTouchUpInside];
    [wayne addSubview:b];
    
    UITextView *wv = [[UITextView alloc] initWithFrame:CGRectMake(10, 45, 280, 100)];
    wv.editable = NO;
    wv.showsVerticalScrollIndicator = NO;
    wv.layer.borderWidth = 1.0f;
    wv.layer.borderColor = [UIColor blackColor].CGColor;
    wv.layer.cornerRadius = 8.0f;
    wv.font = [UIFont systemFontOfSize:17.0f];
    
    switch ([daTag integerValue]) {
        case kRoomTypeDescrLongTag: {
            wv.text = ((UILabel *)ov).text;
            break;
        }
        case kRoomNonRefundLongTag: {
            EanAvailabilityHotelRoomResponse *room = [self.tableData objectAtIndex:self.expandedIndexPath.row];
            wv.text = room.rateInfo.cancellationPolicy;
            break;
        }
        case kWhyThisInfoTag: {
            wv.text = @"The first and last names must match the guest's photo ID when checking in at the property.\n\nA confirmation email will be sent to the given address upon booking.\n\nYour phone number will only be used by a customer service agent in the event that there is a problem with your reservation.\n\nThis information will be securely stored in your iPhone's Keychain for your future hotel bookings, so that you don't have to retype it. No other apps will have access to this information. And you can change or delete this information at any time.";
            break;
        }
        case kCardSecurityTag: {
            wv.text = @"Your payment information will be securely transmitted for processing. Payment information is not stored or saved.";
            break;
        }
        case kRoomValueAddTag: {
            EanAvailabilityHotelRoomResponse *room = [self.tableData objectAtIndex:self.expandedIndexPath.row];
            for (int j = 0; j < room.valueAddArray.count; j++)
                wv.text = [wv.text stringByAppendingFormat:@"%@%@", j ? @"\n" : @"", room.valueAddArray[j]];
        }
            
        default:
            break;
    }
    
    wv.textColor = [UIColor blackColor];
    wv.backgroundColor = [UIColor whiteColor];
    
    CGFloat fixedWidth = wv.frame.size.width;
    CGSize newSize = [wv sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = wv.frame;
    newFrame.size = CGSizeMake(fixedWidth, fminf(newSize.height + 2, 384));
    wv.frame = newFrame;
    
    CGFloat abc = wv.frame.origin.y + wv.frame.size.height + 10;
    wayne.frame = CGRectMake(10, ((64 + 568 - abc)/2), 300, abc);
    
    [wayne addSubview:wv];
    
    CGFloat fromX = ov.center.x - wayne.center.x;
    CGFloat fromY = ov.center.y - wayne.center.y + 64;
    wayne.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(fromX, fromY), 0.001f, 0.001f);
    
//    wayne.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, 65), 0.001f, 0.001f);
    
    self.navigationController.navigationBar.clipsToBounds = NO;
    self.overlayDisable.alpha = 0.0f;
    self.overlayDisableNav.alpha = 0.0f;
    [self.view addSubview:self.overlayDisable];
    [self.navigationController.navigationBar addSubview:self.overlayDisableNav];
    [self.view bringSubviewToFront:self.overlayDisable];
    [self.navigationController.navigationBar bringSubviewToFront:self.overlayDisableNav];
    [self.view addSubview:wayne];
    [self.view bringSubviewToFront:wayne];
    
    [self.view endEditing:YES];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:kSrAnimationDuration animations:^{
        weakSelf.overlayDisable.alpha = 0.8f;
        weakSelf.overlayDisableNav.alpha = 1.0f;
        weakSelf.navigationController.navigationBar.alpha = 0.3f;
        wayne.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)dropInfoDetailsPopup {
    __weak typeof(self) weakSelf = self;
    __weak UIView *w = [self.view viewWithTag:kInfoDetailPopupRoomDetailsTag] ? : [self.view viewWithTag:kInfoDetailPopupCancelPolicTag] ? : [self.view viewWithTag:kInfoDetailPopupGuestDetailTag] ? : [self.view viewWithTag:kInfoDetailPopupPaymeDetailTag] ? : [self.view viewWithTag:kInfoDetailPopupValueAddDetTag];
    
    __weak UIView *originatingView = nil;/*[self.view viewWithTag:kInfoDetailPopupRoomDetailsTag] ? [self.view viewWithTag:kRoomTypeDescrLongTag] : [self.view viewWithTag:kInfoDetailPopupCancelPolicTag] ? [self.view viewWithTag:kRoomNonRefundLongTag] : nil;*/
    
    NSArray *k = [self.infoPopupTagDict allKeysForObject:[NSNumber numberWithInteger:w.tag]];
    if ([k count] == 1) {
        originatingView = [self.view viewWithTag:[k[0] integerValue]];
    }
    
    CGFloat toX = originatingView.center.x - w.center.x;
    CGFloat toY = originatingView.center.y - w.center.y + 64;
    __block CGAffineTransform toTransform = CGAffineTransformScale(CGAffineTransformMakeTranslation(toX, toY), 0.001f, 0.001f);
    
    [self.currentFirstResponder becomeFirstResponder];
    [UIView animateWithDuration:kSrAnimationDuration animations:^{
        weakSelf.overlayDisable.alpha = 0.0f;
        weakSelf.overlayDisableNav.alpha = 0.0f;
        weakSelf.navigationController.navigationBar.alpha = 1.0f;
        w.transform = toTransform;
    } completion:^(BOOL finished) {
        [weakSelf.overlayDisable removeFromSuperview];
        [weakSelf.overlayDisableNav removeFromSuperview];
        [w removeFromSuperview];
    }];
}

- (void)loadPriceDetailsPopup:(UIGestureRecognizer *)sender {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"PriceDetailsPopupView" owner:self options:nil];
    if (nil == views || [views count] != 1) {
        return;
    }
    
    __block UIView *pdp = views[0];
    pdp.frame = CGRectMake(10, 100, 300, 368);
    pdp.tag = kPriceDetailsPopupTag;
    pdp.backgroundColor = [UIColor whiteColor];
    pdp.layer.masksToBounds = YES;
    pdp.layer.cornerRadius = 8.0f;
    pdp.layer.borderColor = [UIColor blackColor].CGColor;
    pdp.layer.borderWidth = 3.0f;
    
    WotaButton *wc = (WotaButton *)[pdp viewWithTag:9823754];
    [wc addTarget:self action:@selector(dropPriceDetailsPopup) forControlEvents:UIControlEventTouchUpInside];
    
    EanAvailabilityHotelRoomResponse *room = [self.tableData objectAtIndex:self.expandedIndexPath.row];
    self.nrtvd = [[NightlyRateTableViewDelegateImplementation alloc] init];
    self.nrtvd.room = room;
    self.nrtvd.tableData = room.rateInfo.chargeableRateInfo.nightlyRatesArray;
    __weak UITableView *nrtv = (UITableView *) [pdp viewWithTag:19171917];
    nrtv.dataSource = self.nrtvd;
    nrtv.delegate = self.nrtvd;
    nrtv.layer.borderColor = [UIColor blackColor].CGColor;
    nrtv.layer.borderWidth = 2;
    nrtv.layer.cornerRadius = 8.0f;
    [nrtv reloadData];
    
    CGFloat maxTvHeight = [room.rateInfo.sumOfHotelFees doubleValue] == 0 ? 343.0f : 303.0f;
    
    CGFloat nrtvHeight = MIN(nrtv.contentSize.height, maxTvHeight);
    nrtv.frame = CGRectMake(nrtv.frame.origin.x, nrtv.frame.origin.y, nrtv.frame.size.width, nrtvHeight);
    
    NSNumberFormatter *tdf = kPriceTwoDigitFormatter(room.rateInfo.chargeableRateInfo.currencyCode);
    
    UIView *taxesFeesContainer = [pdp viewWithTag:84623089];
    CGRect tfcf = taxesFeesContainer.frame;
    taxesFeesContainer.frame = CGRectMake(tfcf.origin.x, 44.0f + nrtvHeight + 7.0f, tfcf.size.width, tfcf.size.height);
    tfcf = taxesFeesContainer.frame;
    
    UILabel *taxFeeTotal = (UILabel *) [pdp viewWithTag:61094356];
    NSNumber *sc = room.rateInfo.chargeableRateInfo.surchargeTotal;
    taxFeeTotal.text = [sc doubleValue] == 0 ? @"Included" : [tdf stringFromNumber:sc];
    
    if (0 != [room.rateInfo.sumOfHotelFees doubleValue]) {
        UILabel *tfLabel = (UILabel *) [pdp viewWithTag:10854935];
        tfLabel.text = @"Taxes";
        
        UIView *ev = [[UIView alloc] initWithFrame:CGRectMake(tfcf.origin.x, tfcf.origin.y + tfcf.size.height, tfcf.size.width, tfcf.size.height)];
        
        UILabel *evla = [[UILabel alloc] initWithFrame:CGRectMake(136, 0, 153, 19)];
        evla.textAlignment = NSTextAlignmentRight;
        evla.font = [UIFont systemFontOfSize:16.0f];
        evla.text = [tdf stringFromNumber:room.rateInfo.chargeableRateInfo.total];
        [ev addSubview:evla];
        
        UILabel *evl = [[UILabel alloc] initWithFrame:CGRectMake(11, 0, 124, 19)];
        evl.textAlignment = NSTextAlignmentLeft;
        evl.font = [UIFont systemFontOfSize:16.0f];
        NSString *ft = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
        evl.text = [NSString stringWithFormat:@"Due %@ Now", ft];
        [ev addSubview:evl];
        
        [pdp addSubview:ev];
        tfcf = ev.frame;
        
        UIView *sv = [[UIView alloc] initWithFrame:CGRectMake(tfcf.origin.x, tfcf.origin.y + tfcf.size.height-5, tfcf.size.width, tfcf.size.height)];
        
        UILabel *svla = [[UILabel alloc] initWithFrame:CGRectMake(149, 0, 140, 19)];
        svla.textAlignment = NSTextAlignmentRight;
        svla.font = [UIFont systemFontOfSize:16.0f];
        svla.text = [tdf stringFromNumber:room.rateInfo.sumOfHotelFees];
        [sv addSubview:svla];
        
        UILabel *svl = [[UILabel alloc] initWithFrame:CGRectMake(11, 0, 137, 19)];
        svl.textAlignment = NSTextAlignmentLeft;
        svl.font = [UIFont systemFontOfSize:16.0f];
        svl.text = @"Fees Due at Hotel";
        [sv addSubview:svl];
        
        [pdp addSubview:sv];
        tfcf = sv.frame;
    }
    
    UIView *totalContainer = [pdp viewWithTag:396458172];
    CGRect tcf = totalContainer.frame;
    totalContainer.frame = CGRectMake(tcf.origin.x, tfcf.origin.y + tfcf.size.height + 3.0f, tcf.size.width, tcf.size.height);
    tcf = totalContainer.frame;
    
    UILabel *tripTotal = (UILabel *) [pdp viewWithTag:1947284];
    tripTotal.text = [tdf stringFromNumber:room.rateInfo.totalPlusHotelFees];
    
    pdp.frame = CGRectMake(10, ((64 + 568 - tcf.origin.y - tcf.size.height)/2), 300, tcf.origin.y + tcf.size.height);
    pdp.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(75, 15), 0.001f, 0.001f);
    
    self.navigationController.navigationBar.clipsToBounds = NO;
    self.overlayDisable.alpha = 0.0f;
    self.overlayDisableNav.alpha = 0.0f;
    [self.view addSubview:self.overlayDisable];
    [self.navigationController.navigationBar addSubview:self.overlayDisableNav];
    [self.view bringSubviewToFront:self.overlayDisable];
    [self.navigationController.navigationBar bringSubviewToFront:self.overlayDisableNav];
    [self.view addSubview:pdp];
    [self.view bringSubviewToFront:pdp];
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:kSrAnimationDuration animations:^{
        weakSelf.overlayDisable.alpha = 0.8f;
        weakSelf.overlayDisableNav.alpha = 1.0f;
        weakSelf.navigationController.navigationBar.alpha = 0.3f;
        pdp.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)dropPriceDetailsPopup {
    __weak typeof(self) weakSelf = self;
    __weak UIView *w = [self.view viewWithTag:kPriceDetailsPopupTag];
    [UIView animateWithDuration:kSrAnimationDuration animations:^{
        weakSelf.overlayDisable.alpha = 0.0f;
        weakSelf.overlayDisableNav.alpha = 0.0f;
        weakSelf.navigationController.navigationBar.alpha = 1.0f;
        w.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(75, 15), 0.001f, 0.001f);
    } completion:^(BOOL finished) {
        [weakSelf.overlayDisable removeFromSuperview];
        [weakSelf.overlayDisableNav removeFromSuperview];
        [w removeFromSuperview];
    }];
}

#pragma mark Validation methods

- (void)enableOrDisableRightBarButtonItemForGuest {
    NavigationView *nv = (NavigationView *) [self.view viewWithTag:kNavigationViewTag];
    
    if ([self isWeGoodForGuest]) {
        [nv rightViewEnableCheckMark];
    } else {
        [nv rightViewDisableCheckMark];
    }
}

- (BOOL)isWeGoodForGuest {
    return self.isValidFirstName && self.isValidLastName && self.isValidEmail && self.isValidConfirmEmail && self.isValidPhone;
}

- (BOOL)validateGuestDetails {
    GuestInfo *gi = [GuestInfo singleton];
    [self validateFirstName:gi.firstName];
    [self validateLastName:gi.lastName];
    [self validateEmailAddress:gi.email withNoGoColor:NO];
    self.isValidConfirmEmail = self.isValidEmail;
    [self validatePhone:gi.phoneNumber];
    return [self isWeGoodForGuest];
}

- (void)validateFirstName:(NSString *)firstName {
    if (!stringIsEmpty(firstName)) {
        self.isValidFirstName = YES;
    } else {
        self.isValidFirstName = NO;
    }
    [self enableOrDisableRightBarButtonItemForGuest];
}

- (void)validateLastName:(NSString *)lastName {
    if (!stringIsEmpty(lastName)) {
        self.isValidLastName = YES;
    } else {
        self.isValidLastName = NO;
    }
    [self enableOrDisableRightBarButtonItemForGuest];
}

- (void)validateEmailAddress:(NSString *)emailString withNoGoColor:(BOOL)wngc {
    // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    // SOF: http://stackoverflow.com/questions/3139619/check-that-an-email-address-is-valid-on-ios
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    self.isValidEmail = [emailTest evaluateWithObject:emailString];
    if (wngc && !self.isValidEmail) {
        self.emailOutlet.backgroundColor = kColorNoGo();
    } else {
        self.emailOutlet.backgroundColor = [UIColor whiteColor];
        self.confirmEmailOutlet.placeholder = @"Confirm Email";
    }
    [self enableOrDisableRightBarButtonItemForGuest];
}

- (void)validateConfirmEmailAddress:(NSString *)ces whileLeaving:(BOOL)leaving {
    self.isValidConfirmEmail = [ces isEqualToString:self.emailOutlet.text];
    if (self.isValidConfirmEmail) {
        self.confirmEmailOutlet.backgroundColor = [UIColor whiteColor];
    } else if (leaving) {
        self.confirmEmailOutlet.backgroundColor = kColorNoGo();
    } else if ([ces isEqualToString:[self.emailOutlet.text substringToIndex:MIN([ces length], [self.emailOutlet.text length])]]) {
        self.confirmEmailOutlet.backgroundColor = [UIColor whiteColor];
    } else {
        self.confirmEmailOutlet.backgroundColor = kColorNoGo();
    }
    [self enableOrDisableRightBarButtonItemForGuest];
}

- (void)validatePhone:(NSString *)phoneNumber {
    //Numbers must be at least 5 digits long. Restrict characters to 0-9, +, -, and ( ).
    if ([phoneNumber length] >= 5) {
        self.isValidPhone = YES;
    } else {
        self.isValidPhone = NO;
    }
    [self enableOrDisableRightBarButtonItemForGuest];
}

- (void)enableOrDisableRightBarButtonItemForPayment {
    NavigationView *nv = (NavigationView *) [self.view viewWithTag:kNavigationViewTag];
    
    if ([self isWeGoodForCredit]) {
        [nv rightViewEnableCheckMark];
    } else {
        [nv rightViewDisableCheckMark];
    }
}

- (BOOL)isWeGoodForCredit {
    return self.isValidCreditCard && self.isValidBillingAddress && self.isValidExpiration && self.isValidCardHolderFirst && self.isValidCardHolderLast;
}

- (void)validateCreditCardNumber:(NSString *)cardNumber {
    if ([[PTKCardNumber cardNumberWithString:cardNumber] isValid]) {
        self.ccNumberOutlet.backgroundColor = [UIColor whiteColor];
        self.isValidCreditCard = YES;
    } else if ([[PTKCardNumber cardNumberWithString:cardNumber] isGreaterThanOrEqualValidLength]) {
        self.ccNumberOutlet.backgroundColor = kColorNoGo();
        self.isValidCreditCard = NO;
    } else {
        self.ccNumberOutlet.backgroundColor = [UIColor whiteColor];
        self.isValidCreditCard = NO;
    }
    
    [self enableOrDisableRightBarButtonItemForPayment];
}

- (void)validateExpiration {
    if (stringIsEmpty(self.expirationOutlet.text)) {
        self.expirationOutlet.backgroundColor = [UIColor whiteColor];
        self.isValidExpiration = NO;
        [self enableOrDisableRightBarButtonItemForPayment];
        return;
    }
    
    NSArray *expArr = [self.expirationOutlet.text componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    
    if (nil == expArr || [expArr count] != 2) {
        self.expirationOutlet.backgroundColor = kColorNoGo();
        self.isValidExpiration = NO;
        [self enableOrDisableRightBarButtonItemForPayment];
        return;
    }
    
    NSString *expMonth = expArr[0];
    NSString *expYear = expArr[1];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM"];
    dateFormatter.locale = [NSLocale currentLocale];
    NSDate *daDate = [dateFormatter dateFromString:expMonth];
    NSInteger intExpMonth = [[NSCalendar currentCalendar] component:NSCalendarUnitMonth fromDate:daDate];
    
    NSInteger intExpYear = [expYear integerValue];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth|NSCalendarUnitYear fromDate:[NSDate date]];
    
    if (intExpMonth <= 0 || intExpMonth >= 13 || intExpYear < [components year]) {
        self.expirationOutlet.backgroundColor = kColorNoGo();
        self.isValidExpiration = NO;
    } else if (intExpYear > [components year]) {
        self.expirationOutlet.backgroundColor = [UIColor whiteColor];
        self.isValidExpiration = YES;
    } else if (intExpMonth >= [components month]) {
        self.expirationOutlet.backgroundColor = [UIColor whiteColor];
        self.isValidExpiration = YES;
    } else {
        self.expirationOutlet.backgroundColor = kColorNoGo();
        self.isValidExpiration = NO;
    }
    
    [self enableOrDisableRightBarButtonItemForPayment];
}

- (void)validateCardholder:(NSString *)cardHolderFirst {
    if (!stringIsEmpty(cardHolderFirst)) self.isValidCardHolderFirst = YES;
    else self.isValidCardHolderFirst = NO;
    [self enableOrDisableRightBarButtonItemForPayment];
}

- (void)validateCardholderLast:(NSString *)cardHolderLast {
    if (!stringIsEmpty(cardHolderLast)) self.isValidCardHolderLast = YES;
    else self.isValidCardHolderLast = NO;
    [self enableOrDisableRightBarButtonItemForPayment];
}

- (void)validateStreetAddress:(NSString *)sa {
    if (!stringIsEmpty(sa)) self.isValidStreetAddress = YES;
    else self.isValidStreetAddress = NO;
    [self enableOrDisableRightBarButtonItemForPayment];
}

- (void)validateCity:(NSString *)city {
    if (!stringIsEmpty(city)) self.isValidCity = YES;
    else self.isValidCity = NO;
    [self enableOrDisableRightBarButtonItemForPayment];
}

- (void)validateState:(NSString *)state {
    if (!stringIsEmpty(state)) self.isValidState = YES;
    else if (![self.countryTextField.text isEqualToString:@"US"] && ![self.countryTextField.text isEqualToString:@"CA"] && ![self.countryTextField.text isEqualToString:@"AU"]) self.isValidState = YES;
    else self.isValidState = NO;
    [self enableOrDisableRightBarButtonItemForPayment];
}

- (void)validatePostalCode:(NSString *)pc {
    if (stringIsEmpty(pc)) self.isValidPostalCode = NO;
    else if ([self.countryTextField.text isEqualToString:@"US"] && pc.length < 5) self.isValidPostalCode = NO;
    else self.isValidPostalCode = YES;
    [self enableOrDisableRightBarButtonItemForPayment];
}

- (BOOL)isValidBillingAddress {
    return _isValidStreetAddress && _isValidCity && _isValidState && _isValidPostalCode;
}

#pragma mark Card Deletion Selectors

- (void)initiateDeleteUser:(id)sender {
    self.firstNameOutlet.userInteractionEnabled = NO;
    self.lastNameOutlet.userInteractionEnabled = NO;
    self.emailOutlet.userInteractionEnabled = NO;
    self.confirmEmailOutlet.userInteractionEnabled = NO;
    self.phoneOutlet.userInteractionEnabled = NO;
    self.phoneCountryContainer.userInteractionEnabled = NO;
    
    self.cancelUserDeletionOutlet.transform = CGAffineTransformMakeTranslation(300, 0);
    self.cancelUserDeletionOutlet.hidden = NO;
    [self.cancelUserDeletionOutlet addTarget:self action:@selector(cancelDeleteUser:) forControlEvents:UIControlEventTouchUpInside];
    
    [UIView animateWithDuration:0.4f animations:^{
        self.cancelUserDeletionOutlet.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
        ;
    }];
    
    NavigationView *nv = (NavigationView *) [self.view viewWithTag:kNavigationViewTag];
    [nv grayAndDisableLeftView];
    [nv grayAndDisableRiteView];
    
    self.firstNameOutlet.backgroundColor = [UIColor grayColor];
    self.lastNameOutlet.backgroundColor = [UIColor grayColor];
    self.emailOutlet.backgroundColor = [UIColor grayColor];
    self.confirmEmailOutlet.backgroundColor = [UIColor grayColor];
    self.phoneOutlet.backgroundColor = [UIColor grayColor];
    self.phoneCountryContainer.backgroundColor = [UIColor grayColor];
    UIImageView *flagView = (UIImageView *) [self.phoneCountryContainer.leftView viewWithTag:kFlagViewTag];
    flagView.backgroundColor = [UIColor grayColor];
    flagView.alpha = 0.2f;
    
    self.firstNameOutlet.textColor = [UIColor lightGrayColor];
    self.lastNameOutlet.textColor = [UIColor lightGrayColor];
    self.emailOutlet.textColor = [UIColor lightGrayColor];
    self.confirmEmailOutlet.textColor = [UIColor lightGrayColor];
    self.phoneOutlet.textColor = [UIColor lightGrayColor];
    self.phoneCountryContainer.textColor = [UIColor lightGrayColor];
    
    [self.deleteUserOutlet setTitle:@"Confirm Deletion" forState:UIControlStateNormal];
    [self.deleteUserOutlet removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.deleteUserOutlet addTarget:self action:@selector(dropGuestDetailsView:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)cancelDeleteUser:(id)sender {
    self.firstNameOutlet.userInteractionEnabled = YES;
    self.lastNameOutlet.userInteractionEnabled = YES;
    self.emailOutlet.userInteractionEnabled = YES;
    self.phoneOutlet.userInteractionEnabled = YES;
    self.phoneCountryContainer.userInteractionEnabled = YES;
    
    [UIView animateWithDuration:0.4f animations:^{
        self.cancelUserDeletionOutlet.transform = CGAffineTransformMakeTranslation(300, 0);
    } completion:^(BOOL finished) {
        self.cancelUserDeletionOutlet.hidden = YES;
    }];
    
    NavigationView *nv = (NavigationView *) [self.view viewWithTag:kNavigationViewTag];
    [nv blueAndEnableLeftView];
    
    [self validateFirstName:self.firstNameOutlet.text];
    [self validateLastName:self.lastNameOutlet.text];
    [self validateEmailAddress:self.emailOutlet.text withNoGoColor:NO];
    [self validatePhone:self.phoneOutlet.text];
    
    self.firstNameOutlet.backgroundColor = [UIColor whiteColor];
    self.lastNameOutlet.backgroundColor = [UIColor whiteColor];
    self.emailOutlet.backgroundColor = [UIColor whiteColor];
    self.phoneOutlet.backgroundColor = [UIColor whiteColor];
    self.phoneCountryContainer.backgroundColor = [UIColor whiteColor];
    UIImageView *flagView = (UIImageView *) [self.phoneCountryContainer.leftView viewWithTag:kFlagViewTag];
    flagView.backgroundColor = [UIColor clearColor];
    flagView.alpha = 1.0f;
    
    self.firstNameOutlet.textColor = [UIColor blackColor];
    self.lastNameOutlet.textColor = [UIColor blackColor];
    self.emailOutlet.textColor = [UIColor blackColor];
    self.phoneOutlet.textColor = [UIColor blackColor];
    self.phoneCountryContainer.textColor = [UIColor blackColor];
    
    self.deleteUserOutlet.hidden = NO;
    [self.deleteUserOutlet setTitle:@"Delete This Guest" forState:UIControlStateNormal];
    [self.deleteUserOutlet removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.deleteUserOutlet addTarget:self action:@selector(initiateDeleteUser:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark Add gradient methods

- (void)addPriceGradient:(UIView *)view {
    if ([view.layer.sublayers count] > 0) {
        return;
    }
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = view.bounds;
    gradientLayer.colors = self.priceGradientColors;
    gradientLayer.startPoint = CGPointMake(0.65f, 0.45f);
    gradientLayer.endPoint = CGPointMake(0.95f, 0.88f);
//    iv.layer.mask = gradientLayer;
    [view.layer addSublayer:gradientLayer];
}

- (void)addBottomGradient:(UIView *)view {
    if ([view.layer.sublayers count] > 0) {
        return;
    }
    
    CAGradientLayer *cornerGradLayer = [CAGradientLayer layer];
    cornerGradLayer.frame = view.bounds;
    cornerGradLayer.colors = self.bottomGradientColors;
    cornerGradLayer.startPoint = CGPointMake(0.5f, 0.0f);
    cornerGradLayer.endPoint = CGPointMake(0.5f, 1.0f);
    [view.layer addSublayer:cornerGradLayer];
}

- (void)addBottomsUpGradient:(UIView *)view {
    if ([view.layer.sublayers count] > 0) {
        return;
    }
    
    CAGradientLayer *cornerGradLayer = [CAGradientLayer layer];
    cornerGradLayer.frame = view.bounds;
    cornerGradLayer.colors = self.bottomsUpGradientColors;
    cornerGradLayer.startPoint = CGPointMake(0.7f, 0.0f);
    cornerGradLayer.endPoint = CGPointMake(0.5f, 0.9f);
    [view.layer addSublayer:cornerGradLayer];
}

#pragma mark Some views

- (UIView *)guestDetailsView {
    if (_guestDetailsView) return _guestDetailsView;
    
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"GuestDetailsView" owner:self options:nil];
    if (nil == views || [views count] != 1) {
        return nil;
    }
    
    _guestDetailsView = views[0];
    _guestDetailsView.tag = kGuestDetailsViewTag;
    _guestDetailsView.frame = CGRectMake(0, 64, 320, 568);
    _guestDetailsView.backgroundColor = kWotaColorOne();
    [[_guestDetailsView subviews] makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:(id)kWotaColorOne()];
    
    self.firstNameOutlet.delegate = self;
    self.lastNameOutlet.delegate = self;
    self.emailOutlet.delegate = self;
    self.phoneOutlet.delegate = self;
    self.phoneCountryContainer.delegate = self;
    
    UIView *cv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 26)];
    cv.backgroundColor = [UIColor clearColor];
    cv.userInteractionEnabled = NO;
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 32, 26)];
    iv.tag = kFlagViewTag;
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [cv addSubview:iv];
    [self.phoneCountryContainer setLeftViewMode:UITextFieldViewModeAlways];
    self.phoneCountryContainer.leftView = cv;
    
    return _guestDetailsView;
}

- (UIView *)paymentDetailsView {
    if (_paymentDetailsView) return _paymentDetailsView;
    
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"PaymentDetailsView" owner:self options:nil];
    if (nil == views || [views count] != 1) {
        return nil;
    }
    
    _paymentDetailsView = views[0];
    _paymentDetailsView.tag = kPaymentDetailsViewTag;
    _paymentDetailsView.frame = CGRectMake(0, 64, 320, 568);
    _paymentDetailsView.backgroundColor = kWotaColorOne();
    [[_paymentDetailsView subviews] makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:(id)kWotaColorOne()];
    
    self.ccNumberOutlet.delegate = self;
    self.addressTextFieldOutlet.delegate = self;
    self.cityTextField.delegate = self;
    self.countryTextField.delegate = self;
    self.stateTextField.delegate = self;
    self.postalTextField.delegate = self;
    self.expirationOutlet.delegate = self;
    self.cardholderFirstOutlet.delegate = self;
    self.cardholderLastOutlet.delegate = self;
    
    self.stateTextField.hidden = YES;
    
    UIView *cv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 26)];
    cv.backgroundColor = [UIColor clearColor];
    cv.userInteractionEnabled = NO;
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 32, 26)];
    iv.tag = kFlagViewTag;
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [cv addSubview:iv];
    [self.countryTextField setLeftViewMode:UITextFieldViewModeAlways];
    self.countryTextField.leftView = cv;
    
    return _paymentDetailsView;
}

@end
