//
//  EanAbstractResponse.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/26/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "EanAbstractResponse.h"
#import "AppEnvironment.h"
#import "Analytics.h"

@implementation EanAbstractResponse

+ (instancetype)eanObjectFromApiResponseData:(NSData *)data {
    if (data == nil) {
        return nil;
    }
    
    NSError *error = nil;
    id respDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error != nil) {
        TrotterLog(@"%s ERROR trying to deserialize JSON data:%@", __PRETTY_FUNCTION__, error);
        return nil;
    }
    
    if (![NSJSONSerialization isValidJSONObject:respDict]) {
        TrotterLog(@"%s ERROR: Response is not valid JSON", __PRETTY_FUNCTION__);
        return nil;
    }
    
    NSString *respString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    TrotterLog(@"%@ JSON Response String:%@", NSStringFromClass(self.class), respString);
    return [self eanObjectFromApiJsonResponse:respDict];
}

+ (instancetype)eanObjectFromApiJsonResponse:(id)jsonResponse {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (EanWsError *)checkForEanError:(id)jsonResponse {
    id idEwe = [EanWsError eanErrorFromApiJsonResponse:jsonResponse];
    
    if (idEwe && [idEwe isKindOfClass:[EanWsError class]]) {
        EanWsError *ee = idEwe;
        [Analytics postEanErrorWithItineraryId:ee.itineraryId handling:ee.eweHandling category:ee.eweCategory presentationMessage:ee.presentationMessage verboseMessage:ee.verboseMessage];
        return ee;
    } else {
        return nil;
    }
}

@end
