//
//  EanHotelConfirmation.h
//  ota-ios
//
//  Created by WAYNE SMALL on 9/12/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EanRateInfo.h"

@interface EanHotelConfirmation : NSObject

@property (nonatomic) NSInteger supplierId;
@property (nonatomic, strong) NSString *chainCode;
@property (nonatomic, strong) NSDate *arrivalDate;
@property (nonatomic, strong) NSDate *departureDate;
@property (nonatomic, strong) NSNumber *confirmationNumber;
@property (nonatomic) id cancellationNumber;
@property (nonatomic, strong) NSDictionary *rateInfos;
@property (nonatomic, strong) EanRateInfo *rateInfo;
@property (nonatomic) int numberOfAdults;
@property (nonatomic) int numberOfChildren;
@property (nonatomic, strong) NSString *affiliateConfirmationId;
@property (nonatomic, strong) NSString *smokingPreference;
@property (nonatomic, strong) id supplierPropertyId;
@property (nonatomic, strong) NSString *status;

+ (EanHotelConfirmation *)confirmFromDict:(NSDictionary *)dict;

@end
