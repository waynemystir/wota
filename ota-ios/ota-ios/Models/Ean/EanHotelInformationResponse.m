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
    
    if (![NSJSONSerialization isValidJSONObject:respDict]) {
        NSLog(@"%@.%@ Response is not valid JSON", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
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
    
    hi.hotelSummary = [EanHotelInformationSummary hotelSummaryFromDictionary:[hir objectForKey:@"HotelSummary"]];
    
    hi.hotelDetails = [EanHotelDetails hotelDetailsFromDictionary:[hir objectForKey:@"HotelDetails"]];
    
    hi.suppliers = [hir objectForKey:@"Suppliers"];
    
    [self unwrapEanObject:[hir objectForKey:@"RoomTypes"] withDict:&hi->_roomTypesDict withSize:&hi->_numberOfRoomTypes sizeKey:@"@size" withArray:&hi->_roomTypesArray arrayKey:@"RoomType"];
    
    [self unwrapEanObject:[hir objectForKey:@"PropertyAmenities"] withDict:&hi->_propertyAmenitiesDict withSize:&hi->_numberOfPropertyAmenities sizeKey:@"@size" withArray:&hi->_propertyAmenitiesArray arrayKey:@"PropertyAmenity"];
    
    [self unwrapEanObject:[hir objectForKey:@"HotelImages"] withDict:&hi->_hotelImagesDict withSize:&hi->_numberOfHotelImages sizeKey:@"@size" withArray:&hi->_hotelImagesArray arrayKey:@"HotelImage"];
    
    return hi;
}

+ (void)unwrapEanObject:(id)object
               withDict:(NSDictionary * __strong *)dict
               withSize:(NSUInteger *)size
                sizeKey:(NSString *) sizeKey
              withArray:(NSArray * __strong *) array
               arrayKey:(NSString *) arrayKey {
    if (object != nil && [object isKindOfClass:[NSDictionary class]]) {
        *dict = object;
        *size = [[*dict objectForKey:sizeKey] integerValue];
        id tmpArray = [*dict objectForKey:arrayKey];
        if (tmpArray != nil && [tmpArray isKindOfClass:[NSArray class]]) {
            *array = tmpArray;
        }
    }
}

@end
