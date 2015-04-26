//
//  EanHotelListResponse.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/5/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EanAbstractResponse.h"

@interface EanHotelListResponse : EanAbstractResponse

@property (nonatomic, strong) NSString *customerSessionId;
@property (nonatomic) NSUInteger numberOfRoomsRequested;
@property (nonatomic) BOOL moreResultsAvailable;
@property (nonatomic, strong) NSString *cacheKey;
@property (nonatomic, strong) NSString *cacheLocation;
@property (nonatomic, strong) NSDictionary *hotelListDict;
@property (nonatomic) NSUInteger size;
@property (nonatomic) NSUInteger activePropertyCount;
@property (nonatomic, strong) NSArray *hotelList;

@end
