//
//  LoadDataProtocol.h
//  ean-ota-ios
//
//  Created by WAYNE SMALL on 3/20/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LoadDataProtocol <NSObject>

@required

- (void)requestFinished:(NSData *)responseData;

@optional

- (void)requestStarted:(NSURL *)url;

@end
