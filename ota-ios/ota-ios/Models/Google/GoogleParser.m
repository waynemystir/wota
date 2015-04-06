//
//  GoogleParser.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/24/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "GoogleParser.h"

@implementation GoogleParser

+ (NSArray *)parseAutoCompleteResponse:(NSData *)responseData {
    NSError *error = nil;
    id response = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
    
    if (error != nil) {
        NSLog(@"ERROR:%@", [error description]);
    } else {
//        NSLog(@"GOOGLE PLACES RESPONSE:%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
    }
    
    id predictions = [response objectForKey:@"predictions"];
    
    return predictions;
}

@end
