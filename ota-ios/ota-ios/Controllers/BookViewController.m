//
//  BookViewController.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/28/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "BookViewController.h"
#import "EanHotelRoomReservationResponse.h"
#import "NavigationView.h"
#import "AppDelegate.h"
#import "WotaTappableView.h"
#import "GuestInfo.h"
#import "EanCredentials.h"

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

@end

@implementation BookViewController

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
    
    if (dataType != LOAD_EAN_BOOK)
        return;
    
    EanHotelRoomReservationResponse *hrrr = [EanHotelRoomReservationResponse eanObjectFromApiResponseData:responseData];
    if (hrrr.eanWsError) {
        [self handleProblems:hrrr.eanWsError.presentationMessage];
    } else if (-1 == hrrr.itineraryId || !hrrr.processedWithConfirmation || hrrr.confirmationNumbers.count == 0
                    || ![hrrr.confirmationNumbers.firstObject isKindOfClass:[NSNumber class]]) {
        [self handleProblems:nil];
    } else {
        self.itinNumber = hrrr.itineraryId;
        self.ItineraryTextView.text = [NSString stringWithFormat:@"%@", @(self.itinNumber)];
        self.confirmNumber = hrrr.confirmationNumbers.firstObject;
        self.confirmTextView.text = [NSString stringWithFormat:@"%@", self.confirmNumber];
        
        UITapGestureRecognizer *tgr1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickReturnToMenu:)];
        tgr1.numberOfTapsRequired = tgr1.numberOfTouchesRequired = 1;
        [self.returnMenuView addGestureRecognizer:tgr1];
        
        UITapGestureRecognizer *tgr2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickViewOrCancelReservation:)];
        tgr2.numberOfTapsRequired = tgr2.numberOfTouchesRequired = 1;
        [self.viewOrCancelView addGestureRecognizer:tgr2];
        
        [self dropDaSpinner];
        
        __weak typeof(self) wes = self;
        [UIView animateWithDuration:0.15 animations:^{
            wes.problemOverlay.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [wes.problemOverlay removeFromSuperview];
        }];
    }
    
    NSString *respString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"%@.%@:::%@", self.class, NSStringFromSelector(_cmd), respString);
}

- (void)handleProblems:(NSString *)message {
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
    self.previousScreenView.hidden = NO;
    self.problemMessage.hidden = NO;
    [self dropDaSpinner];
}

#pragma mark Tap Gestures

- (void)clickReturnToPreviousScreen:(UITapGestureRecognizer *)tgr {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickReturnToMenu:(UITapGestureRecognizer *)tgr {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)clickViewOrCancelReservation:(UITapGestureRecognizer *)tgr {
    NSString *urlString = [NSString stringWithFormat:@"https://travelnow.com/selfService/%@/searchByIdAndEmail?itineraryId=%@&email=%@", [EanCredentials CID], @(self.itinNumber), [[GuestInfo singleton] email]];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

@end
