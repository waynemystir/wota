//
//  GoogleParser.h
//  ota-ios
//
//  Created by WAYNE SMALL on 3/24/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoogleParser : NSObject

+ (NSArray *)parseAutoCompleteResponse:(NSData *)responseData;

@end
