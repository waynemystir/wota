//
//  EanHotelConfirmation.m
//  ota-ios
//
//  Created by WAYNE SMALL on 9/12/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanHotelConfirmation.h"
#import "AppEnvironment.h"

@implementation EanHotelConfirmation

+ (EanHotelConfirmation *)confirmFromDict:(NSDictionary *)dict {
    if (nil == dict) {
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanHotelConfirmation *hc = [[EanHotelConfirmation alloc] init];
    
    hc.supplierId = [[dict objectForKey:@"supplierId"] integerValue];
    hc.chainCode = [dict objectForKey:@"chainCode"];
    hc.arrivalDate = [kEanApiDateFormatter() dateFromString:[dict objectForKey:@"arrivalDate"]];
    hc.departureDate = [kEanApiDateFormatter() dateFromString:[dict objectForKey:@"departureDate"]];
    hc.confirmationNumber = [dict objectForKey:@"confirmationNumber"];
    hc.cancellationNumber = [dict objectForKey:@"cancellationNumber"];
    hc.rateInfos = [dict objectForKey:@"RateInfos"];
    
    // TODO: I am assuming here that RateInfos contains exactly one RateInfo.
    // Is there ever a case where RateInfos contains more than one RateInfo?
    hc.rateInfo = [EanRateInfo rateInfoFromDict:[hc.rateInfos objectForKey:@"RateInfo"]];
    
    hc.numberOfAdults = [[dict objectForKey:@"numberOfAdults"] intValue];
    hc.numberOfChildren = [[dict objectForKey:@"numberOfChildren"] intValue];
    hc.affiliateConfirmationId = [dict objectForKey:@"affiliateConfirmationId"];
    hc.smokingPreference = [dict objectForKey:@"smokingPreference"];
    hc.supplierPropertyId = [dict objectForKey:@"supplierPropertyId"];
    hc.status = [dict objectForKey:@"status"];
    
    return hc;
}

@end
