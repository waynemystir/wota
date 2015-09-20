//
//  TrotterCalendarPicker.m
//  ota-ios
//
//  Created by WAYNE SMALL on 7/26/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "TrotterCalendarPicker.h"
#import "WotaButton.h"
#import "TrotterCalendarDay.h"

@interface TrotterCalendarPicker () <TrotterCalendarDayDelegate> {
    int _weeksOnCalendar;
    int _bufferDaysBeginning;
    int _daysInMonth;
    NSDate * _dateNoTime;
    NSCalendar * _calendar;
}

@property (nonatomic, strong) NSDate * firstOfCurrentMonth;
@property (nonatomic, strong) TrotterCalendarDay * currentDay;
@property (nonatomic, strong) NSDate * internalDate;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIButton *prevBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIButton *clearBtn;
@property (strong, nonatomic) IBOutlet UIView *calendarDaysView;
@property (weak, nonatomic) IBOutlet UIView *weekdaysView;
@property (weak, nonatomic) IBOutlet UILabel *arriveOrDepartLabel;
@property (weak, nonatomic) IBOutlet WotaButton *doneBtn;

- (IBAction)nextMonthPressed:(id)sender;
- (IBAction)prevMonthPressed:(id)sender;
- (IBAction)donePressed:(id)sender;

@end

@implementation TrotterCalendarPicker {
    UIControl *overlay;
}

@synthesize dwaDate = _dwaDate;
@synthesize selectedBackgroundColor = _selectedBackgroundColor;
@synthesize currentDateColor = _currentDateColor;
@synthesize currentDateColorSelected = _currentDateColorSelected;
@synthesize autoCloseCancelDelay = _autoCloseCancelDelay;

+ (TrotterCalendarPicker *)calendarFromNib {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"TrotterCalendarPicker" owner:self options:nil];
    if ([views count] != 1) {
        return nil;
    }
    
    return views.firstObject;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.frame = CGRectMake(0, 569, 320, 320);
        overlay = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
        overlay.backgroundColor = [UIColor blackColor];
        overlay.alpha = 0.0f;
        [overlay addTarget:self action:@selector(overlayClicked) forControlEvents:UIControlEventTouchUpInside];
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        _allowClearDate = NO;
        _allowSelectionOfSelectedDate = NO;
        _clearAsToday = NO;
        _disableFutureSelection = NO;
        _disableHistorySelection = NO;
        _autoCloseCancelDelay = 1.0;
    }
    return self;
}

- (void)setArrivalOrDepartureString:(NSString *)arrivalOrDepartureString {
    _arriveOrDepartLabel.text = _arrivalOrDepartureString = arrivalOrDepartureString;
}

#pragma mark Load and drop

- (void)loadDatePicker {
    __weak typeof(self) tcp = self;
    __weak typeof(UIView) *sv = self.superview;
    
    [sv addSubview:overlay];
    [sv bringSubviewToFront:overlay];
    [sv bringSubviewToFront:tcp];
    
    [UIView animateWithDuration:0.28 animations:^{
        overlay.alpha = 0.7;
        tcp.frame = CGRectMake(0, 248, 320, 320);
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)dropDatePicker {
    __weak typeof(self) tcp = self;
    __weak typeof(UIView) *sv = self.superview;
    
    [UIView animateWithDuration:0.28 animations:^{
        overlay.alpha = 0.0f;
        tcp.frame = CGRectMake(0, 569, 320, 320);
    } completion:^(BOOL finished) {
        [sv sendSubviewToBack:overlay];
        [overlay removeFromSuperview];
        [sv sendSubviewToBack:tcp];
        [tcp.calendarDelegate calendarPickerDidHide];
    }];
    
    [self.calendarDelegate performSelector:@selector(goodTimeToRedrawCalendarPicker:) withObject:self afterDelay:0.01];
}

#pragma Redraw

- (void)redraw {
    if(!self.firstOfCurrentMonth) [self setDisplayedMonthFromDate:[NSDate date]];
    for(UIView * view in self.calendarDaysView.subviews){ // clean view
        [view removeFromSuperview];
    }
    [self redrawDays];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM yyyy"];
    NSString *monthName = [formatter stringFromDate:self.firstOfCurrentMonth];
    self.monthLabel.text = monthName;
}

- (void)redrawDays {
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:-_bufferDaysBeginning];
    NSDate * date = [_calendar dateByAddingComponents:offsetComponents toDate:self.firstOfCurrentMonth options:0];
    [offsetComponents setDay:1];
    UIView * container = self.calendarDaysView;
    CGRect containerFrame = container.frame;
    int areaWidth = containerFrame.size.width;
    int areaHeight = containerFrame.size.height;
    int cellWidth = areaWidth/7;
    int cellHeight = areaHeight/_weeksOnCalendar;
    int days = _weeksOnCalendar*7;
    int curY = (areaHeight - cellHeight*_weeksOnCalendar)/2;
    int origX = (areaWidth - cellWidth*7)/2;
    int curX = origX;
    [self redrawWeekdays:cellWidth];
    for(int i = 0; i < days; i++){
        // @beginning
        if(i && !(i%7)) {
            curX = origX;
            curY += cellHeight;
        }
        
        TrotterCalendarDay * day = [[NSBundle mainBundle] loadNibNamed:@"TrotterCalendarDay" owner:self options:nil].firstObject;
        day.frame = CGRectMake(curX, curY, cellWidth, cellHeight);
        day.delegate = self;
        day.date = [date dateByAddingTimeInterval:0];
        if (self.currentDateColor)
            [day setCurrentDateColor:self.currentDateColor];
        if (self.currentDateColorSelected)
            [day setCurrentDateColorSelected:self.currentDateColorSelected];
        if (self.selectedBackgroundColor)
            [day setSelectedBackgroundColor:self.selectedBackgroundColor];
        
        [day setLightText:![self dateInCurrentMonth:date]];
        //        [day setEnabled:![self dateInFutureAndShouldBeDisabled:date]];
        [day setEnabled:[self dateIsWithinAcceptableRange:date]];
        [day indicateDayHasItems:NO];
        
        NSDateComponents *comps = [_calendar components:NSCalendarUnitDay fromDate:date];
        [day.dateButton setTitle:[NSString stringWithFormat:@"%ld",(long)[comps day]]
                        forState:UIControlStateNormal];
        [self.calendarDaysView addSubview:day];
        if (_internalDate && ![date timeIntervalSinceDate:_internalDate]) {
            self.currentDay = day;
            [day setSelected:YES];
        }
        // @end
        date = [_calendar dateByAddingComponents:offsetComponents toDate:date options:0];
        curX += cellWidth;
    }
}

- (BOOL)dateIsWithinAcceptableRange:(NSDate *)theDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger comps = (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear);
    theDate = [calendar dateFromComponents:[calendar components:comps fromDate:theDate]];
    NSDate *minDate = [calendar dateFromComponents:[calendar components:comps fromDate:_minDate]];
    NSDate *maxDate = [calendar dateFromComponents:[calendar components:comps fromDate:_maxDate]];
    BOOL aboveMin = [theDate compare:minDate] == NSOrderedDescending || [theDate compare:minDate] == NSOrderedSame;
    BOOL belowMax = [theDate compare:_maxDate] == NSOrderedAscending || [theDate compare:maxDate] == NSOrderedSame;
    return aboveMin && belowMax;
}

- (void)redrawWeekdays:(int)dayWidth {
    if(!self.weekdaysView.subviews.count) {
        CGSize fullSize = self.weekdaysView.frame.size;
        int curX = (fullSize.width - 7*dayWidth)/2;
        NSDateComponents * comps = [_calendar components:NSCalendarUnitDay fromDate:[NSDate date]];
        NSCalendar *c = [NSCalendar currentCalendar];
        [comps setDay:[c firstWeekday]-1];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        [offsetComponents setDay:1];
        [df setDateFormat:@"EE"];
        NSDate * date = [_calendar dateFromComponents:comps];
        for(int i = 0; i < 7; i++){
            UILabel * dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(curX, 0, dayWidth, fullSize.height)];
            dayLabel.textAlignment = NSTextAlignmentCenter;
            dayLabel.font = [UIFont systemFontOfSize:12];
            [self.weekdaysView addSubview:dayLabel];
            dayLabel.text = [df stringFromDate:date];
            dayLabel.textColor = [UIColor grayColor];
            date = [_calendar dateByAddingComponents:offsetComponents toDate:date options:0];
            curX+=dayWidth;
        }
    }
}

#pragma mark - Date Set, etc.

- (void)setDwaDate:(NSDate *)date {
    _dwaDate = date;
    _dateNoTime = !date ? nil : [self dateWithOutTime:date];
    self.internalDate = [_dateNoTime dateByAddingTimeInterval:0];
}

- (NSDate *)dwaDate {
    if(!self.internalDate) return nil;
    else if(!_dwaDate) return self.internalDate;
    else {
        int ymd = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
        NSDateComponents* internalComps = [_calendar components:ymd fromDate:self.internalDate];
        int time = NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond|NSCalendarUnitTimeZone;
        NSDateComponents* origComps = [_calendar components:time fromDate:_dwaDate];
        [origComps setDay:[internalComps day]];
        [origComps setMonth:[internalComps month]];
        [origComps setYear:[internalComps year]];
        return [_calendar dateFromComponents:origComps];
    }
}

- (void)setClearAsToday:(BOOL)clearAsToday {
    if (clearAsToday) {
        [self setAllowClearDate:clearAsToday];
    }
    _clearAsToday = clearAsToday;
}

- (void)setAutoCloseOnSelectDate:(BOOL)autoCloseOnSelectDate {
    if (!_allowClearDate)
        [self setAllowClearDate:!autoCloseOnSelectDate];
    _autoCloseOnSelectDate = autoCloseOnSelectDate;
}

- (BOOL)shouldOkBeEnabled {
    if (_autoCloseOnSelectDate)
        return YES;
    return (self.internalDate && _dateNoTime && (_allowSelectionOfSelectedDate || [self.internalDate timeIntervalSinceDate:_dateNoTime]))
    || (self.internalDate && !_dateNoTime)
    || (!self.internalDate && _dateNoTime);
}

- (void)setInternalDate:(NSDate *)internalDate{
    _internalDate = internalDate;
    self.clearBtn.enabled = !!internalDate;
    self.doneBtn.enabled = [self shouldOkBeEnabled];
    if(internalDate){
        [self setDisplayedMonthFromDate:internalDate];
    } else {
        [self.currentDay setSelected:NO];
        self.currentDay =  nil;
    }
}

- (void)setDisplayedMonth:(int)month year:(int)year{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM"];
    self.firstOfCurrentMonth = [df dateFromString: [NSString stringWithFormat:@"%d-%@%d", year, (month<10?@"0":@""), month]];
    [self storeDateInformation];
}

- (void)setDisplayedMonthFromDate:(NSDate *)date{
    NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
    [self setDisplayedMonth:(int)[comps month] year:(int)[comps year]];
}

- (void)storeDateInformation{
    NSDateComponents *comps = [_calendar components:NSCalendarUnitWeekday | NSCalendarUnitDay fromDate:self.firstOfCurrentMonth];
    NSCalendar *c = [NSCalendar currentCalendar];
#ifdef DEBUG
    //[c setFirstWeekday:FIRST_WEEKDAY];
#endif
    NSRange days = [c rangeOfUnit:NSCalendarUnitDay
                           inUnit:NSCalendarUnitMonth
                          forDate:self.firstOfCurrentMonth];
    
    int bufferDaysBeginning = (int)([comps weekday]-[c firstWeekday]);
    // % 7 is not working for negative numbers
    // http://stackoverflow.com/questions/989943/weird-objective-c-mod-behavior-for-negative-numbers
    if (bufferDaysBeginning < 0)
        bufferDaysBeginning += 7;
    int daysInMonthWithBuffer = (int)(days.length + bufferDaysBeginning);
    int numberOfWeeks = daysInMonthWithBuffer / 7;
    if(daysInMonthWithBuffer % 7) numberOfWeeks++;
    
    _weeksOnCalendar = 6;
    _bufferDaysBeginning = bufferDaysBeginning;
    _daysInMonth = (int)days.length;
}

- (void)incrementMonth:(int)incrValue{
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setMonth:incrValue];
    NSDate * incrementedMonth = [_calendar dateByAddingComponents:offsetComponents toDate:self.firstOfCurrentMonth options:0];
    [self setDisplayedMonthFromDate:incrementedMonth];
}

#pragma mark - User Events

- (void)calendarDayClicked:(TrotterCalendarDay *)calendarDay {
    if (!_internalDate || [_internalDate timeIntervalSinceDate:calendarDay.date] || _allowSelectionOfSelectedDate) { // new date selected
        [self.currentDay setSelected:NO];
        [calendarDay setSelected:YES];
        BOOL dateInDifferentMonth = ![self dateInCurrentMonth:calendarDay.date];
        [self setInternalDate:calendarDay.date];
        [self setCurrentDay:calendarDay];
        if (dateInDifferentMonth) {
            [self slideTransitionViewInDirection:[calendarDay.date timeIntervalSinceDate:self.firstOfCurrentMonth]];
        }
        [self.calendarDelegate calendarPickerDidSelectDate:calendarDay.date];
        if (_autoCloseOnSelectDate) {
            [self dropDatePicker];
        }
    }
}

- (void)dateDayTapped:(TrotterCalendarDay *)dateDay {
    if (!_internalDate || [_internalDate timeIntervalSinceDate:dateDay.date] || _allowSelectionOfSelectedDate) { // new date selected
        [self.currentDay setSelected:NO];
        [dateDay setSelected:YES];
        BOOL dateInDifferentMonth = ![self dateInCurrentMonth:dateDay.date];
        [self setInternalDate:dateDay.date];
        [self setCurrentDay:dateDay];
        if (dateInDifferentMonth) {
            [self slideTransitionViewInDirection:[dateDay.date timeIntervalSinceDate:self.firstOfCurrentMonth]];
        }
        [self.calendarDelegate calendarPickerDidSelectDate:dateDay.date];
        if (_autoCloseOnSelectDate) {
            [self dropDatePicker];
        }
    }
}

- (void)slideTransitionViewInDirection:(int)dir {
    dir = dir < 1 ? -1 : 1;
    CGRect origFrame = self.calendarDaysView.frame;
    CGRect outDestFrame = origFrame;
    outDestFrame.origin.y -= 20*dir;
    CGRect inStartFrame = origFrame;
    inStartFrame.origin.y += 20*dir;
    UIView *oldView = self.calendarDaysView;
    UIView *newView = self.calendarDaysView = [[UIView alloc] initWithFrame:inStartFrame];
    [oldView.superview addSubview:newView];
    [self addSwipeGestures];
    newView.alpha = 0;
    [self redraw];
    [UIView animateWithDuration:.1 animations:^{
        newView.frame = origFrame;
        newView.alpha = 1;
        oldView.frame = outDestFrame;
        oldView.alpha = 0;
    } completion:^(BOOL finished) {
        [oldView removeFromSuperview];
    }];
}

- (IBAction)nextMonthPressed:(id)sender {
    [self incrementMonth:1];
    [self slideTransitionViewInDirection:1];
}

- (IBAction)prevMonthPressed:(id)sender {
    [self incrementMonth:-1];
    [self slideTransitionViewInDirection:-1];
}

- (IBAction)donePressed:(id)sender {
    if(self.doneBtn.enabled) {
        [self.calendarDelegate calendarPickerDonePressed];
        [self dropDatePicker];
    }
}

- (void)overlayClicked {
    [self.calendarDelegate calendarPickerCancelled];
    [self dropDatePicker];
}

- (IBAction)clearPressed:(id)sender {
    if(self.clearBtn.enabled){
        if (_clearAsToday) {
            [self setDwaDate:[NSDate date]];
            [self redraw];
            if (_autoCloseOnSelectDate) {
                [self.doneBtn setUserInteractionEnabled:NO];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.autoCloseCancelDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.calendarDelegate calendarPickerDonePressed];
                    [self.doneBtn setUserInteractionEnabled:YES];
                });
            }
        } else {
            self.internalDate = nil;
            [self.currentDay setSelected:NO];
            self.currentDay = nil;
        }
    }
}

- (IBAction)closePressed:(id)sender {
    [self.calendarDelegate calendarPickerCancelled];
}

#pragma mark - Hide/Show Clear Button

- (void) showClearButton {
    int width = self.frame.size.width;
    int buttonHeight = 37;
    int buttonWidth = (width-20)/3;
    int curX = (width - buttonWidth*3 - 10)/2;
    self.closeBtn.frame = CGRectMake(curX, 5, buttonWidth, buttonHeight);
    curX+=buttonWidth+5;
    self.clearBtn.frame = CGRectMake(curX, 5, buttonWidth, buttonHeight);
    curX+=buttonWidth+5;
    //    self.okBtn.frame = CGRectMake(curX, 5, buttonWidth, buttonHeight);
    if (_clearAsToday) {
        [self.clearBtn setImage:nil forState:UIControlStateNormal];
        [self.clearBtn setTitle:NSLocalizedString(@"TODAY", @"Customize this for your language") forState:UIControlStateNormal];
    } else {
        [self.clearBtn setImage:[UIImage imageNamed:@"dialog_clear"] forState:UIControlStateNormal];
        [self.clearBtn setTitle:nil forState:UIControlStateNormal];
    }
}

- (void) hideClearButton {
    int width = self.frame.size.width;
    int buttonHeight = 37;
    self.clearBtn.hidden = YES;
    int buttonWidth = (width-15)/2;
    int curX = (width - buttonWidth*2 - 5)/2;
    self.closeBtn.frame = CGRectMake(curX, 5, buttonWidth, buttonHeight);
    curX+=buttonWidth+5;
    //    self.okBtn.frame = CGRectMake(curX, 5, buttonWidth, buttonHeight);
}

#pragma mark - Date Utils

- (BOOL)dateInFutureAndShouldBeDisabled:(NSDate *)dateToCompare {
    NSDate *currentDate = [self dateWithOutTime:[NSDate date]];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger comps = (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear);
    currentDate = [calendar dateFromComponents:[calendar components:comps fromDate:currentDate]];
    dateToCompare = [calendar dateFromComponents:[calendar components:comps fromDate:dateToCompare]];
    NSComparisonResult compResult = [currentDate compare:dateToCompare];
    return (compResult == NSOrderedDescending && _disableHistorySelection) || (compResult == NSOrderedAscending && _disableFutureSelection);
}

- (BOOL)dateInCurrentMonth:(NSDate *)date{
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [_calendar components:unitFlags fromDate:self.firstOfCurrentMonth];
    NSDateComponents* comp2 = [_calendar components:unitFlags fromDate:date];
    return [comp1 year]  == [comp2 year] && [comp1 month] == [comp2 month];
}

- (NSDate *)dateWithOutTime:(NSDate *)datDate {
    if(!datDate) {
        datDate = [NSDate date];
    }
    NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:datDate];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

#pragma mark swipe gestures

- (void)addSwipeGestures{
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionUp;
    [self.calendarDaysView addGestureRecognizer:swipeGesture];
    
    UISwipeGestureRecognizer *swipeGesture2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeGesture2.direction = UISwipeGestureRecognizerDirectionDown;
    [self.calendarDaysView addGestureRecognizer:swipeGesture2];
}

- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)sender{
    //Gesture detect - swipe up/down , can be recognized direction
    if(sender.direction == UISwipeGestureRecognizerDirectionUp){
        [self incrementMonth:1];
        [self slideTransitionViewInDirection:1];
    }
    else if(sender.direction == UISwipeGestureRecognizerDirectionDown){
        [self incrementMonth:-1];
        [self slideTransitionViewInDirection:-1];
    }
}

@end
