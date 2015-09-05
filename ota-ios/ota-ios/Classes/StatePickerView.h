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
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *selectedStateAbbr;
@property (nonatomic, strong) NSString *selectedStateName;

@end
