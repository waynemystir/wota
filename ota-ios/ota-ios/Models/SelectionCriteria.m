//
//  SelectionCriteria.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/28/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "SelectionCriteria.h"
#import "AppEnvironment.h"

NSString * const kKeyWhereTo = @"whereTo";
NSString * const kKeyGooglePlaceDetail = @"googlePlaceDetail";
NSString * const kKeyArrivalDate = @"arrivalDate";
NSString * const kKeyReturnDate = @"returnDate";
NSString * const kKeyNumberOfAdults = @"numberOfAdults";
NSString * const kKeyChildTravelers = @"childTravelers";

@interface SelectionCriteria ()

@end

@implementation SelectionCriteria

+ (SelectionCriteria *)singleton {
    static SelectionCriteria *_selectionCriteria = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _selectionCriteria = [SelectionCriteria retrieveSelectionCriteria];
    });
    
    return _selectionCriteria;
}

+ (SelectionCriteria *)retrieveSelectionCriteria {
    SelectionCriteria *_selectionCriteria = nil;
    
    NSString* path = [self pathForSelectionCriteria];
//    NSData* data = [[NSFileManager defaultManager] contentsAtPath:path];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        _selectionCriteria = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
//        _selectionCriteria = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    if (nil == _selectionCriteria) {
        _selectionCriteria = [[self alloc] init];
        _selectionCriteria.numberOfAdults = 2;
    }
    
    return _selectionCriteria;
}

- (void)save {
    NSString *path = [[self class] pathForSelectionCriteria];
    [NSKeyedArchiver archiveRootObject:self toFile:path];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _whereTo = [aDecoder decodeObjectForKey:kKeyWhereTo];
//        _googlePlaceDetail = [aDecoder decodeObjectForKey:kKeyGooglePlaceDetail];
        _arrivalDate = [aDecoder decodeObjectForKey:kKeyArrivalDate];
        _returnDate = [aDecoder decodeObjectForKey:kKeyReturnDate];
        _numberOfAdults = [aDecoder decodeIntegerForKey:kKeyNumberOfAdults];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_whereTo forKey:kKeyWhereTo];
//    [aCoder encodeObject:_googlePlaceDetail forKey:kKeyGooglePlaceDetail];
    [aCoder encodeObject:_arrivalDate forKey:kKeyArrivalDate];
    [aCoder encodeObject:_returnDate forKey:kKeyReturnDate];
    [aCoder encodeInteger:_numberOfAdults forKey:kKeyNumberOfAdults];
}

+ (NSString *)pathForSelectionCriteria {
    return [kWotaCacheDirectory() stringByAppendingFormat:@"/%@", @"selection_criteria"];
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

#pragma mark Setters

- (void)setWhereTo:(NSString *)whereTo {
    _whereTo = whereTo;
    [self save];
}

- (void)setGooglePlaceDetail:(GooglePlaceDetail *)googlePlaceDetail {
    _googlePlaceDetail = googlePlaceDetail;
    [self save];
}

- (void)setArrivalDate:(NSDate *)arrivalDate {
    _arrivalDate = arrivalDate;
    [self save];
}

- (void)setReturnDate:(NSDate *)returnDate {
    _returnDate = returnDate;
    [self save];
}

- (void)setNumberOfAdults:(NSUInteger)numberOfAdults {
    _numberOfAdults = numberOfAdults;
    [self save];
}

@end
