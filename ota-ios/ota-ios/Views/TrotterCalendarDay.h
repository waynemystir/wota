//
//  TrotterCalendarDay.h
//  ota-ios
//
//  Created by WAYNE SMALL on 7/26/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TrotterCalendarDay;

@protocol TrotterCalendarDayDelegate <NSObject>

- (void)calendarDayClicked:(TrotterCalendarDay *)calendarDay;

@end

@interface TrotterCalendarDay : UIView

@property (weak, nonatomic) id<TrotterCalendarDayDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *hasItemsIndicator;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;

@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) UIColor *selectedBackgroundColor;
@property (strong, nonatomic) UIColor *currentDateColor;
@property (strong, nonatomic) UIColor *currentDateColorSelected;

- (IBAction)dateButtonTapped:(id)sender;

- (void)setLightText:(BOOL)light;
- (void)setSelected:(BOOL)selected;
- (void)setEnabled:(BOOL)enabled;
- (void)indicateDayHasItems:(BOOL)indicate;

@end
