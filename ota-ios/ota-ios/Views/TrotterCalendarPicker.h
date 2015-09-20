//
//  TrotterCalendarPicker.h
//  ota-ios
//
//  Created by WAYNE SMALL on 7/26/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class TrotterCalendarPicker;

@protocol TrotterCalendarPickerDelegate <NSObject>

- (void)calendarPickerDidSelectDate:(NSDate *)selectedDate;
- (void)calendarPickerDonePressed;
- (void)calendarPickerCancelled;
- (void)calendarPickerDidHide;
- (void)goodTimeToRedrawCalendarPicker:(TrotterCalendarPicker *)tcp;

@end

@interface TrotterCalendarPicker : UIView

@property (nonatomic, strong) NSDate *dwaDate;
@property (nonatomic, strong) NSString *arrivalOrDepartureString;
@property (weak, nonatomic) NSObject<TrotterCalendarPickerDelegate> *calendarDelegate;
@property (strong, nonatomic) UIColor *selectedBackgroundColor;
@property (strong, nonatomic) UIColor *currentDateColor;
@property (strong, nonatomic) UIColor *currentDateColorSelected;
@property (nonatomic) float autoCloseCancelDelay;
@property (nonatomic, strong) NSDate *maxDate;
@property (nonatomic, strong) NSDate *minDate;
@property (nonatomic) BOOL allowClearDate;
@property (nonatomic) BOOL allowSelectionOfSelectedDate;
@property (nonatomic) BOOL clearAsToday;
@property (nonatomic) BOOL autoCloseOnSelectDate;
@property (nonatomic) BOOL disableHistorySelection;
@property (nonatomic) BOOL disableFutureSelection;

- (void)loadDatePicker;
- (void)redraw;
+ (TrotterCalendarPicker *)calendarFromNib;

@end
