//
//  SelectSmokingPreferenceDelegateImplementation.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/25/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "SelectSmokingPreferenceDelegateImplementation.h"

@implementation SelectSmokingPreferenceDelegateImplementation

#pragma mark UIPickerViewDataSource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_pickerData count];
}

#pragma mark UIPickerViewDelegate methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[self class] smokingPrefStringForEanSmokeCode:_pickerData[row]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([self.smokePrefDelegate respondsToSelector:@selector(didSelectSmokingPref:)]) {
        [self.smokePrefDelegate didSelectSmokingPref:_pickerData[row]];
    }
}

#pragma mark Methods to convert between Ean Smoke Code and a smoking preference string

+ (NSString *)smokingPrefStringForEanSmokeCode:(NSString *)eanSmokeCode {
    if ([eanSmokeCode isEqualToString:@"NS"]) {
        return @"Non-smoking";
    } else if ([eanSmokeCode isEqualToString:@"S"]) {
        return @"Smoking";
    } else {
        return @"Either";
    }
}

+ (NSString *)eanSmokeCodeForSmokingPrefString:(NSString *)smokingPrefString {
    if ([smokingPrefString isEqualToString:@"Non-smoking"]) {
        return @"NS";
    } else if ([smokingPrefString isEqualToString:@"Smoking"]) {
        return @"S";
    } else {
        return @"E";
    }
}

@end
