//
//  StatePickerView.m
//  ota-ios
//
//  Created by WAYNE SMALL on 9/3/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "StatePickerView.h"

@interface StatePickerView () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) NSDictionary *usAbbrevs;
@property (nonatomic, strong) NSDictionary *caAbbrevs;
@property (nonatomic, strong) NSDictionary *auAbbrevs;
@property (nonatomic, strong) NSArray *stateNames;

@end

@implementation StatePickerView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        super.dataSource = self;
        super.delegate = self;
        NSString *file = @"USStateAbbreviations";
        NSString *stateAbbrPath = [[NSBundle mainBundle] pathForResource:file ofType:@"plist"];
        _usAbbrevs = [NSDictionary dictionaryWithContentsOfFile:stateAbbrPath];
    }
    return self;
}

- (NSArray *)stateNames {
    static NSArray *_sn = nil;
    if (!_sn) {
        NSMutableArray *marr = [[self.usAbbrevs.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] mutableCopy];
        [marr insertObject:@"" atIndex:0];
        _sn = [NSArray arrayWithArray:marr];
    }
    return _sn;
}

- (void)setSelectedStateName:(NSString *)stateName {
    NSUInteger index = [self.stateNames indexOfObject:stateName];
    [self selectRow:index inComponent:0 animated:NO];
}

- (void)setSelectedStateAbbr:(NSString *)stateAbbr {
    NSString *stateName = [self.usAbbrevs allKeysForObject:stateAbbr].firstObject;
    [self setSelectedStateName:stateName];
}

- (void)setSelectedIndex:(NSUInteger)index {
    [self selectRow:index inComponent:0 animated:NO];
}

- (NSInteger)numberOfComponentsInPickerView:(__unused UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(__unused UIPickerView *)pickerView numberOfRowsInComponent:(__unused NSInteger)component {
    return (NSInteger)self.usAbbrevs.count;
}

- (UIView *)pickerView:(__unused UIPickerView *)pickerView viewForRow:(NSInteger)row
          forComponent:(__unused NSInteger)component reusingView:(UIView *)view {
    if (!view) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 30)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(35, 3, 245, 24)];
        label.backgroundColor = [UIColor clearColor];
        label.tag = 1;
        [view addSubview:label];
    }
    
    ((UILabel *)[view viewWithTag:1]).text = self.stateNames[(NSUInteger)row];
    
    return view;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *stateName = self.stateNames[(NSUInteger)row];
    NSString *code = [self.usAbbrevs objectForKey:stateName];
    [self.stateDelegate statePicker:self didSelectStateWithName:stateName code:code];
}

@end
