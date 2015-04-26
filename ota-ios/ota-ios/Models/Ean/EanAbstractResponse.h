//
//  EanAbstractResponse.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/26/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * This is an abstrast class and should never be instantiated
 */

@interface EanAbstractResponse : NSObject

+ (instancetype)eanObjectFromApiResponseData:(NSData *)data;
+ (instancetype)eanObjectFromApiJsonResponse:(id)jsonResponse;

@end
