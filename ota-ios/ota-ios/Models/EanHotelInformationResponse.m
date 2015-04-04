//
//  EanHotelInfo.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/26/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanHotelInformationResponse.h"

@implementation EanHotelInformationResponse

+ (EanHotelInformationResponse *)hotelInfoFromObject:(NSObject *)object {
    if (object == nil) {
        return nil;
    }
    
    EanHotelInformationResponse *hotelInfo = [[EanHotelInformationResponse alloc] init];
    
    return hotelInfo;
}

@end
