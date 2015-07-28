//
//  SelectSmokingPreferenceDelegateImplementation.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/25/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectSmokingPrefDelegate <NSObject>

@required

- (void)didSelectSmokingPref:(NSString *)eanSmokeCode;

@end

@interface SelectSmokingPreferenceDelegateImplementation : NSObject <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) NSArray *pickerData;
@property (nonatomic, weak) id<SelectSmokingPrefDelegate> smokePrefDelegate;

+ (NSString *)smokingPrefStringForEanSmokeCode:(NSString *)eanSmokeCode;
+ (NSString *)eanSmokeCodeForSmokingPrefString:(NSString *)smokingPrefString;

@end
