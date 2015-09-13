//
//  EanHotelItineraryResponse.m
//  ota-ios
//
//  Created by WAYNE SMALL on 9/12/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanHotelItineraryResponse.h"
#import "EanItinerary.h"

@implementation EanHotelItineraryResponse

+ (instancetype)eanObjectFromApiJsonResponse:(id)jsonResponse {
    if (nil == jsonResponse) {
        return nil;
    }
    
    if (![jsonResponse isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    id idHir = [jsonResponse objectForKey:@"HotelItineraryResponse"];
    
    if (nil == idHir) {
        return nil;
    }
    
    if (![idHir isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanHotelItineraryResponse *hir = [[EanHotelItineraryResponse alloc] init];
    hir.eanWsError = [self checkForEanError:idHir];
    if (hir.eanWsError) return hir;
    
    id idItinerary = [idHir objectForKey:@"Itinerary"];
    
    if (!idItinerary) {
        hir.itineraries = @[];
    } else if ([idItinerary isKindOfClass:[NSDictionary class]]) {
        hir.itineraries = @[ [EanItinerary itineraryFromDict:idItinerary] ];
    } else if ([idItinerary isKindOfClass:[NSArray class]]) {
        NSMutableArray *mutArr = [@[] mutableCopy];
        for (id obj in idItinerary) {
            if ([obj isKindOfClass:[NSDictionary class]])
                [mutArr addObject:[EanItinerary itineraryFromDict:obj]];
        }
        hir.itineraries = [NSArray arrayWithArray:mutArr];
    } else {
        hir.itineraries = @[];
    }
    
    return hir;
}

@end
