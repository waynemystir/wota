//
//  WotaCardPatternInfo.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/20/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WotaCardPatternInfo : NSObject

/**
 * The card company name. (e.g., Visa, Master, ...)
 */
@property (nonatomic, strong, readonly) NSString      *companyName;

/**
 * Short card company name. (e.g., visa, master, ...)
 */
@property (nonatomic, strong, readonly) NSString      *shortName;

/**
 * Expedia Affiliation Network Card Type. (e.g., VI, CA, ...)
 * Refer to http://developer.ean.com/general-info/valid-card-types#validation
 */
@property (nonatomic, strong, readonly) NSString      *eanType;

/**
 * Shorter version of card company name to present
 */
@property (nonatomic, strong, readonly) NSString      *presentName;

/**
 *
 */
@property (nonatomic, readonly) NSInteger numberOfGroups;

/**
 * Initialize card pattern info with dictionary object in CardPatterns.plist
 */
- (instancetype)initWithDictionary:(NSDictionary *)aDictionary;

/**
 * Check whether number string matches credit card number pattern.
 */
- (BOOL)patternMatchesWithNumberString:(NSString *)aNumberString;

/**
 * Returns formatted card number string. (e.g., 1234 1234 1234 1234)
 */
- (NSString *)groupedStringWithString:(NSString *)aString
                       groupSeparater:(NSString *)aGroupSeparater
                     maskingCharacter:(NSString *)aMaskingCharacter
                 maskingGroupIndexSet:(NSIndexSet *)aMaskingGroupIndexSet;

@end
