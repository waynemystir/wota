//
//  SelectionCriteria.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/28/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "SelectionCriteria.h"
#import "AppEnvironment.h"

NSString * const kWotaPlaceCurrentLocationId = @"kWotaPlaceCurrentLocationId";

NSUInteger const kMaximumNumberOfSavedPlaces = 20;

NSString * const kKeyPlacesArray = @"kKeyPlacesArray";
NSString * const kKeySelectedPlace = @"kKeySelectedPlaces";
NSString * const kKeyArrivalDate = @"arrivalDate";
NSString * const kKeyReturnDate = @"returnDate";
NSString * const kKeyNumberOfAdults = @"numberOfAdults";

@implementation SelectionCriteria

+ (SelectionCriteria *)singleton {
    static SelectionCriteria *_selectionCriteria = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _selectionCriteria = [SelectionCriteria unarchiveSelectionCriteria];
    });
    
    return _selectionCriteria;
}

+ (SelectionCriteria *)unarchiveSelectionCriteria {
    SelectionCriteria *_selectionCriteria = nil;
    
    NSString* path = [self pathForSelectionCriteria];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        _selectionCriteria = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    }
    
    if (nil == _selectionCriteria) {
        _selectionCriteria = [[self alloc] init];
        _selectionCriteria.numberOfAdults = 2;
        WotaPlace *wp = [[WotaPlace alloc] init];
        wp.placeId = kWotaPlaceCurrentLocationId;
        wp.placeName = @"Current Location";
        wp.displayName = @"Current Location";
        _selectionCriteria.placesArray = [NSMutableArray arrayWithObject:wp];
        _selectionCriteria.selectedPlace = wp;
        [_selectionCriteria save];
    }
    
    return _selectionCriteria;
}

- (WotaPlace *)retrieveCurrentLocationPlace {
    return _placesArray.firstObject;
}

- (void)save {
    NSString *path = [[self class] pathForSelectionCriteria];
    [NSKeyedArchiver archiveRootObject:self toFile:path];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _placesArray = [aDecoder decodeObjectForKey:kKeyPlacesArray];
        _selectedPlace = [aDecoder decodeObjectForKey:kKeySelectedPlace];
        _arrivalDate = [aDecoder decodeObjectForKey:kKeyArrivalDate];
        _returnDate = [aDecoder decodeObjectForKey:kKeyReturnDate];
        _numberOfAdults = [aDecoder decodeIntegerForKey:kKeyNumberOfAdults];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_placesArray forKey:kKeyPlacesArray];
    [aCoder encodeObject:_selectedPlace forKey:kKeySelectedPlace];
    [aCoder encodeObject:_arrivalDate forKey:kKeyArrivalDate];
    [aCoder encodeObject:_returnDate forKey:kKeyReturnDate];
    [aCoder encodeInteger:_numberOfAdults forKey:kKeyNumberOfAdults];
}

+ (NSString *)pathForSelectionCriteria {
    return [kWotaCacheDirectory() stringByAppendingFormat:@"/%@", @"selection_criteria"];
}

#pragma mark Getters

- (NSString *)whereTo {
    return _googlePlaceDetail ? _googlePlaceDetail.formattedWhereTo : _selectedPlace.formattedWhereTo;
}

- (NSString *)whereToFirst {
    return _googlePlaceDetail ? _googlePlaceDetail.formattedWhereToFirst : _selectedPlace.formattedWhereToFirst;
}

- (NSString *)whereToSecond {
    return _googlePlaceDetail ? _googlePlaceDetail.formattedWhereToSecond : _selectedPlace.formattedWhereToSecond;
}

- (double)latitude {
    return _googlePlaceDetail ? _googlePlaceDetail.latitude : _selectedPlace.latitude;
}

- (double)longitude {
    return _googlePlaceDetail ? _googlePlaceDetail.longitude : _selectedPlace.longitude;
}

- (NSString *)arrivalDateEanString {
    return [kEanApiDateFormatter() stringFromDate:_arrivalDate];
}

- (NSString *)returnDateEanString {
    return [kEanApiDateFormatter() stringFromDate:_returnDate];
}

#pragma mark Setters

- (void)setSelectedPlace:(WotaPlace *)selectedPlace {
    _selectedPlace = selectedPlace;
    
    if ([self currentLocationIsSelectedPlace]) {
        return;
    }
    
    for (int j = 0; j < [_placesArray count]; j++) {
        WotaPlace *wp = [_placesArray objectAtIndex:j];
        if([wp.placeId isEqualToString: _selectedPlace.placeId]) {
            [_placesArray removeObjectAtIndex:j];
        }
    }
    
    [_placesArray insertObject:_selectedPlace atIndex:1];
    [self trimPlacesArray];
    [self save];
}

- (void)trimPlacesArray {
    if ([_placesArray count] <= kMaximumNumberOfSavedPlaces) {
        return;
    }
    
    for (NSUInteger j = [_placesArray count] - kMaximumNumberOfSavedPlaces; j > 0; j--) {
        [_placesArray removeObjectAtIndex:([_placesArray count] - 1)];
    }
}

- (void)setGooglePlaceDetail:(GooglePlaceDetail *)googlePlaceDetail {
    _googlePlaceDetail = googlePlaceDetail;
    [self save];
}

- (void)savePlace:(GooglePlaceDetail *)googlePlaceDetail {
    _googlePlaceDetail = googlePlaceDetail;
    WotaPlace *wp = [[WotaPlace alloc] init];
    wp.placeId = googlePlaceDetail.placeId;
    wp.placeName = googlePlaceDetail.placeName ? : googlePlaceDetail.formattedWhereToFirst;
    wp.displayName = googlePlaceDetail.formattedWhereTo;
    wp.latitude = googlePlaceDetail.latitude;
    wp.longitude = googlePlaceDetail.longitude;
    wp.placeDetailLevel = googlePlaceDetail.placeDetailLevel;
    self.selectedPlace = wp;
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

#pragma mark Helper methods

- (BOOL)currentLocationIsSelectedPlace {
    return [_selectedPlace.placeId isEqualToString:kWotaPlaceCurrentLocationId];
}

@end
