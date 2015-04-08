//
//  EanHotelRoomResponse.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/4/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanAvailabilityHotelRoomResponse.h"

@implementation EanAvailabilityHotelRoomResponse

+ (EanAvailabilityHotelRoomResponse *)roomFromDict:(NSDictionary *)dict {
    if (nil == dict) {
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanAvailabilityHotelRoomResponse *room = [[EanAvailabilityHotelRoomResponse alloc] init];
    room.cancellationPolicy = [dict objectForKey:@"cancellationPolicy"];
    room.rateCode = [dict objectForKey:@"rateCode"];
    room.roomTypeCode = [dict objectForKey:@"roomTypeCode"];
    room.rateDescription = [dict objectForKey:@"rateDescription"];
    room.roomTypeDescription = [dict objectForKey:@"roomTypeDescription"];
    room.supplierType = [dict objectForKey:@"supplierType"];
    room.taxRate = [dict objectForKey:@"taxRate"];
    room.rateChange = [[dict objectForKey:@"rateChange"] boolValue];
    room.nonRefundable = [[dict objectForKey:@"nonRefundable"] boolValue];
    room.guaranteeRequired = [[dict objectForKey:@"guaranteeRequired"] boolValue];
    room.depositRequired = [[dict objectForKey:@"depositRequired"] boolValue];
    room.immediateChargeRequired = [[dict objectForKey:@"immediateChargeRequired"] boolValue];
    room.currentAllotment = [[dict objectForKey:@"currentAllotment"] integerValue];
    room.propertyId = [dict objectForKey:@"propertyId"];
    room.bedTypes = [dict objectForKey:@"BedTypes"];
    room.cancelPolicyInfoList = [dict objectForKey:@"CancelPolicyInfoList"];
    room.smokingPreferences = [dict objectForKey:@"smokingPreferences"];
    room.rateOccupancyPerRoom = [[dict objectForKey:@"rateOccupancyPerRoom"] integerValue];
    room.quotedOccupancy = [[dict objectForKey:@"quotedOccupancy"] integerValue];
    room.minGuestAge = [[dict objectForKey:@"minGuestAge"] integerValue];
    room.rateInfo = [dict objectForKey:@"RateInfo"];
    room.chargeableRateInfo = [room.rateInfo objectForKey:@"ChargeableRateInfo"];
    room.chargeableRate = [[room.chargeableRateInfo objectForKey:@"@total"] floatValue];
    room.deepLink = [dict objectForKey:@"deepLink"];
    return room;
}

@end
