//
//  IpAddress.m
//  ota-ios
//
//  Created by WAYNE SMALL on 9/30/15.
//  Copyright © 2015 Trotter Travel LLC. All rights reserved.
//

#import "IpAddress.h"
#include <sys/types.h>
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <netdb.h>
#include <stdbool.h>
#include <arpa/inet.h>

@implementation IpAddress

BOOL isValidIPv4_alt1(NSString *ipAdd) {
    
    if (!ipAdd || [[ipAdd  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
        return NO;
    
    // Curtesy of http://stackoverflow.com/questions/3736335/tell-whether-a-text-string-is-an-ipv6-address-or-ipv4-address-using-standard-c-s
    
    BOOL retBool = NO;
    struct addrinfo hint, *res = NULL;
    int ret;
    
    memset(&hint, '\0', sizeof hint);
    
    hint.ai_family = PF_UNSPEC;
    hint.ai_flags = AI_NUMERICHOST;
    
    ret = getaddrinfo([ipAdd UTF8String], NULL, &hint, &res);
    if (ret) {
//        NSLog(@"%s %s", gai_strerror(ret), [ipAdd UTF8String] ? : [@"" UTF8String]);
        retBool = NO;
    } else if(res->ai_family == AF_INET) {
        retBool = YES;
    } else if (res->ai_family == AF_INET6) {
//        NSLog(@"IPv6 address:%s", [ipAdd UTF8String] ? : [@"" UTF8String]);
        retBool = NO;
    } else {
        retBool = NO;
    }
    
    freeaddrinfo(res);
    return retBool;
}

BOOL isValidIPv4_alt2(NSString *ipAdd) {
    const char *utf8 = [ipAdd UTF8String];
    int success;
    
    struct in_addr dst;
    success = inet_pton(AF_INET, utf8, &dst);
    
    return success == 1;
}

BOOL isValidIPv4_alt3(NSString *ipAdd) {
    NSString *pattern = @"^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:ipAdd options:0 range:NSMakeRange(0, [ipAdd length])];
    return match != nil;
}

BOOL isValidIPAddress(NSString *ipAdd) {
    const char *utf8 = [ipAdd UTF8String];
    int success;
    
    struct in_addr dst;
    success = inet_pton(AF_INET, utf8, &dst);
    if (success != 1) {
        struct in6_addr dst6;
        success = inet_pton(AF_INET6, utf8, &dst6);
    }
    
    return success == 1;
}

@end
