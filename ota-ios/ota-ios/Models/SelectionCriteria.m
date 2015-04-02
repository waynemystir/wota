//
//  SelectionCriteria.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/28/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "SelectionCriteria.h"

@interface SelectionCriteria ()

@end

@implementation SelectionCriteria

+ (SelectionCriteria *)singleton {
    static SelectionCriteria *_selectionCriteria = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _selectionCriteria = [[SelectionCriteria alloc] init];
        _selectionCriteria.numberOfAdults = 2;
    });
    return _selectionCriteria;
}

- (NSString *)arrivalDateEanString {
    return [[SelectionCriteria EanApiDateFormatter] stringFromDate:_arrivalDate];
}

- (NSString *)returnDateEanString {
    return [[SelectionCriteria EanApiDateFormatter] stringFromDate:_returnDate];
}

+ (NSDateFormatter *)EanApiDateFormatter {
    static NSDateFormatter *_eanApiDateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _eanApiDateFormatter = [[NSDateFormatter alloc] init];
        [_eanApiDateFormatter setDateFormat:@"MM/dd/yyyy"];
    });
    return _eanApiDateFormatter;
}

- (NSUInteger)numberOfKids {
    if (self.childTravelers == nil || [self.childTravelers count] == 0) {
        return 0;
    }
    
    return [self.childTravelers count];
}

- (NSInteger)addChildTraveler:(ChildTraveler *)childTraveler {
    if (self.childTravelers == nil) {
        self.childTravelers = [NSMutableArray array];
    }
    
    if ([self.childTravelers count] >= 4) {
        return -1;
    }
    
    [self.childTravelers addObject:childTraveler];
    
    return [self.childTravelers count];
}

- (NSInteger)removeLastChildTraveler {
    if (self.childTravelers == nil || [self.childTravelers count] == 0) {
        return -1;
    }
    
    [self.childTravelers removeLastObject];
    return [self.childTravelers count] + 1;
}

- (BOOL)moreKidsOk {
    if ([self.childTravelers count] >= 4) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)lessKidsOk {
    if ([self.childTravelers count] <= 0) {
        return NO;
    } else {
        return YES;
    }
}

- (ChildTraveler *)retrieveChildTravelerByNumber:(NSUInteger)number {
    if (self.childTravelers == nil || [self.childTravelers count] == 0) {
        return nil;
    }
    
    if (number > [self.childTravelers count]) {
        return nil;
    }
    
    return self.childTravelers[number - 1];
}

- (NSDictionary *)childTravelersWithoutAges {
    if (self.childTravelers == nil || [self.childTravelers count] == 0) {
        return nil;
    }
    
    NSMutableDictionary *ctsMutable = [NSMutableDictionary dictionary];
    
    for (int j = 0; j < [self.childTravelers count]; j++) {
        ChildTraveler *ct = [self retrieveChildTravelerByNumber:(j + 1)];
        if (ct != nil && !ct.ageHasBeenSet) {
            [ctsMutable setObject:ct forKey:[NSNumber numberWithUnsignedInteger:(j + 1)]];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:ctsMutable];
}

@end
