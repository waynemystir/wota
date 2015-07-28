//
//  SelectBedTypeDelegateImplementation.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/24/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "SelectBedTypeDelegateImplementation.h"

@implementation SelectBedTypeDelegateImplementation

#pragma mark UIPickerViewDataSource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_pickerData count];
}

#pragma mark UIPickerViewDelegate methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return ((EanBedType *)_pickerData[row]).bedTypeDescription;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([self.bedTypeDelegate respondsToSelector:@selector(didSelectBedType:)]) {
        [self.bedTypeDelegate didSelectBedType:_pickerData[row]];
    }
}

@end
