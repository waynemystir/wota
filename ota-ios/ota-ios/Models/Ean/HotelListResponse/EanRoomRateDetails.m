//
//  EanRoomRateDetails.m
//  ota-ios
//
//  Created by WAYNE SMALL on 5/25/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanRoomRateDetails.h"

@implementation EanRoomRateDetails

+ (EanRoomRateDetails *)roomRateDetailsFromDict:(NSDictionary *)dict {
    if (nil == dict) {
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanRoomRateDetails *rrd = [[EanRoomRateDetails alloc] init];
    rrd.roomTypeCode = [dict objectForKey:@"roomTypeCode"];
    rrd.rateCode = [dict objectForKey:@"rateCode"];
    rrd.maxRoomOccupancy = [[dict objectForKey:@"maxRoomOccupancy"] integerValue];
    rrd.quotedRoomOccupancy = [[dict objectForKey:@"quotedRoomOccupancy"] integerValue];
    rrd.minGuestAge = [[dict objectForKey:@"minGuestAge"] integerValue];
    rrd.roomDescription = [dict objectForKey:@"roomDescription"];
    rrd.propertyAvailable = [[dict objectForKey:@"propertyAvailable"] boolValue];
    rrd.propertyRestricted = [[dict objectForKey:@"propertyRestricted"] boolValue];
    rrd.expediaPropertyId = [dict objectForKey:@"expediaPropertyId"];
    
    rrd.rateInfos = [dict objectForKey:@"RateInfos"];
    
    // TODO: I am assuming here that RateInfos contains exactly one RateInfo.
    // Is there ever a case where RateInfos contains more than one RateInfo?
    rrd.rateInfo = [EanRateInfo rateInfoFromDict:[rrd.rateInfos objectForKey:@"RateInfo"]];
    
    return rrd;
}

@end
