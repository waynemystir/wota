//
//  EanHotelRoomAvailabilityResponse.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/4/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanHotelRoomAvailabilityResponse.h"
#import "EanAvailabilityHotelRoomResponse.h"
#import "EanRateInfo.h"
#import "EanCancelPolicyInfo.h"
#import "AppEnvironment.h"
#import "EanNightlyRate.h"

NSString * const kNonrefundableString = @"This rate is non-refundable";
NSString * const kFreeCancelString = @"Free Cancellation by";

@implementation EanHotelRoomAvailabilityResponse

+ (instancetype)eanObjectFromApiJsonResponse:(id)jsonResponse {
    if (nil == jsonResponse) {
        return nil;
    }
    
    if (![jsonResponse isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    id idHrar = [jsonResponse objectForKey:@"HotelRoomAvailabilityResponse"];
    
    if (nil == idHrar) {
        return nil;
    }
    
    if (![idHrar isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanHotelRoomAvailabilityResponse *hrar = [[EanHotelRoomAvailabilityResponse alloc] init];
    hrar.size = [[idHrar objectForKey:@"@size"] integerValue];
    hrar.customerSessionId = [idHrar objectForKey:@"customerSessionId"];
    hrar.hotelId = [idHrar objectForKey:@"hotelId"];
    hrar.arrivalDateString = [idHrar objectForKey:@"arrivalDate"];
    hrar.departureDateString = [idHrar objectForKey:@"departureDate"];
    hrar.arrivalDate = [kEanApiDateFormatter() dateFromString:hrar.arrivalDateString];
    hrar.departureDate = [kEanApiDateFormatter() dateFromString:hrar.departureDateString];
    hrar.hotelName = [idHrar objectForKey:@"hotelName"];
    hrar.hotelAddress = [idHrar objectForKey:@"hotelAddress"];
    hrar.hotelCity = [idHrar objectForKey:@"hotelCity"];
    hrar.hotelStateProvince = [idHrar objectForKey:@"hotelStateProvince"];
    hrar.hotelCountry = [idHrar objectForKey:@"hotelCountry"];
    hrar.numberOfRoomsRequested = [[idHrar objectForKey:@"numberOfRoomsRequested"] integerValue];
    hrar.checkInInstructions = [idHrar objectForKey:@"checkInInstructions"];
    hrar.tripAdvisorRating = [idHrar objectForKey:@"tripAdvisorRating"];
    hrar.tripAdvisorReviewCount = [[idHrar objectForKey:@"tripAdvisorReviewCount"] integerValue];
    hrar.tripAdvisorRatingUrl = [idHrar objectForKey:@"tripAdvisorRatingUrl"];
    
    id hrr = [idHrar objectForKey:@"HotelRoomResponse"];
    
    if (nil == hrr) {
        hrar.hotelRoomArray = nil;
    } else if ([hrr isKindOfClass:[NSArray class]]) {
        NSMutableArray *tmpRooms = [NSMutableArray array];
        for (int j = 0; j < [hrr count]; j++) {
            EanAvailabilityHotelRoomResponse *room = [EanAvailabilityHotelRoomResponse roomFromDict:hrr[j]];
            [tmpRooms addObject:room];
        }
        
        hrar.hotelRoomArray = [NSArray arrayWithArray:tmpRooms];
        
    } else if ([hrr isKindOfClass:[NSDictionary class]]) {
        // Believe it or not, Ean API will not return an array if there
        // is a single room response. Instead they just return a dict
        // of the room. Nice.
        hrar.hotelRoomArray = [NSArray arrayWithObject:[EanAvailabilityHotelRoomResponse roomFromDict:hrr]];
        
    } else {
        hrar.hotelRoomArray = nil;
    }
    
    for (EanAvailabilityHotelRoomResponse *room in hrar.hotelRoomArray) {
        EanRateInfo *ri = room.rateInfo;
        
        if (ri.nonRefundable) {
            ri.nonRefundableLongString = kNonrefundableString;
        } else if ([ri.cancelPolicyInfoArray count] == 2) {
            
            NSInteger startWindowHours = ((EanCancelPolicyInfo *)ri.cancelPolicyInfoArray[1]).startWindowHours;
            int daysInAdvance = (int) startWindowHours / 24;
            NSDate *lastDayToCancel = kAddDays(-daysInAdvance, hrar.arrivalDate);
            
            NSString *strLastDayToCancel = [kShortDateFormatter() stringFromDate:lastDayToCancel];
            
            NSDateFormatter *tf = [[NSDateFormatter alloc] init];
            [tf setDateFormat:@"HH:mm:ss"];
            NSDate *ct = [tf dateFromString:((EanCancelPolicyInfo *)ri.cancelPolicyInfoArray[0]).cancelTime];
            [tf setDateFormat:nil];
            [tf setLocale:[NSLocale currentLocale]];
            [tf setDateStyle:NSDateFormatterNoStyle];
            [tf setTimeStyle:NSDateFormatterShortStyle];
            NSString *cts = [tf stringFromDate:ct];
            
            NSString *s = [NSString stringWithFormat:@"%@ %@ %@", kFreeCancelString, strLastDayToCancel, cts];
            
            ri.nonRefundableLongString = s;
            
        } else {
            ri.nonRefundableLongString = kNonrefundableString;
        }
        
        int j = 0;
        for (EanNightlyRate *nr in ri.chargeableRateInfo.nightlyRatesArray) {
            nr.daDate = kAddDays(j++, hrar.arrivalDate);
        }
    }
    
    return hrar;
}

@end
