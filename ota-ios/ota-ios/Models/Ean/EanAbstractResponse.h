//
//  EanAbstractResponse.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/26/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EanWsError.h"

/**
 * See the word 'Abstract' in the class name? It's
 * not there just so I can sound cool, although I have
 * to admit it does make me sound rather choice.
 */
@interface EanAbstractResponse : NSObject

+ (instancetype)eanObjectFromApiResponseData:(NSData *)data;
+ (instancetype)eanObjectFromApiJsonResponse:(id)jsonResponse;
+ (EanWsError *)checkForEanError:(id)jsonResponse;

@end
