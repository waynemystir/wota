//
//  StatePickerView.h
//  ota-ios
//
//  Created by WAYNE SMALL on 9/3/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StatePickerView;

@protocol StatePickerDelegate <UIPickerViewDelegate>

- (void)statePicker:(StatePickerView *)picker didSelectStateWithName:(NSString *)name code:(NSString *)code;

@end

@interface StatePickerView : UIPickerView

@property (nonatomic, weak) id<StatePickerDelegate> stateDelegate;

- (void)setSelectedStateName:(NSString *)stateName;
- (void)setSelectedStateAbbr:(NSString *)stateAbbr;
- (void)setSelectedIndex:(NSUInteger)index;

@end
