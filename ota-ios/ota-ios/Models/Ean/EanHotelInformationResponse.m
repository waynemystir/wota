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
    
    id rtDict = [hir objectForKey:@"RoomTypes"];
    if (rtDict != nil && [rtDict isKindOfClass:[NSDictionary class]]) {
        hi.roomTypesDict = rtDict;
        hi.numberOfRoomTypes = [[hi.roomTypesDict objectForKey:@"@size"] integerValue];
        id rtArray = [hi.roomTypesDict objectForKey:@"RoomType"];
        if (rtArray != nil && [rtArray isKindOfClass:[NSArray class]]) {
            hi.roomTypesArray = rtArray;
        }
    }
    
    id amenitiesDict = [hir objectForKey:@"PropertyAmenities"];
    if (amenitiesDict != nil && [amenitiesDict isKindOfClass:[NSDictionary class]]) {
        hi.propertyAmenitiesDict = amenitiesDict;
        hi.numberOfPropertyAmenities = [[hi.propertyAmenitiesDict objectForKey:@"@size"] integerValue];
        id amenitiesArray = [hi.propertyAmenitiesDict objectForKey:@"PropertyAmenity"];
        if (amenitiesArray != nil && [amenitiesArray isKindOfClass:[NSArray class]]) {
            hi.propertyAmenitiesArray = amenitiesArray;
        }
    }
    
//    id imagesDict = [hir objectForKey:@"HotelImages"];
//    if (imagesDict != nil && [imagesDict isKindOfClass:[NSDictionary class]]) {
//        hi.hotelImagesDict = imagesDict;
//        hi.numberOfHotelImages = [[hi.hotelImagesDict objectForKey:@"@size"] integerValue];
//        id imagesArray = [hi.hotelImagesDict objectForKey:@"HotelImage"];
//        if (imagesArray != nil && [imagesArray isKindOfClass:[NSArray class]]) {
//            hi.hotelImagesArray = imagesArray;
//        }
//    }
    
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
