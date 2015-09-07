//
//  EanHotelRoomReservationResponse.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/7/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "EanHotelRoomReservationResponse.h"
#import "AppEnvironment.h"

@implementation EanHotelRoomReservationResponse

+ (instancetype)eanObjectFromApiJsonResponse:(id)jsonResponse {
    if (nil == jsonResponse) {
        return nil;
    }
    
    if (![jsonResponse isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    id idHrrr = [jsonResponse objectForKey:@"HotelRoomReservationResponse"];
    
    if (nil == idHrrr) {
        return nil;
    }
    
    if (![idHrrr isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanHotelRoomReservationResponse *hrrr = [[EanHotelRoomReservationResponse alloc] init];
    
    hrrr.eanWsError = [self checkForEanError:idHrrr];
    if (hrrr.eanWsError) return hrrr;
    
    hrrr.customerSessionId = [idHrrr objectForKey:@"customerSessionId"];
    hrrr.itineraryId = [[idHrrr objectForKey:@"itineraryId"] longValue];
    hrrr.processedWithConfirmation = [[idHrrr objectForKey:@"processedWithConfirmation"] boolValue];
    
    id idConfirmNumbs = [idHrrr objectForKey:@"confirmationNumbers"];
    
    if (!idConfirmNumbs) {
        hrrr.confirmationNumbers = @[];
    } else if ([idConfirmNumbs isKindOfClass:[NSNumber class]]) {
        hrrr.confirmationNumbers = @[ idConfirmNumbs ];
    } else if ([idConfirmNumbs isKindOfClass:[NSArray class]] && [idConfirmNumbs count] > 0) {
        // This shouldn't happen because I am not yet allowing users to
        // book more than one room at a time. But I will add something
        // simple for the time being.
        NSMutableArray *ma = [@[] mutableCopy];
        for (int j = 0; j < [idConfirmNumbs count]; j++) {
            id o = idConfirmNumbs[j];
            if (o)  [ma addObject:o];
        }
        hrrr.confirmationNumbers = [NSArray arrayWithArray:ma];
    } else {
        hrrr.confirmationNumbers = @[];
    }
    
    hrrr.rateInfo = [idHrrr objectForKey:@"RateInfo"];
    hrrr.supplierType = [idHrrr objectForKey:@"supplierType"];
    hrrr.reservationStatusCode = [idHrrr objectForKey:@"reservationStatusCode"];
    hrrr.existingItinerary = [[idHrrr objectForKey:@"existingItinerary"] boolValue];
    hrrr.numberOfRoomsBooked = [[idHrrr objectForKey:@"numberOfRoomsBooked"] intValue];
    hrrr.roomGroup = [idHrrr objectForKey:@"RoomGroup"];
    hrrr.drivingDirections = [idHrrr objectForKey:@"drivingDirections"];
    hrrr.checkInInstructions = [idHrrr objectForKey:@"checkInInstructions"];
    hrrr.arrivalDate = [kEanApiDateFormatter() dateFromString:[idHrrr objectForKey:@"arrivalDate"]];
    hrrr.departureDate = [kEanApiDateFormatter() dateFromString:[idHrrr objectForKey:@"departureDate"]];
    hrrr.hotelName = [idHrrr objectForKey:@"hotelName"];
    hrrr.hotelAddress = [idHrrr objectForKey:@"hotelAddress"];
    hrrr.hotelCity = [idHrrr objectForKey:@"hotelCity"];
    hrrr.hotelPostalCode = [idHrrr objectForKey:@"hotelPostalCode"];
    hrrr.hotelCountryCode = [idHrrr objectForKey:@"hotelCountryCode"];
    hrrr.roomDescription = [idHrrr objectForKey:@"roomDescription"];
    hrrr.cancellationPolicy = [idHrrr objectForKey:@"cancellationPolicy"];
    hrrr.cancelPolicyInfoList = [idHrrr objectForKey:@"CancelPolicyInfoList"];
    hrrr.nonRefundable = [[idHrrr objectForKey:@"nonRefundable"] boolValue];
    hrrr.rateOccupancyPerRoom = [[idHrrr objectForKey:@"rateOccupancyPerRoom"] integerValue];
    
    return hrrr;
}

@end
