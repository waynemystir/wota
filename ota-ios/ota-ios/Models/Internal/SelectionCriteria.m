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

//NSString * const kKeyWhereTo = @"whereTo";
NSString * const kKeyPlacesArray = @"kKeyPlacesArray";
NSString * const kKeySelectedPlace = @"kKeySelectedPlaces";
NSString * const kKeyGooglePlaceDetail = @"googlePlaceDetail";
NSString * const kKeyClPlacemark = @"kKeyClPlacemark";
NSString * const kKeyArrivalDate = @"arrivalDate";
NSString * const kKeyReturnDate = @"returnDate";
NSString * const kKeyNumberOfAdults = @"numberOfAdults";
NSString * const kKeyChildTravelers = @"childTravelers";

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
//    NSData* data = [[NSFileManager defaultManager] contentsAtPath:path];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        _selectionCriteria = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
//        _selectionCriteria = [NSKeyedUnarchiver unarchiveObjectWithData:data];
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
    
//    for (WotaPlace *obj in _placesArray){
//        if([obj.placeId isEqualToString: kWotaPlaceCurrentLocationId])
//            return obj;
//    }
//    
//    return nil;
}

- (void)save {
    NSString *path = [[self class] pathForSelectionCriteria];
    [NSKeyedArchiver archiveRootObject:self toFile:path];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
//        _whereTo = [aDecoder decodeObjectForKey:kKeyWhereTo];
        _placesArray = [aDecoder decodeObjectForKey:kKeyPlacesArray];
        _selectedPlace = [aDecoder decodeObjectForKey:kKeySelectedPlace];
//        _googlePlaceDetail = [aDecoder decodeObjectForKey:kKeyGooglePlaceDetail];
        _arrivalDate = [aDecoder decodeObjectForKey:kKeyArrivalDate];
        _returnDate = [aDecoder decodeObjectForKey:kKeyReturnDate];
        _numberOfAdults = [aDecoder decodeIntegerForKey:kKeyNumberOfAdults];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
//    [aCoder encodeObject:_whereTo forKey:kKeyWhereTo];
    [aCoder encodeObject:_placesArray forKey:kKeyPlacesArray];
    [aCoder encodeObject:_selectedPlace forKey:kKeySelectedPlace];
//    [aCoder encodeObject:_googlePlaceDetail forKey:kKeyGooglePlaceDetail];
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
    [self save];
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
