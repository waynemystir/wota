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

@interface BookViewController ()

@property (weak, nonatomic) IBOutlet UITextView *ItineraryTextView;
@property (weak, nonatomic) IBOutlet UITextView *confirmTextView;
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

- (id)init {
    self = [super initWithNibName:@"BookView" bundle:nil];
    return  self;
}

- (void)loadView {
    [super loadView];
    [self loadDaSpinner];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

#pragma mark Spinner

- (void)loadDaSpinner {
    AppDelegate *ad = [[UIApplication sharedApplication] delegate];
    [ad loadDaSpinnerWithFrame:CGRectMake(0, 0, 320, 568)];
}

- (void)dropDaSpinner {
    AppDelegate *ad = [[UIApplication sharedApplication] delegate];
    [ad dropDaSpinnerAlreadyWithForce:YES];
}

#pragma mark LoadDataProtocol methods

- (void)requestStarted:(NSURLConnection *)connection {
    NSLog(@"%@.%@.:::%@", self.class, NSStringFromSelector(_cmd), [[[connection currentRequest] URL] absoluteString]);
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
        
        // TODO: I need to cancel these bookings and message them as "inventory unavailable" to the customer to avoid duplicate bookings. If left alone, EAN will continue to attempt to process these bookings and may eventually confirm them without further notice.
        
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
        
        // TODO: I need to cancel these bookings and message them as "inventory unavailable" to the customer to avoid duplicate bookings. If left alone, EAN will continue to attempt to process these bookings and may eventually confirm them without further notice.
        
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
}

- (void)requestFailedCredentials {
    [self nukePaymentDetails];
    [self dropDaSpinner];
    __weak typeof(self) wes = self;
    [NetworkProblemResponder launchWithSuperView:self.view headerTitle:@"System Error" messageString:@"Sorry for the inconvenience. We are experiencing a technical issue. Please try again shortly." completionCallback:^{
        [wes.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)requestFailed {
    [self nukePaymentDetails];
    [self dropDaSpinner];
    __weak typeof(self) wes = self;
    [NetworkProblemResponder launchWithSuperView:self.view headerTitle:@"An Error Occurred" messageString:@"Please try again." completionCallback:^{
        [wes.navigationController popViewControllerAnimated:YES];
    }];
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

@end
