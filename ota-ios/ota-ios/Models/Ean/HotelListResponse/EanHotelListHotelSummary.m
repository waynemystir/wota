//
//  EanHotelListHotelSummary.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/5/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "EanHotelListHotelSummary.h"
#import "NSString+HTML.h"
#import "AppEnvironment.h"

@implementation EanHotelListHotelSummary

+ (EanHotelListHotelSummary *)hotelFromDict:(NSDictionary *)dict {
    if (dict == nil) {
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanHotelListHotelSummary *hotel = [[EanHotelListHotelSummary alloc] init];
    
    //*******************
    // TODO: handle cases where the following values are not empty or wrong data type
    //*******************
    hotel.featuredOrder = [[dict objectForKey:@"@order"] integerValue];
    hotel.hotelId = [dict objectForKey:@"hotelId"];
    hotel.hotelName = [dict objectForKey:@"name"];
    hotel.address1 = [dict objectForKey:@"address1"];
    hotel.address2 = [dict objectForKey:@"address2"];
    hotel.city = [dict objectForKey:@"city"];
    hotel.stateProvinceCode = [dict objectForKey:@"stateProvinceCode"];
    hotel.postalCode = [dict objectForKey:@"postalCode"];
    hotel.countryCode = [dict objectForKey:@"countryCode"];
    hotel.airportCode = [dict objectForKey:@"airportCode"];
    hotel.supplierType = [dict objectForKey:@"supplierType"];
    hotel.propertyCategory = [dict objectForKey:@"propertyCategory"];
    hotel.hotelRating = [dict objectForKey:@"hotelRating"];
    hotel.confidenceRating = [dict objectForKey:@"confidenceRating"];
    hotel.amenityMask = [dict objectForKey:@"amenityMask"];
    hotel.tripAdvisorRating = [dict objectForKey:@"tripAdvisorRating"];
    hotel.tripAdvisorReviewCount = [dict objectForKey:@"tripAdvisorReviewCount"];
    hotel.tripAdvisorRatingUrl = [dict objectForKey:@"tripAdvisorRatingUrl"];
    hotel.locationDescription = [dict objectForKey:@"locationDescription"];
    hotel.shortDescription = [dict objectForKey:@"shortDescription"];
    hotel.highRate = [dict objectForKey:@"highRate"];
    hotel.lowRate = [dict objectForKey:@"lowRate"];
    hotel.rateCurrencyCode = [dict objectForKey:@"rateCurrencyCode"];
    hotel.latitude = [[dict objectForKey:@"latitude"] doubleValue];
    hotel.longitude = [[dict objectForKey:@"longitude"] doubleValue];
    hotel.proximityDistance = [[dict objectForKey:@"proximityDistance"] doubleValue];
    hotel.proximityUnit = [dict objectForKey:@"proximityUnit"];
    hotel.hotelInDestination = [[dict objectForKey:@"hotelInDestination"] boolValue];
    hotel.thumbNailUrl = [dict objectForKey:@"thumbNailUrl"];
    hotel.thumbNailUrlEnhanced = [hotel.thumbNailUrl stringByReplacingOccurrencesOfString:@"_t" withString:@"_b"];
    hotel.thumbNailUrlLooksOK = !stringIsEmpty(hotel.thumbNailUrlEnhanced);
    hotel.thumbNailUrlEnhancedURL = [NSURL URLWithString:[@"http://images.travelnow.com" stringByAppendingString:hotel.thumbNailUrlEnhanced]];
    hotel.deepLink = [dict objectForKey:@"deepLink"];
    hotel.roomRateDetailsList = [dict objectForKey:@"RoomRateDetailsList"];
    
    id idRoomRateDetails = [hotel.roomRateDetailsList objectForKey:@"RoomRateDetails"];
    if ([idRoomRateDetails isKindOfClass:[NSDictionary class]]) {
        hotel.roomRateDetails = [EanRoomRateDetails roomRateDetailsFromDict:idRoomRateDetails];
        hotel.roomRateDetailsArray = [NSArray arrayWithObject:hotel.roomRateDetails];
    } else if ([idRoomRateDetails isKindOfClass:[NSArray class]]) {
        NSMutableArray *tmpRrdArray = [NSMutableArray array];
        for (int j = 0; j < [idRoomRateDetails count]; j++) {
            if ([idRoomRateDetails[j] isKindOfClass:[NSDictionary class]]) {
                EanRoomRateDetails *rrd = [EanRoomRateDetails roomRateDetailsFromDict:idRoomRateDetails[j]];
                [tmpRrdArray addObject:rrd];
            }
        }
        hotel.roomRateDetailsArray = [NSArray arrayWithArray:tmpRrdArray];
    }
    
    return hotel;
}

- (NSString *)hotelNameFormatted {
    return [_hotelName stringByConvertingHTMLToPlainText];
}

- (NSString *)address1Formatted {
    return [_address1 stringByConvertingHTMLToPlainText];
}

@end
