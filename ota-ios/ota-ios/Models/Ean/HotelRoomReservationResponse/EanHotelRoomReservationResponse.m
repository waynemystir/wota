//
//  EanHotelRoomReservationResponse.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/7/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
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
    
    hrrr.customerSessionId = [idHrrr objectForKey:@"customerSessionId"];
    hrrr.itineraryId = [[idHrrr objectForKey:@"itineraryId"] longValue];
    hrrr.confirmationNumbers = [idHrrr objectForKey:@"confirmationNumbers"];
    hrrr.rateInfo = [idHrrr objectForKey:@"RateInfo"];
    hrrr.processedWithConfirmation = [[idHrrr objectForKey:@"processedWithConfirmation"] boolValue];
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
