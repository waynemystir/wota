//
//  BookViewController.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/28/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "BookViewController.h"
#import "EanHotelRoomReservationResponse.h"
#import "EanHotelItineraryResponse.h"
#import "NavigationView.h"
#import "AppDelegate.h"
#import "WotaTappableView.h"
#import "GuestInfo.h"
#import "EanCredentials.h"
#import "NetworkProblemResponder.h"
#import "LoadEanData.h"
#import "WotaButton.h"
#import "EanItinerary.h"
#import "EanHotelConfirmation.h"
#import "SelectRoomViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "RoomCostView.h"
#import "AppEnvironment.h"
#import "Analytics.h"

NSUInteger const kBookPriceDetailsPopupTag = 1239874;
NSUInteger const kCheckInInstrPopupTag = 5917431;
NSUInteger const kOverlayDisableTag = 7146398;

@interface BookViewController ()

@property (nonatomic, strong) EanAvailabilityHotelRoomResponse *room;
@property (nonatomic, strong) NSString *checkInInstructions;
@property (weak, nonatomic) IBOutlet UITextView *ItineraryTextView;
@property (weak, nonatomic) IBOutlet UITextView *confirmTextView;
@property (weak, nonatomic) IBOutlet UILabel *totalChargesLbl;
@property (weak, nonatomic) IBOutlet UILabel *checkInInstructionsLbl;
@property (weak, nonatomic) IBOutlet WotaTappableView *returnMenuView;
@property (weak, nonatomic) IBOutlet WotaTappableView *viewOrCancelView;
@property (weak, nonatomic) IBOutlet UIView *problemOverlay;
@property (weak, nonatomic) IBOutlet UILabel *problemMessage;
@property (nonatomic) NSInteger itinNumber;
@property (nonatomic, strong) NSNumber *confirmNumber;
@property (weak, nonatomic) IBOutlet WotaTappableView *previousScreenView;
@property (weak, nonatomic) IBOutlet UILabel *errorTitle;
@property (weak, nonatomic) IBOutlet UIView *pendingOverlay;
@property (weak, nonatomic) IBOutlet WotaButton *callCustSuppUS;
@property (weak, nonatomic) IBOutlet WotaButton *callCustSuppEU;
@property (weak, nonatomic) IBOutlet WotaTappableView *linkToSelfServeView;
@property (weak, nonatomic) IBOutlet WotaTappableView *returnHotelSrchAfterPendingView;
@property (weak, nonatomic) IBOutlet UITextView *pendingItineraryTextView;
@property (weak, nonatomic) IBOutlet UIView *pendingItineraryContainer;

@end

@implementation BookViewController {
    int numberOfPriceMismatchRecalls;
}

- (id)initWithRoom:(EanAvailabilityHotelRoomResponse *)room checkInInstructions:(NSString *)checkInInstructions {
    if (self = [self init]) {
        _room = room;
        _checkInInstructions = checkInInstructions;
    }
    return self;
}

- (id)init {
    self = [super initWithNibName:@"BookView" bundle:nil];
    return  self;
}

- (void)loadView {
    [super loadView];
    [self loadDaSpinner];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect sf = [[UIScreen mainScreen] bounds];
    if (sf.size.height == 480) {
        self.view.transform = CGAffineTransformMakeScale(0.845070f, 0.845070f);
    } else if (sf.size.height == 568) {
        
    } else if (sf.size.height == 667) {
        self.view.transform = CGAffineTransformMakeScale(1.171875f, 1.174295f);
    } else if (sf.size.height == 736) {
        self.view.transform = CGAffineTransformMakeScale(1.29375f, 1.295774f);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    TrotterLog(@"WARNING:%s", __PRETTY_FUNCTION__);
}

#pragma mark Spinner

- (void)loadDaSpinner {
    AppDelegate *ad = [[UIApplication sharedApplication] delegate];
    [ad loadDaSpinnerWithFrame:[[UIScreen mainScreen] bounds]];
}

- (void)dropDaSpinner {
    AppDelegate *ad = [[UIApplication sharedApplication] delegate];
    [ad dropDaSpinnerAlreadyWithForce:YES];
}

#pragma mark LoadDataProtocol methods

- (void)requestStarted:(NSURLConnection *)connection {
    TrotterLog(@"%@.%@.:::%@", self.class, NSStringFromSelector(_cmd), [[[connection currentRequest] URL] absoluteString]);
}

- (void)requestFinished:(NSData *)responseData dataType:(LOAD_DATA_TYPE)dataType {
    
    switch (dataType) {
        case LOAD_EAN_BOOK: {
            [self evaluateBookResponse:responseData];
            break;
        }
            
        case LOAD_EAN_ITIN: {
            [self evaluateItineraryResponse:responseData];
            break;
        }
            
        default:
            break;
    }

//    NSString *respString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//    TrotterLog(@"%@.%@:::%@", self.class, NSStringFromSelector(_cmd), respString);
}

- (void)evaluateItineraryResponse:(NSData *)responseData {
    EanHotelItineraryResponse *hir = [EanHotelItineraryResponse eanObjectFromApiResponseData:responseData];
    
    if (!hir) {
        
        [self handleProblems:nil];
        
    } else if (hir.eanWsError) {
        
        [self handleProblems:nil];
        
    } else if (!hir.itineraries.firstObject) {
        
        [self handleProblems:nil];
        
    } else if ([((EanItinerary *)hir.itineraries.firstObject).hotelConfirmation.status isEqualToString:@"PS"]) {
        
        [self handlePendingState:((EanItinerary *)hir.itineraries.firstObject).itineraryId];
        
    } else if ([((EanItinerary *)hir.itineraries.firstObject).hotelConfirmation.status isEqualToString:@"UC"]) {
        
        // https://support.ean.com/hc/en-us/requests/112810
        [self handlePendingState:((EanItinerary *)hir.itineraries.firstObject).itineraryId];
        
    } else if ([((EanItinerary *)hir.itineraries.firstObject).hotelConfirmation.status isEqualToString:@"CX"] ||
               [((EanItinerary *)hir.itineraries.firstObject).hotelConfirmation.status isEqualToString:@"ER"] ||
               [((EanItinerary *)hir.itineraries.firstObject).hotelConfirmation.status isEqualToString:@"DT"] ||
               -1 == ((EanItinerary *)hir.itineraries.firstObject).itineraryId ||
               !((EanItinerary *)hir.itineraries.firstObject).hotelConfirmation.confirmationNumber ||
               ![((EanItinerary *)hir.itineraries.firstObject).hotelConfirmation.confirmationNumber isKindOfClass:[NSNumber class]]) {
        
        [self handleProblems:nil];
        
    } else {
        
        [self handleConfirmedItinerary:((EanItinerary *)hir.itineraries.firstObject).itineraryId confirmNumber:((EanItinerary *)hir.itineraries.firstObject).hotelConfirmation.confirmationNumber];
        
    }
}

- (void)evaluateBookResponse:(NSData *)responseData {
    EanHotelRoomReservationResponse *hrrr = [EanHotelRoomReservationResponse eanObjectFromApiResponseData:responseData];
    if (!hrrr || hrrr.isResponseEmpty) {
        
        [[LoadEanData sharedInstance:self] loadItineraryWithAffiliateConfirmationId:self.affiliateConfirmationId];
        
    } else if (hrrr.eanWsError) {
        
        if ([hrrr.eanWsError.eweCategory isEqualToString:@"PRICE_MISMATCH"]) {
            
            NSMutableArray *controllers = [self.navigationController.viewControllers mutableCopy];
            int indexOfSRVC = -1;
            SelectRoomViewController *srvc;
            for (int j = 0; j < controllers.count; j++)
                if ([controllers[j] isKindOfClass:[SelectRoomViewController class]]) {
                    indexOfSRVC = j;
                    break;
                }
            
            if (indexOfSRVC > -1) srvc = controllers[indexOfSRVC];
            if (srvc) {
                if (numberOfPriceMismatchRecalls++ > 0) {
                    [controllers removeObjectAtIndex:indexOfSRVC];
                    self.navigationController.viewControllers = [NSArray arrayWithArray:controllers];
                    [self handleProblems:hrrr.eanWsError.presentationMessage];
                } else {
                    setWithIpAddress(NO);
                    [srvc bookIt];
                    return;
                }
            } else {
                [self handleProblems:hrrr.eanWsError.presentationMessage];
            }
            
        } else if ([hrrr.eanWsError.eweHandling isEqualToString:@"AGENT_ATTENTION"]) {
            
            [self handlePendingState:hrrr.eanWsError.itineraryId];
            
        } else {
            
            [self handleProblems:hrrr.eanWsError.presentationMessage];
            
        }
        
    } else if ([hrrr.reservationStatusCode isEqualToString:@"PS"]) {
        
        [self handlePendingState:hrrr.itineraryId];
        
    } else if ([hrrr.reservationStatusCode isEqualToString:@"UC"]) {
        
        // https://support.ean.com/hc/en-us/requests/112810
        [self handlePendingState:hrrr.itineraryId];
        
    } else if ([hrrr.reservationStatusCode isEqualToString:@"CX"] ||
               [hrrr.reservationStatusCode isEqualToString:@"ER"] ||
               [hrrr.reservationStatusCode isEqualToString:@"DT"] ||
               -1 == hrrr.itineraryId ||
               !hrrr.processedWithConfirmation ||
               hrrr.confirmationNumbers.count == 0 ||
               ![hrrr.confirmationNumbers.firstObject isKindOfClass:[NSNumber class]]) {
        
        [self handleProblems:hrrr.errorText];
        
    } else {
        
        [self handleConfirmedItinerary:hrrr.itineraryId confirmNumber:hrrr.confirmationNumbers.firstObject];
        
    }
    
    [self nukePaymentDetails];
}

- (void)nukePaymentDetails {
    NSArray *controllers = self.navigationController.viewControllers;
    SelectRoomViewController *srvc;
    for (int j = 0; j < controllers.count; j++)
        if ([controllers[j] isKindOfClass:[SelectRoomViewController class]]) {
            srvc = controllers[j];
            break;
        }
    
    if (srvc) [srvc nukePaymentDetails];
}

- (void)handleConfirmedItinerary:(NSInteger)itineraryId confirmNumber:(NSNumber *)confirmNumber {
    self.itinNumber = itineraryId;
    self.ItineraryTextView.text = [NSString stringWithFormat:@"%@", @(self.itinNumber)];
    self.confirmNumber = confirmNumber;
    self.confirmTextView.text = [NSString stringWithFormat:@"%@", self.confirmNumber];
    
    NSNumberFormatter *twoDigit = kPriceTwoDigitFormatter(_room.rateInfo.chargeableRateInfo.currencyCode);
    NSString *totalAmt = [twoDigit stringFromNumber:_room.rateInfo.chargeableRateInfo.total];
    self.totalChargesLbl.text = totalAmt;
    self.totalChargesLbl.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadPriceDetailsPopup:)];
    tapper.numberOfTapsRequired = 1;
    tapper.numberOfTouchesRequired = 1;
    tapper.cancelsTouchesInView = NO;
    [self.totalChargesLbl addGestureRecognizer:tapper];
    
    UITapGestureRecognizer *cit = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadCheckInInstructionsPopup:)];
    cit.numberOfTapsRequired = cit.numberOfTouchesRequired = 1;
    self.checkInInstructionsLbl.userInteractionEnabled = YES;
    [self.checkInInstructionsLbl addGestureRecognizer:cit];
    
    UITapGestureRecognizer *tgr1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickReturnToMenu:)];
    tgr1.numberOfTapsRequired = tgr1.numberOfTouchesRequired = 1;
    [self.returnMenuView addGestureRecognizer:tgr1];
    
    UITapGestureRecognizer *tgr2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickViewOrCancelReservation:)];
    tgr2.numberOfTapsRequired = tgr2.numberOfTouchesRequired = 1;
    [self.viewOrCancelView addGestureRecognizer:tgr2];
    
    self.pendingOverlay.hidden = YES;
    [self dropDaSpinner];
    
    __weak typeof(self) wes = self;
    [UIView animateWithDuration:0.15 animations:^{
        wes.problemOverlay.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [wes.problemOverlay removeFromSuperview];
    }];
    
    [Analytics postBookingResponseWithAffConfId:[self.affiliateConfirmationId UUIDString]
                                    itineraryId:itineraryId confirmationId:[confirmNumber longLongValue]
                      processedWithConfirmation:@(YES)
                          reservationStatusCode:@"CF"
                                  nonrefundable:@(_room.rateInfo.nonRefundable)
                              customerSessionId:kEanCustomerSessionId()];
}

- (void)handlePendingState:(NSInteger)itineraryNumber {
    self.itinNumber = itineraryNumber;
    if (self.itinNumber > 0) {
        self.pendingItineraryTextView.text = [NSString stringWithFormat:@"%@", @(self.itinNumber)];
    } else {
        self.pendingItineraryContainer.hidden = YES;
    }
    
    self.pendingOverlay.hidden = NO;
    
    [self.callCustSuppUS addTarget:self action:@selector(clickCustomerSupportUS:) forControlEvents:UIControlEventTouchUpInside];
    [self.callCustSuppEU addTarget:self action:@selector(clickCustomerSupportEU:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tgrss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickSelfServiceLink:)];
    tgrss.numberOfTapsRequired = tgrss.numberOfTouchesRequired = 1;
    [self.linkToSelfServeView addGestureRecognizer:tgrss];
    
    UITapGestureRecognizer *tgr1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickReturnToMenu:)];
    tgr1.numberOfTapsRequired = tgr1.numberOfTouchesRequired = 1;
    [self.returnHotelSrchAfterPendingView addGestureRecognizer:tgr1];
    
    [self dropDaSpinner];
}

- (void)handleProblems:(NSString *)message {
    [self handleProblems:message titleMsg:nil];
    
    NSString *vm = @"";
    
    NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
    [array removeObject:@""];
    
    if (array.count >= 5)
        vm = [NSString stringWithFormat:@"%@.%@", [array objectAtIndex:3], [array objectAtIndex:4]];
    
    [Analytics postTrotterProblemWithCategory:@"BOOKING_PROBLEM" shortMessage:[NSString stringWithFormat:@"From:%s", __PRETTY_FUNCTION__] verboseMessage:[NSString stringWithFormat:@"EAN message:%@", message]];
}

- (void)handleProblems:(NSString *)message titleMsg:(NSString *)titleMsg {
    self.pendingOverlay.hidden = YES;
    if (!stringIsEmpty(message)) {
        self.problemMessage.text = [NSString stringWithFormat:@"%@\n\n%@", self.problemMessage.text, message];
        CGRect pmf = self.problemMessage.frame;
        CGSize size = [self.problemMessage sizeThatFits:CGSizeMake(pmf.size.width, 325.0f)];
        pmf.size.height = MIN(size.height, 325.0f);
        self.problemMessage.frame = pmf;
        CGRect w = self.previousScreenView.frame;
        self.previousScreenView.frame = CGRectMake(w.origin.x, pmf.origin.y + pmf.size.height + 30, w.size.width, w.size.height);
    }
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickReturnToPreviousScreen:)];
    tgr.numberOfTapsRequired = tgr.numberOfTouchesRequired = 1;
    [self.previousScreenView addGestureRecognizer:tgr];
    self.errorTitle.hidden = NO;
    if (titleMsg) {
        self.errorTitle.adjustsFontSizeToFitWidth = YES;
        self.errorTitle.minimumScaleFactor = 0.6f;
        self.errorTitle.text = titleMsg;
    }
    self.previousScreenView.hidden = NO;
    self.problemMessage.hidden = NO;
    [self dropDaSpinner];
}

- (void)requestTimedOut:(LOAD_DATA_TYPE)dataType {
    [self nukePaymentDetails];
    
    switch (dataType) {
        case LOAD_EAN_BOOK: {
            [[LoadEanData sharedInstance:self] loadItineraryWithAffiliateConfirmationId:self.affiliateConfirmationId];
            break;
        }
            
        case LOAD_EAN_ITIN: {
            [self handleProblems:@"The reservation request timed out. Please check your connection and try again."];
            break;
        }
            
        default:
            break;
    }
}

- (void)requestFailedOffline {
    [self nukePaymentDetails];
    [self dropDaSpinner];
    __weak typeof(self) wes = self;
    [NetworkProblemResponder launchWithSuperView:self.view headerTitle:@"Network Error" messageString:@"The network could not be reached. Please check your connection and try again." completionCallback:^{
        [wes.navigationController popViewControllerAnimated:YES];
    }];
    [Analytics postTrotterProblemWithCategory:@"TROTTER_FAILED_OFFLINE" shortMessage:@"Request failed offline" verboseMessage:[NSString stringWithFormat:@"CALLED BY:%s", __PRETTY_FUNCTION__]];
}

- (void)requestFailedCredentials {
    [self nukePaymentDetails];
    [self dropDaSpinner];
    __weak typeof(self) wes = self;
    [NetworkProblemResponder launchWithSuperView:self.view headerTitle:@"System Error" messageString:@"Sorry for the inconvenience. We are experiencing a technical issue. Please try again shortly." completionCallback:^{
        [wes.navigationController popViewControllerAnimated:YES];
    }];
    NSString *vm = [NSString stringWithFormat:@"CID:%@ apiKey:%@ sharedSecret:%@ From:%s",  [EanCredentials CID] ? : @"", [EanCredentials apiKey] ? : @"", [EanCredentials sharedSecret] ? : @"", __PRETTY_FUNCTION__];
    [Analytics postTrotterProblemWithCategory:@"TROTTER_CREDENTIALS" shortMessage:@"Request failed credentials" verboseMessage:vm];
}

- (void)requestFailed {
    [self nukePaymentDetails];
    [self dropDaSpinner];
    __weak typeof(self) wes = self;
    [NetworkProblemResponder launchWithSuperView:self.view headerTitle:@"An Error Occurred" messageString:@"Please try again." completionCallback:^{
        [wes.navigationController popViewControllerAnimated:YES];
    }];
    [Analytics postTrotterProblemWithCategory:@"TROTTER_REQUEST_FAILED" shortMessage:@"Request failed" verboseMessage:[NSString stringWithFormat:@"CALLED BY:%s", __PRETTY_FUNCTION__]];
}

#pragma mark Tap Gestures

- (void)clickReturnToPreviousScreen:(UITapGestureRecognizer *)tgr {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickReturnToMenu:(UITapGestureRecognizer *)tgr {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)clickViewOrCancelReservation:(UITapGestureRecognizer *)tgr {
    NSString *languageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    NSString *urlString = [NSString stringWithFormat:@"https://travelnow.com/selfService/%@/searchByIdAndEmail?itineraryId=%@&email=%@&lang=%@", [EanCredentials CID], @(self.itinNumber), [[GuestInfo singleton] email], languageCode];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (void)clickCustomerSupportUS:(id)sender {
    [self makeTheCall:@"1-800-780-5733"];
}

- (void)clickCustomerSupportEU:(id)sender {
    [self makeTheCall:@"00-800-11-20-11-40"];
}

- (void)clickSelfServiceLink:(UITapGestureRecognizer *)tgr {
    NSString *languageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    NSString *urlString = [NSString stringWithFormat:@"https://travelnow.com/selfService/searchform?cid=%@&lang=%@", [EanCredentials CID], languageCode];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

#pragma mark Making A Call

- (void)makeTheCall:(NSString *)phoneNumber {
    NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
    NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt:%@", cleanedString]];
    [[UIApplication sharedApplication] openURL:telURL];
}

#pragma mark Price view

- (void)loadPriceDetailsPopup:(UIGestureRecognizer *)sender {
    RoomCostView *rcv = [[RoomCostView alloc] initWithFrame:CGRectMake(7, 100, 306, 368) room:_room];
    [rcv loadCostSummaryView:self.view wx:7 wy:568 xOffset:0.0f yOffset:-193.0f];
//    [rcv loadCostSummaryView:self.view xOffset:0.0f yOffset:-193.0f];
}

- (void)loadCheckInInstructionsPopup:(UITapGestureRecognizer *)sender {
    AudioServicesPlaySystemSound(0x450);
    __block UIView *wayne = [[UIView alloc] initWithFrame:CGRectMake(10, 100, 300, 356)];
    
    UIView *ov = sender.view;
    wayne.tag = kCheckInInstrPopupTag;
    wayne.backgroundColor = [UIColor whiteColor];
    wayne.layer.cornerRadius = 8.0f;
    wayne.layer.borderColor = [UIColor blackColor].CGColor;
    wayne.layer.borderWidth = 3.0f;
    
    UIView *old = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    old.backgroundColor = [UIColor blackColor];
    old.alpha = 0.0f;
    old.tag = kOverlayDisableTag;
    
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(13, 12, 200, 30)];
    l.text = @"Check-in Instructions";
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
    
    wv.text = self.checkInInstructions;
    
    wv.textColor = [UIColor blackColor];
    wv.backgroundColor = [UIColor whiteColor];
    
    CGFloat fixedWidth = wv.frame.size.width;
    CGSize newSize = [wv sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = wv.frame;
    newFrame.size = CGSizeMake(fixedWidth, fminf(newSize.height + 2, 384));
    wv.frame = newFrame;
    
    CGFloat abc = wv.frame.origin.y + wv.frame.size.height + 10;
    CGFloat wx = (320 - 300)/2;
    wayne.frame = CGRectMake(wx, ((64 + 568 - abc)/2), 300, abc);
    
    [wayne addSubview:wv];
    
    CGFloat fromX = ov.center.x - wayne.center.x;
    CGFloat fromY = ov.center.y - wayne.center.y + 64;
    wayne.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(fromX, fromY), 0.001f, 0.001f);
    
    //    wayne.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, 65), 0.001f, 0.001f);
    
    self.navigationController.navigationBar.clipsToBounds = NO;
    [self.view addSubview:old];
    [self.view bringSubviewToFront:old];
    [self.view addSubview:wayne];
    [self.view bringSubviewToFront:wayne];
    
    [self.view endEditing:YES];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.4 animations:^{
        old.alpha = 0.8f;
        weakSelf.navigationController.navigationBar.alpha = 0.3f;
        wayne.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)dropInfoDetailsPopup {
    __weak typeof(self) weakSelf = self;
    __weak UIView *w = [self.view viewWithTag:kCheckInInstrPopupTag];
    
    __weak UIView *originatingView = self.checkInInstructionsLbl;
    __weak UIView *old = [self.view viewWithTag:kOverlayDisableTag];
    
    CGFloat toX = originatingView.center.x - w.center.x;
    CGFloat toY = originatingView.center.y - w.center.y + 64;
    __block CGAffineTransform toTransform = CGAffineTransformScale(CGAffineTransformMakeTranslation(toX, toY), 0.001f, 0.001f);
    
    [UIView animateWithDuration:0.4 animations:^{
        old.alpha = 0.0f;
        weakSelf.navigationController.navigationBar.alpha = 1.0f;
        w.transform = toTransform;
    } completion:^(BOOL finished) {
        [old removeFromSuperview];
        [w removeFromSuperview];
    }];
}

@end
