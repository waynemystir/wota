//
//  EanHotelParser.h
//  ean-ota-ios
//
//  Created by WAYNE SMALL on 3/21/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EanParser : NSObject

+ (NSArray *)parseHotelListResponse:(NSData *)responseData;

@end
