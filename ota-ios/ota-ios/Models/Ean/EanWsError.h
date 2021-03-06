//
//  EanWsError.h
//  ota-ios
//
//  Created by WAYNE SMALL on 7/21/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EanWsError : NSObject

@property (nonatomic) NSInteger itineraryId;
@property (nonatomic, strong) NSString *eweHandling;
@property (nonatomic, strong) NSString *eweCategory;
@property (nonatomic) NSUInteger exceptionConditionId;
@property (nonatomic, strong) NSString *presentationMessage;
@property (nonatomic, strong) NSString *verboseMessage;
@property (nonatomic, strong) NSDictionary *ServerInfo;

+ (EanWsError *)eanErrorFromApiJsonResponse:(id)jsonResponse;

@end
