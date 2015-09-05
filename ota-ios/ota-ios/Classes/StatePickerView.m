//
//  StatePickerView.m
//  ota-ios
//
//  Created by WAYNE SMALL on 9/3/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "StatePickerView.h"

static NSArray *_sn = nil;

@interface StatePickerView () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) NSDictionary *usAbbrevs;
@property (nonatomic, strong) NSDictionary *caAbbrevs;
@property (nonatomic, strong) NSDictionary *auAbbrevs;
@property (nonatomic, strong) NSDictionary *designatedAbbrevs;
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
        
        file = @"AUStateAbbreviations";
        stateAbbrPath = [[NSBundle mainBundle] pathForResource:file ofType:@"plist"];
        _auAbbrevs = [NSDictionary dictionaryWithContentsOfFile:stateAbbrPath];
        
        file = @"CAStateAbbreviations";
        stateAbbrPath = [[NSBundle mainBundle] pathForResource:file ofType:@"plist"];
        _caAbbrevs = [NSDictionary dictionaryWithContentsOfFile:stateAbbrPath];
    }
    return self;
}

- (void)setCountry:(NSString *)country {
    _country = country;
    [self setTheStateNames];
}

- (void)setTheStateNames {
    if ([_country isEqualToString:@"US"]) {
        _designatedAbbrevs = _usAbbrevs;
    } else if ([_country isEqualToString:@"AU"]) {
        _designatedAbbrevs = _auAbbrevs;
    } else if ([_country isEqualToString:@"CA"]) {
        _designatedAbbrevs = _caAbbrevs;
    } else {
        _designatedAbbrevs = nil;
    }
    
    NSMutableArray *marr = [[_designatedAbbrevs.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] mutableCopy];
    [marr insertObject:@"" atIndex:0];
    _sn = [NSArray arrayWithArray:marr];
}

- (NSArray *)stateNames {
    if (!_sn) [self setTheStateNames];
    return _sn;
}

- (void)setSelectedStateAbbr:(NSString *)stateAbbr {
    NSString *stateName = [self.designatedAbbrevs allKeysForObject:stateAbbr].firstObject;
    self.selectedStateName = stateName;
}

- (void)setSelectedStateName:(NSString *)stateName {
    NSUInteger index = [self.stateNames indexOfObject:stateName];
    if (index == NSNotFound) return;
    [self selectRow:index inComponent:0 animated:NO];
}

- (void)reloadAllComponents {
    [super reloadAllComponents];
    [self selectRow:0 inComponent:0 animated:NO];
}

- (NSInteger)numberOfComponentsInPickerView:(__unused UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(__unused UIPickerView *)pickerView numberOfRowsInComponent:(__unused NSInteger)component {
    return (NSInteger)self.stateNames.count;
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
    NSString *code = [self.designatedAbbrevs objectForKey:stateName];
    [self.stateDelegate statePicker:self didSelectStateWithName:stateName code:code];
}

@end
