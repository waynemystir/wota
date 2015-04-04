//
//  CriteriaViewController.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/24/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "CriteriaViewController.h"
#import "SelectionCriteria.h"
#import "ChildTraveler.h"
#import "LoadGooglePlacesData.h"
#import "PlaceAutoCompleteTableViewCell.h"
#import "GoogleParser.h"
#import "GooglePlace.h"
#import "GooglePlaceDetail.h"
#import "MapViewController.h"
#import "HotelListingViewController.h"
#import "THDatePickerViewController.h"
#import "ChildViewController.h"

@interface CriteriaViewController () <LoadDataProtocol, UITableViewDataSource, UITableViewDelegate, THDatePickerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *whereToTextFieldOutlet;
@property (weak, nonatomic) IBOutlet UIButton *mapButtonOutlet;
@property (strong, nonatomic) UITableView *autoCompleteTableViewOutlet;

@property (nonatomic) BOOL isAutoCompleteTableViewExpanded;

@property (nonatomic, strong) NSArray *tableData;

//autoComplete is NO and placeDetails is YES
@property (nonatomic) BOOL autoCompleteOrPlaceDetails;

@property (nonatomic, strong) UIView *cupHolder;
@property (nonatomic, strong) UIButton *arrivalDateOutlet;
@property (nonatomic, strong) UIButton *returnDateOutlet;
@property (nonatomic, strong) UILabel *adultsLabel;
@property (nonatomic, strong) UIButton *addAdultButton;
@property (nonatomic, strong) UIButton *minusAdultButton;
@property (nonatomic, strong) UIButton *checkHotelsButton;
@property (nonatomic, strong) UIButton *kidsButton;

@property (nonatomic, strong) THDatePickerViewController *datePicker;
@property BOOL arrivalOrReturn; //arrival == NO and return == YES
@property (nonatomic, strong) NSDateFormatter *viewFormatter;

- (IBAction)justPushIt:(id)sender;

@end

@implementation CriteriaViewController

#pragma mark Lifecycle methods

- (id)init {
    self = [super initWithNibName:@"CriteriaView" bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //**********************************************************************
    // This is needed so that this view controller (or it's nav controller?)
    // doesn't make room at the top of the table view's scroll view (I guess
    // to account for the nav bar).
    //***********************************************************************
    self.automaticallyAdjustsScrollViewInsets = NO;
    //***********************************************************************
    
    self.cupHolder = [[UIView alloc] initWithFrame:CGRectMake(13, 137, 300, 400)];
//    self.cupHolder.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.cupHolder];
    
    self.arrivalDateOutlet = [[UIButton alloc] initWithFrame:CGRectMake(50, 20, 200, 50)];
    self.arrivalDateOutlet.backgroundColor = [UIColor whiteColor];
    [self.arrivalDateOutlet setTitle:@"Arrival Date" forState:UIControlStateNormal];
    [self.arrivalDateOutlet setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.arrivalDateOutlet addTarget:self action:@selector(justPushIt:) forControlEvents:UIControlEventTouchUpInside];
    [self.cupHolder addSubview: self.arrivalDateOutlet];
    
    self.returnDateOutlet = [[UIButton alloc] initWithFrame:CGRectMake(50, 90, 200, 50)];
    self.returnDateOutlet.backgroundColor = [UIColor whiteColor];
    [self.returnDateOutlet setTitle:@"Return Date" forState:UIControlStateNormal];
    [self.returnDateOutlet setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.returnDateOutlet addTarget:self action:@selector(justPushIt:) forControlEvents:UIControlEventTouchUpInside];
    [self.cupHolder addSubview: self.returnDateOutlet];
    
    self.adultsLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 160, 100, 50)];
    self.adultsLabel.backgroundColor = [UIColor whiteColor];
    [self setNumberOfAdultsLabel:0];
    self.adultsLabel.textColor = [UIColor blackColor];
    [self.cupHolder addSubview: self.adultsLabel];
    
    self.minusAdultButton = [[UIButton alloc] initWithFrame:CGRectMake(155, 160, 50, 50)];
    self.minusAdultButton.backgroundColor = [UIColor whiteColor];
    [self.minusAdultButton setTitle:@"M" forState:UIControlStateNormal];
    [self.minusAdultButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.minusAdultButton addTarget:self action:@selector(justPushIt:) forControlEvents:UIControlEventTouchUpInside];
    [self.cupHolder addSubview: self.minusAdultButton];
    
    self.addAdultButton = [[UIButton alloc] initWithFrame:CGRectMake(205, 160, 50, 50)];
    self.addAdultButton.backgroundColor = [UIColor whiteColor];
    [self.addAdultButton setTitle:@"A" forState:UIControlStateNormal];
    [self.addAdultButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.addAdultButton addTarget:self action:@selector(justPushIt:) forControlEvents:UIControlEventTouchUpInside];
    [self.cupHolder addSubview: self.addAdultButton];
    
    self.kidsButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 230, 200, 50)];
    self.kidsButton.backgroundColor = [UIColor whiteColor];
    [self setNumberOfKidsButtonLabel];
    [self.kidsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.kidsButton addTarget:self action:@selector(justPushIt:) forControlEvents:UIControlEventTouchUpInside];
    [self.cupHolder addSubview: self.kidsButton];
    
    self.checkHotelsButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 300, 200, 50)];
    self.checkHotelsButton.backgroundColor = [UIColor whiteColor];
    [self.checkHotelsButton setTitle:@"Find Hotels" forState:UIControlStateNormal];
    [self.checkHotelsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.checkHotelsButton addTarget:self action:@selector(justPushIt:) forControlEvents:UIControlEventTouchUpInside];
    [self.cupHolder addSubview: self.checkHotelsButton];
    
    self.viewFormatter = [[NSDateFormatter alloc] init];
    [_viewFormatter setDateFormat:@"MMMM dd, yyyy"];
    
    self.arrivalOrReturn = NO;
    [self refreshDisplayedArrivalDate];
    [self refreshDisplayedReturnDate];
    
//    self.tableData = [NSArray arrayWithObjects:@"Albequerque", @"Saschatchawan", @"New Orleans", @"Madison", nil];
    self.autoCompleteTableViewOutlet = [[UITableView alloc] initWithFrame:CGRectMake(13, 122, 300, 0)];
    self.autoCompleteTableViewOutlet.backgroundColor = [UIColor whiteColor];
    self.autoCompleteTableViewOutlet.dataSource = self;
    self.autoCompleteTableViewOutlet.delegate = self;
    self.autoCompleteTableViewOutlet.sectionHeaderHeight = 0.0f;
    [self.view addSubview:self.autoCompleteTableViewOutlet];
    
    self.whereToTextFieldOutlet.text = [SelectionCriteria singleton].whereTo;
    [self.whereToTextFieldOutlet addTarget:self action:@selector(startEnteringWhereTo) forControlEvents:UIControlEventTouchDown];
    [self.whereToTextFieldOutlet addTarget:self action:@selector(autoCompleteSomePlace) forControlEvents:UIControlEventEditingChanged];
    [self.whereToTextFieldOutlet addTarget:self action:@selector(didFinishTextFieldKeyboard) forControlEvents:UIControlEventEditingDidEndOnExit];
}

#pragma mark Various events and such

- (void)startEnteringWhereTo {
    if (!self.isAutoCompleteTableViewExpanded) {
        [self animateTableViewExpansion];
    }
}

- (void)autoCompleteSomePlace {
    self.autoCompleteOrPlaceDetails = NO;
    [[LoadGooglePlacesData sharedInstance:self] autoCompleteSomePlaces:self.whereToTextFieldOutlet.text];
}

- (void)didFinishTextFieldKeyboard {
    [self.whereToTextFieldOutlet resignFirstResponder];
    [self animateTableViewCompression];
}

- (IBAction)justPushIt:(id)sender {
    if (sender == self.mapButtonOutlet) {
        MapViewController *mvc = [MapViewController new];
        [self.navigationController pushViewController:mvc animated:YES];
    } else if (sender == self.checkHotelsButton) {
        [self letsFindHotels];
    } else if (sender == self.arrivalDateOutlet) {
        self.arrivalOrReturn = NO;
        [self presentTheDatePicker];
    } else if (sender == self.returnDateOutlet) {
        self.arrivalOrReturn = YES;
        [self presentTheDatePicker];
    } else if (sender == self.minusAdultButton) {
        [self setNumberOfAdultsLabel:-1];
    } else if (sender == self.addAdultButton) {
        [self setNumberOfAdultsLabel:1];
    } else if (sender == self.kidsButton) {
        [self presentKidsSelector];
    } else {
        NSLog(@"Dude we've got a problem");
    }
}

- (void)letsFindHotels {
    GooglePlaceDetail *gpd = [SelectionCriteria singleton].googlePlaceDetail;
    NSString *arrivalDt = [SelectionCriteria singleton].arrivalDateEanString;
    NSString *returnDt = [SelectionCriteria singleton].returnDateEanString;
    
    HotelListingViewController *hvc = [HotelListingViewController new];
    [[LoadEanData sharedInstance:hvc] loadHotelsWithLatitude:gpd.latitude longitude:gpd.longitude arrivalDate:arrivalDt returnDate:returnDt];
    [self.navigationController pushViewController:hvc animated:YES];
}

- (void)setNumberOfAdultsLabel:(NSInteger)change {
    SelectionCriteria *sc = [SelectionCriteria singleton];
    
    if (sc.numberOfAdults > 1 || change > 0) {
        sc.numberOfAdults += change;
    }
    
    if (sc.numberOfAdults <= 1) {
        // TODO: disable minus button
    }
    
    if (sc.numberOfAdults > 10) {
        // TODO: disable add button
    }
    
    NSString *plural = sc.numberOfAdults == 1 ? @"" : @"s";
    self.adultsLabel.text = [NSString stringWithFormat:@"%lu Adult%@", (unsigned long)sc.numberOfAdults, plural];
}

- (void)presentKidsSelector {
    ChildViewController *kids = [ChildViewController new];
    [self presentSemiViewController:kids withOptions:@{
                                                       KNSemiModalOptionKeys.pushParentBack    : @(NO),
                                                       KNSemiModalOptionKeys.animationDuration : @(0.4),
                                                       KNSemiModalOptionKeys.shadowOpacity     : @(0.3),
                                                       } completion:^{
                                                           NSLog(@"");
                                                       } dismissBlock:^{
                                                           NSLog(@"");
                                                           [self setNumberOfKidsButtonLabel];
                                                       }];
}

- (void)setNumberOfKidsButtonLabel {
    NSUInteger numberOfKids = [ChildTraveler numberOfKids];
    NSString *plural = numberOfKids == 1 ? @"Child" : @"Children";
    id numbKids = numberOfKids == 0 ? @"Add" : [NSString stringWithFormat:@"%lu", (unsigned long) numberOfKids];
    NSString *buttonText = [NSString stringWithFormat:@"%@ %@", numbKids, plural];
    [self.kidsButton setTitle:buttonText forState:UIControlStateNormal];
}

#pragma mark LoadDataProtocol methods

- (void)requestStarted:(NSURL *)url {
    NSLog(@"%@.%@ loading URL:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [url absoluteString]);
}

- (void)requestFinished:(NSData *)responseData {
    if (!self.autoCompleteOrPlaceDetails) {
        self.tableData = [GoogleParser parseAutoCompleteResponse:responseData];
        [self.autoCompleteTableViewOutlet reloadData];
    } else {
        NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"PLACESDETAIL:%@", response);
        [SelectionCriteria singleton].googlePlaceDetail = [GooglePlaceDetail placeDetailFromData:responseData];
    }
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"placeAutoCompleteCell";
    PlaceAutoCompleteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"PlaceAutoCompleteTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    
    GooglePlace *place = [GooglePlace placeFromObject:[self.tableData objectAtIndex:indexPath.row]];
    cell.outletPlaceName.text = place.placeName;
    cell.placeId = place.placeId;
    
    return cell;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PlaceAutoCompleteTableViewCell * cell = (PlaceAutoCompleteTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    // TODO: I'm worried that we are setting the "where to" value here but that the
    // Google place detail values aren't set until the "loadPlaceDetails" returns.
    // The user could potentially click "Find Hotels" before the Google place details
    // are returned. So we could have two potential problems from this. First, the call
    // to LoadEanData.loadHotelsWithLatitude:longitude: could return data for the wrong
    // place. And second, we could have mismatched data in SelectionCriteria between
    // whereTo and googlePlaceDetail.
    [SelectionCriteria singleton].whereTo = self.whereToTextFieldOutlet.text = cell.outletPlaceName.text;
    self.autoCompleteOrPlaceDetails = YES;
    [[LoadGooglePlacesData sharedInstance:self] loadPlaceDetails:cell.placeId];
    [self didFinishTextFieldKeyboard];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark Some animation methods

- (void)animateTableViewExpansion {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        typeof(self) strongSelf = weakSelf;
        CGRect acp = strongSelf.autoCompleteTableViewOutlet.frame;
        strongSelf.autoCompleteTableViewOutlet.frame = CGRectMake(acp.origin.x, acp.origin.y, acp.size.width, 322.0f);
        
        CGRect chf = strongSelf.cupHolder.frame;
        strongSelf.cupHolder.frame = CGRectMake(chf.origin.x, chf.origin.y + 322.0f, chf.size.width, chf.size.height);
    } completion:^(BOOL finished) {
        typeof(self) strongSelf = weakSelf;
        strongSelf.isAutoCompleteTableViewExpanded = YES;
    }];
}

- (void)animateTableViewCompression {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        typeof(self) strongSelf = weakSelf;
        CGRect acp = strongSelf.autoCompleteTableViewOutlet.frame;
        strongSelf.autoCompleteTableViewOutlet.frame = CGRectMake(acp.origin.x, acp.origin.y, acp.size.width, 0.0f);
        
        CGRect chf = strongSelf.cupHolder.frame;
        strongSelf.cupHolder.frame = CGRectMake(chf.origin.x, chf.origin.y - 322.0f, chf.size.width, chf.size.height);
    } completion:^(BOOL finished) {
        typeof(self) strongSelf = weakSelf;
        strongSelf.isAutoCompleteTableViewExpanded = NO;
    }];
}

#pragma mark Various Date Picker methods

- (void)presentTheDatePicker {
    [self setupTheDatePicker];
    
    if (!self.arrivalOrReturn) {
        self.datePicker.date = [SelectionCriteria singleton].arrivalDate;
    } else {
        self.datePicker.date = [SelectionCriteria singleton].returnDate;
    }
    
    [self presentSemiViewController:self.datePicker withOptions:@{
                                                                  KNSemiModalOptionKeys.pushParentBack    : @(NO),
                                                                  KNSemiModalOptionKeys.animationDuration : @(0.4),
                                                                  KNSemiModalOptionKeys.shadowOpacity     : @(0.3),
                                                                  }];
}

- (void)setupTheDatePicker {
    if(self.datePicker)
        return;
    
    self.datePicker = [THDatePickerViewController datePicker];
    self.datePicker.delegate = self;
    [self.datePicker setAllowClearDate:NO];
    [self.datePicker setClearAsToday:YES];
    [self.datePicker setAutoCloseOnSelectDate:YES];
    [self.datePicker setAllowSelectionOfSelectedDate:YES];
    [self.datePicker setDisableHistorySelection:YES];
    [self.datePicker setDisableFutureSelection:NO];
    [self.datePicker setSelectedBackgroundColor:[UIColor colorWithRed:125/255.0 green:208/255.0 blue:0/255.0 alpha:1.0]];
    [self.datePicker setCurrentDateColor:[UIColor colorWithRed:242/255.0 green:121/255.0 blue:53/255.0 alpha:1.0]];
    
    [self.datePicker setDateHasItemsCallback:^BOOL(NSDate *date) {
        int tmp = (arc4random() % 30)+1;
        if(tmp % 5 == 0)
            return YES;
        return NO;
    }];
}

-(void)refreshDisplayedArrivalDate {
    SelectionCriteria *sc = [SelectionCriteria singleton];
    if (sc.arrivalDate == nil) {
        sc.arrivalDate = [self addDays:3 ToDate:[NSDate date]];
    }
    
    [self.arrivalDateOutlet setTitle:[_viewFormatter stringFromDate:sc.arrivalDate] forState:UIControlStateNormal];
}

-(void)refreshDisplayedReturnDate {
    SelectionCriteria *sc = [SelectionCriteria singleton];
    if (sc.returnDate == nil) {
        sc.returnDate = [self addDays:6 ToDate:[NSDate date]];
    }
    
    [self.returnDateOutlet setTitle:[_viewFormatter stringFromDate:sc.returnDate] forState:UIControlStateNormal];
}

- (NSDate *)addDays:(int)days ToDate:(NSDate *)toDate {
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = days;
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    return [theCalendar dateByAddingComponents:dayComponent toDate:toDate options:0];
}

#pragma mark THDatePickerDelegate methods

- (void)datePickerDonePressed:(THDatePickerViewController *)datePicker {
    if (!self.arrivalOrReturn) {
        [SelectionCriteria singleton].arrivalDate = datePicker.date;
        [self refreshDisplayedArrivalDate];
    } else {
        [SelectionCriteria singleton].returnDate = datePicker.date;
        [self refreshDisplayedReturnDate];
    }
    
    //[self.datePicker slideDownAndOut];
    [self dismissSemiModalView];
}

- (void)datePickerCancelPressed:(THDatePickerViewController *)datePicker {
    //[self.datePicker slideDownAndOut];
    [self dismissSemiModalView];
}

- (void)datePicker:(THDatePickerViewController *)datePicker selectedDate:(NSDate *)selectedDate {
    NSLog(@"Date selected: %@",[_viewFormatter stringFromDate:selectedDate]);
}

@end
