//
//  EanHotelInformationResponse.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/26/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanHotelInformationResponse.h"

@implementation EanHotelInformationResponse

+ (EanHotelInformationResponse *)hotelInfoFromData:(NSData *)data {
    if (data == nil) {
        return nil;
    }
    
    NSError *error = nil;
    id respDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error != nil) {
        NSLog(@"ERROR:%@", error);
        return nil;
    }
    
    return [self hotelInfoFromObject:respDict];
}

+ (EanHotelInformationResponse *)hotelInfoFromObject:(id)object {
    if (object == nil) {
        return nil;
    }
    
    if (![object isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    id hir = [object objectForKey:@"HotelInformationResponse"];
    
    if (hir == nil) {
        return nil;
    }
    
    if (![hir isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanHotelInformationResponse *hi = [[EanHotelInformationResponse alloc] init];
    hi.hotelId = [hir objectForKey:@"@hotelId"];
    hi.customerSessionId = [hir objectForKey:@"customerSessionId"];
    hi.hotelSummary = [hir objectForKey:@"HotelSummary"];
    hi.hotelDetails = [hir objectForKey:@"HotelDetails"];
    hi.suppliers = [hir objectForKey:@"Suppliers"];
    hi.roomTypesDict = [hir objectForKey:@"RoomTypes"];
    hi.propertyAmenitiesDict = [hir objectForKey:@"PropertyAmenities"];
    hi.hotelImagesDict = [hir objectForKey:@"HotelImages"];
    return hi;
}

@end
