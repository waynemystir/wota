//
//  EanWsError.m
//  ota-ios
//
//  Created by WAYNE SMALL on 7/21/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "EanWsError.h"

@implementation EanWsError

+ (EanWsError *)eanErrorFromApiJsonResponse:(id)jsonResponse {
    if (nil == jsonResponse) {
        return nil;
    }
    
    if (![jsonResponse isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    id idEwe = [jsonResponse objectForKey:@"EanWsError"];
    
    if (nil == idEwe) {
        return nil;
    }
    
    if (![idEwe isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanWsError *ewe = [[EanWsError alloc] init];
    ewe.itineraryId = [[idEwe objectForKey:@"itineraryId"] longValue];
    ewe.eweHandling = [idEwe objectForKey:@"handling"];
    ewe.eweCategory = [idEwe objectForKey:@"category"];
    ewe.exceptionConditionId = [[idEwe objectForKey:@"exceptionConditionId"] integerValue];
    ewe.presentationMessage = [idEwe objectForKey:@"presentationMessage"];
    ewe.verboseMessage = [idEwe objectForKey:@"verboseMessage"];
    ewe.ServerInfo = [idEwe objectForKey:@"ServerInfo"];
    return ewe;
}

@end
