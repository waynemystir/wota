//
//  EanChargeableRateInfo.m
//  ota-ios
//
//  Created by WAYNE SMALL on 5/1/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "EanChargeableRateInfo.h"
#import "EanNightlyRate.h"
#import "EanSurcharge.h"

@implementation EanChargeableRateInfo

+ (EanChargeableRateInfo *)chargeableRateInfoFromDict:(NSDictionary *)dict {
    if (nil == dict) {
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanChargeableRateInfo *cri = [[EanChargeableRateInfo alloc] init];
    cri.averageBaseRate = [NSNumber numberWithDouble:[[dict objectForKey:@"@averageBaseRate"] doubleValue]];
    cri.averageRate = [NSNumber numberWithDouble:[[dict objectForKey:@"@averageRate"] doubleValue]];
    cri.commissionableUsdTotal = [NSNumber numberWithDouble:[[dict objectForKey:@"@commissionableUsdTotal"] doubleValue]];
    cri.currencyCode = [dict objectForKey:@"@currencyCode"];
    cri.maxNightlyRate = [NSNumber numberWithDouble:[[dict objectForKey:@"@maxNightlyRate"] doubleValue]];
    cri.nightlyRateTotal = [NSNumber numberWithDouble:[[dict objectForKey:@"@nightlyRateTotal"] doubleValue]];
    cri.surchargeTotal = [NSNumber numberWithDouble:[[dict objectForKey:@"@surchargeTotal"] doubleValue]];
    cri.total = [NSNumber numberWithDouble:[[dict objectForKey:@"@total"] doubleValue]];
    
    cri.nightlyRatesPerRoom = [dict objectForKey:@"NightlyRatesPerRoom"];
    id idNightlyRates = [cri.nightlyRatesPerRoom objectForKey:@"NightlyRate"];
    
    NSMutableArray *mutNightlyRatesArray = [NSMutableArray array];
    if (nil == idNightlyRates) {
        ;
    } else if ([idNightlyRates isKindOfClass:[NSDictionary class]]) {
        EanNightlyRate *nr = [EanNightlyRate nightRateFromDict:idNightlyRates];
        [mutNightlyRatesArray addObject:nr];
    } else if ([idNightlyRates isKindOfClass:[NSArray class]]) {
        for (int j = 0; j < [idNightlyRates count]; j++) {
            EanNightlyRate *nr = [EanNightlyRate nightRateFromDict:idNightlyRates[j]];
            [mutNightlyRatesArray addObject:nr];
        }
    }
    
    if ([mutNightlyRatesArray count] > 0) {
        cri.nightlyRatesArray = [NSArray arrayWithArray:mutNightlyRatesArray];
    }
    
    if ([cri.nightlyRatesArray count] == 0) {
        
    } else if ([cri.nightlyRatesArray count] == 1) {
        cri.nightlyRateTypeDescription = @"";
    } else {
        cri.nightlyRateTypeDescription = @"per night";
        NSNumber *nRate = ((EanNightlyRate *)cri.nightlyRatesArray[0]).rate;
        for (EanNightlyRate *enr in cri.nightlyRatesArray) {
            if (round(100*[nRate doubleValue])/100 != round(100*[enr.rate doubleValue])/100) {
                cri.nightlyRateTypeDescription = @"avg/nt";
                break;
            }
        }
    }
    
    cri.surcharges = [dict objectForKey:@"Surcharges"];
    id idSurcharges = [cri.surcharges objectForKey:@"Surcharge"];
    
    NSMutableArray *mutSurchargesArray = [NSMutableArray array];
    if (nil == idSurcharges) {
        ;
    } else if ([idSurcharges isKindOfClass:[NSDictionary class]]) {
        EanSurcharge *sc = [EanSurcharge surchargeFromDict:idSurcharges];
        [mutSurchargesArray addObject:sc];
    } else if ([idSurcharges isKindOfClass:[NSArray class]]) {
        for (int j = 0; j < [idSurcharges count]; j++) {
            EanSurcharge *sc = [EanSurcharge surchargeFromDict:idSurcharges[j]];
            [mutSurchargesArray addObject:sc];
        }
    }
    
    if ([mutSurchargesArray count] > 0) {
        cri.surchargesArray = [NSArray arrayWithArray:mutSurchargesArray];
    }
    
    if ([cri.averageBaseRate isEqual:@0]) {
        cri.discountPercentString = @"";
    } else {
        float v = ([cri.averageBaseRate floatValue] - [cri.averageRate floatValue]) / [cri.averageBaseRate floatValue];
        if (v <= 0 || v > 1.0) cri.discountPercentString = @"";
        else {
            int vs = roundf(100 * v);
            cri.discountPercentString = [NSString stringWithFormat:@"%d%%", vs];
        }
    }
    
    return cri;
}

@end
