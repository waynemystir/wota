//
//  SelectBedTypeDelegateImplementation.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/24/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EanBedType.h"

@protocol SelectBedTypeDelegate <NSObject>

@required

- (void)didSelectBedType:(EanBedType *)eanBedType;

@end

@interface SelectBedTypeDelegateImplementation : NSObject <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) NSArray *pickerData;
@property (nonatomic, weak) id<SelectBedTypeDelegate> bedTypeDelegate;

@end
