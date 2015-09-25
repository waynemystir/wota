//
//  ChildTraveler.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/29/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "ChildTraveler.h"
#import "AppEnvironment.h"

static NSArray *_cts = nil;

NSString * const kKeyChildTravelerId = @"childTravelerId";
NSString * const kKeyAgeHasBeenSet = @"ageHasBeenSet";
NSString * const kKeyIsLessThanOne = @"isLessThanOne";
NSString * const kKeyChildAge = @"childAge";

@implementation ChildTraveler

@synthesize childAge = _childAge;

+ (ChildTraveler *)childTravelerForId:(CHILD_TRAVELER_ID)childTravelerId {
    ChildTraveler *_ct = nil;
    NSString *path = [self pathToChildTravelerId:childTravelerId];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        _ct = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    }
    
    return _ct;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _childTravelerId = [aDecoder decodeIntegerForKey:kKeyChildTravelerId];
        _ageHasBeenSet = [aDecoder decodeBoolForKey:kKeyAgeHasBeenSet];
        _isLessThanOne = [aDecoder decodeBoolForKey:kKeyIsLessThanOne];
        _childAge = [aDecoder decodeIntegerForKey:kKeyChildAge];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:_childTravelerId forKey:kKeyChildTravelerId];
    [aCoder encodeBool:_ageHasBeenSet forKey:kKeyAgeHasBeenSet];
    [aCoder encodeBool:_isLessThanOne forKey:kKeyIsLessThanOne];
    [aCoder encodeInteger:_childAge forKey:kKeyChildAge];
}

+ (NSString *)pathToChildTravelerId:(CHILD_TRAVELER_ID)childTravelerId {
    return [kWotaCacheChildTravelersDirectory() stringByAppendingFormat:@"/%lu", (unsigned long) childTravelerId];
}

- (BOOL)save {
    BOOL saveResult = [NSKeyedArchiver archiveRootObject:self toFile:[[self class] pathToChildTravelerId:_childTravelerId]];
    [ChildTraveler updateChildTravelers];
    return saveResult;
}

+ (NSArray *)childTravelers {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self updateChildTravelers];
    });
    return _cts;
}

+ (void)updateChildTravelers {
    NSMutableArray* cachedRecords = [NSMutableArray array];
    NSArray* idsArray = [self allIds];
    for (NSString* identifier in idsArray) {
        NSUInteger theId = [identifier integerValue];
        // TODO: Maybe I should do some check here that the object is,
        // you know, actually a ChildTraveler... before adding it to
        // the array
        ChildTraveler *childTraveler = [self childTravelerForId:theId];
        [cachedRecords addObject:childTraveler];
    }
    
    NSArray *sortedRecords = [cachedRecords sortedArrayUsingComparator: ^(id obj1, id obj2) {
        ChildTraveler *ct1 = obj1;
        ChildTraveler *ct2 = obj2;
        NSUInteger ct1id = ct1.childTravelerId;
        NSUInteger ct2id = ct2.childTravelerId;
        
        if (ct1id > ct2id) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if (ct1id < ct2id) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    if (sortedRecords == nil) {
        _cts = [NSArray array];
    } else {
        _cts = sortedRecords;
    }
}

+ (NSArray *)allIds {
    NSString* path = kWotaCacheChildTravelersDirectory();
    NSError *error = nil;
    NSArray* dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    if (error != nil) {
        TrotterLog(@"ERROR:%@", error);
    }
    return dirContents;
}

#pragma mark Various helper methods

+ (int)numberOfKids {
    // I think we can probably just return [[self childTravelers] count]
    // without these nil and zero checks... because "count" on a nil or
    // empty array should just return zero... or so I've heard. But what
    // the hell. A little extra checking couldn't hurt, right?
    if ([self childTravelers] == nil || [[self childTravelers] count] == 0) {
        return 0;
    }
    
    return (int)[[self childTravelers] count];
}

+ (NSInteger)addChildTraveler {
    if ([[self childTravelers] count] >= 4) {
        return -1;
    }
    
    // Notice that we don't care if childTravelers is nil
    // Because count will return zero
    // And the save call will then call updateChildTravelers
    
    NSUInteger numKids = [[self childTravelers] count];
    ChildTraveler *childTraveler = [ChildTraveler new];
    childTraveler.childTravelerId = numKids + 1;
    [childTraveler save];
    
    return (numKids + 1);
}

+ (NSInteger)removeLastChildTraveler {
    if ([self childTravelers] == nil || [[self childTravelers] count] == 0) {
        return -1;
    }
    
    NSUInteger lastChildNumber = [[self childTravelers] count];
    ChildTraveler *ct = [self childTravelerForId:lastChildNumber];
    [ct delete];
    return [[self childTravelers] count] + 1;
}

- (void)delete {
    NSString* path = [[self class] pathToChildTravelerId:_childTravelerId];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    
    [[self class] updateChildTravelers];
}

+ (void)removeAllChildTravelers {
    while ([self removeLastChildTraveler] > 0);
}

+ (BOOL)moreKidsOk {
    if ([[self childTravelers] count] >= 4) {
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)lessKidsOk {
    if ([[self childTravelers] count] <= 0) {
        return NO;
    } else {
        return YES;
    }
}

+ (NSDictionary *)childTravelersWithoutAges {
    if ([self childTravelers] == nil || [[self childTravelers] count] == 0) {
        return nil;
    }
    
    NSMutableDictionary *ctsMutable = [NSMutableDictionary dictionary];
    
    for (int j = 0; j < [[self childTravelers] count]; j++) {
        ChildTraveler *ct = [self childTravelerForId:(j + 1)];
        if (ct != nil && !ct.ageHasBeenSet) {
            [ctsMutable setObject:ct forKey:[NSNumber numberWithUnsignedInteger:(j + 1)]];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:ctsMutable];
}

#pragma mark Getters and Setters

- (NSUInteger)getChildsAge {
    if (self.isLessThanOne) {
        return 0;
    }
    
    return _childAge;
}

- (void)setChildsAge:(NSUInteger)childAge {
    _ageHasBeenSet = YES;
    _childAge = childAge;
    [self save];
}

- (void)setChildTravlerId:(CHILD_TRAVELER_ID)childTravelerId {
    _childTravelerId = childTravelerId;
    [self save];
}

- (void)setAgeHasBeenSet:(BOOL)ageHasBeenSet {
    _ageHasBeenSet = ageHasBeenSet;
    [self save];
}

- (void)setIsLessThanOne:(BOOL)isLessThanOne {
    _isLessThanOne = isLessThanOne;
    [self save];
}

@end
