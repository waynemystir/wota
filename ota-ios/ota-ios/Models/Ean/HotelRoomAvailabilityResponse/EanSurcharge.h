//
//  EanSurcharge.h
//  ota-ios
//
//  Created by WAYNE SMALL on 5/1/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SURCHARGE_TYPE) {
    TaxAndServiceFee,
    ExtraPersonFee,
    Tax,
    ServiceFee,
    SalesTax,
    HotelOccupancyTax,
    Other
};

@interface EanSurcharge : NSObject

@property (nonatomic, strong) NSNumber *amount;
@property (nonatomic, strong) NSString *typeEanString;
@property (nonatomic) SURCHARGE_TYPE surchargeType;

+ (EanSurcharge *)surchargeFromDict:(NSDictionary *)dict;

@end
