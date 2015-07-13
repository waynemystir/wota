//
//  GoogleParser.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/24/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "GoogleParser.h"
#import "GooglePlace.h"

@implementation GoogleParser

+ (NSArray *)parseAutoCompleteResponse:(NSData *)responseData {
    NSError *error = nil;
    id response = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
    
    if (error != nil) {
        NSLog(@"ERROR:%@", [error description]);
        return nil;
    } else {
        NSLog(@"AUTOCOMPLETERESPONSE:%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
    }
    
    id predictions = [response objectForKey:@"predictions"];
    
    if (nil == predictions || ![predictions isKindOfClass:[NSArray class]] /*|| [predictions count] == 0*/) {
        return nil;
    }
    
    NSMutableArray *mutablePredictions = [NSMutableArray array];
    for (int j = 0; j < [predictions count]; j++) {
        GooglePlace *gp = [GooglePlace placeFromObject:predictions[j]];
        [mutablePredictions addObject:gp];
    }
    
    [mutablePredictions addObject:@"poweredByGoogle"];
    
    return [NSArray arrayWithArray:mutablePredictions];
}

@end
