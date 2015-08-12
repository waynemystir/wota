//
//  EanAbstractResponse.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/26/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "EanAbstractResponse.h"
#import "AppEnvironment.h"

@implementation EanAbstractResponse

+ (instancetype)eanObjectFromApiResponseData:(NSData *)data {
    if (data == nil) {
        return nil;
    }
    
    NSError *error = nil;
    id respDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error != nil) {
        NSLog(@"%@.%@ ERROR trying to deserialize JSON data:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), error);
        return nil;
    }
    
    if (![NSJSONSerialization isValidJSONObject:respDict]) {
        NSLog(@"%@.%@ ERROR: Response is not valid JSON", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
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
    
    if (nil != idEwe && [idEwe isKindOfClass:[EanWsError class]]) {
        return idEwe;
    } else {
        return nil;
    }
}

@end
