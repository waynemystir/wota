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
    room.rateCode = [dict objectForKey:@"rateCode"];
    room.rateDescription = [dict objectForKey:@"rateDescription"];
    room.roomType = [EanAvailabilityRoomType roomTypeFromDict:[dict objectForKey:@"RoomType"]];
    room.supplierType = [dict objectForKey:@"supplierType"];
    room.propertyId = [dict objectForKey:@"propertyId"];
    room.bedTypes = [dict objectForKey:@"BedTypes"];
    
    id bta = [room.bedTypes objectForKey:@"BedType"];
    NSMutableArray *btma = [NSMutableArray array];
    
    if ([bta isKindOfClass:[NSDictionary class]]) {
        EanBedType *ebt = [EanBedType bedTypeFromDict:bta];
        if (nil != ebt) {
            [btma addObject:ebt];
        }
    } else if ([bta isKindOfClass:[NSArray class]]) {
        
        for (int j = 0; j < [bta count]; j++) {
            NSDictionary *btDict = bta[j];
            
            if (![btDict isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            EanBedType *ebt = [EanBedType bedTypeFromDict:btDict];
            if (nil != ebt) {
                [btma addObject:ebt];
            }
        }
        
    }
    
    room.bedTypesArray = [NSArray arrayWithArray:btma];
    
    if ([room.bedTypesArray count] > 0) {
        room.selectedBedType = room.bedTypesArray[0];
    }
    
    room.smokingPreferences = [dict objectForKey:@"smokingPreferences"];
    room.smokingPreferencesArray = [room.smokingPreferences componentsSeparatedByString:@","];
    
    if ([room.smokingPreferencesArray count] == 0) {
        room.selectedSmokingPreference = nil;
    } else if ([room.smokingPreferencesArray count] == 1) {
        room.selectedSmokingPreference = room.smokingPreferencesArray[0];
    } else {
        NSUInteger indNS = [room.smokingPreferencesArray indexOfObject:@"NS"];
        NSUInteger indSm = [room.smokingPreferencesArray indexOfObject:@"S"];
        NSUInteger indEr = [room.smokingPreferencesArray indexOfObject:@"E"];
        
        if (NSNotFound != indNS) {
            if (0 != indNS) {
                NSMutableArray *waynemystir = [NSMutableArray arrayWithArray:room.smokingPreferencesArray];
                id object = [waynemystir objectAtIndex:indNS];
                [waynemystir removeObjectAtIndex:indNS];
                [waynemystir insertObject:object atIndex:0];
                room.smokingPreferencesArray = [NSArray arrayWithArray:waynemystir];
            }
            
            room.selectedSmokingPreference = @"NS";
        } else if (NSNotFound != indSm) {
            room.selectedSmokingPreference = @"S";
        } else if (NSNotFound != indEr) {
            room.selectedSmokingPreference = @"E";
        } else {
            room.selectedSmokingPreference = nil;
        }
    }
    
    room.rateOccupancyPerRoom = [[dict objectForKey:@"rateOccupancyPerRoom"] integerValue];
    room.quotedOccupancy = [[dict objectForKey:@"quotedOccupancy"] integerValue];
    room.minGuestAge = [[dict objectForKey:@"minGuestAge"] integerValue];
    
    room.rateInfos = [dict objectForKey:@"RateInfos"];
    
    // TODO: I am assuming here that RateInfos contains exactly one RateInfo.
    // Is there ever a case where RateInfos contains more than one RateInfo?
    room.rateInfo = [EanRateInfo rateInfoFromDict:[room.rateInfos objectForKey:@"RateInfo"]];
    room.deepLink = [dict objectForKey:@"deepLink"];
    
    room.roomImages = [dict objectForKey:@"RoomImages"];
    // TODO: Again, can RoomImages contain more than one RoomImage?
    room.roomImage = [EanRoomImage roomImageFromDict:[room.roomImages objectForKey:@"RoomImage"]];
    
    return room;
}

@end
