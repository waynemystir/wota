//
//  EanHotelDetails.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/4/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "EanHotelDetails.h"
#import "AppEnvironment.h"

@implementation EanHotelDetails

+ (EanHotelDetails *)hotelDetailsFromDictionary:(NSDictionary *)dict {
    if (dict == nil) {
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanHotelDetails *hd = [[EanHotelDetails alloc] init];
    
    hd.numberOfRooms = [[dict objectForKey:@"numberOfRooms"] integerValue];
    hd.numberOfFloors = [[dict objectForKey:@"numberOfFloors"] integerValue];
    hd.checkInTime = [dict objectForKey:@"checkInTime"];
    hd.checkOutTime = [dict objectForKey:@"checkOutTime"];
    hd.propertyInformation = [dict objectForKey:@"propertyInformation"];
    hd.areaInformation = [dict objectForKey:@"areaInformation"];
    hd.propertyDescription = [dict objectForKey:@"propertyDescription"];
    hd.hotelPolicy = [dict objectForKey:@"hotelPolicy"];
    hd.roomInformation = [dict objectForKey:@"roomInformation"];
    hd.drivingDirections = [dict objectForKey:@"drivingDirections"];
    hd.checkInInstructions = [dict objectForKey:@"checkInInstructions"];
    hd.knowBeforeYouGoDescription = [dict objectForKey:@"knowBeforeYouGoDescription"];
    hd.roomFeesDescription = [dict objectForKey:@"roomFeesDescription"];
    hd.locationDescription = [dict objectForKey:@"locationDescription"];
    hd.diningDescription = [dict objectForKey:@"diningDescription"];
    hd.amenitiesDescription = [dict objectForKey:@"amenitiesDescription"];
    hd.businessAmenitiesDescription = [dict objectForKey:@"businessAmenitiesDescription"];
    hd.roomDetailDescription = [dict objectForKey:@"roomDetailDescription"];
    
    return hd;
}

- (NSString *)propertyInformationFormatted {
    if (stringIsEmpty(_propertyInformation)) {
        return @"";
    }
    
    if (![_propertyInformation containsString:@"  "]) {
        return [@"\n● " stringByAppendingString:_propertyInformation];
    }
    
    NSRange r;
    NSString *returnString = [_propertyInformation stringByReplacingOccurrencesOfString:@"      " withString:@"  "];
    returnString = [returnString stringByReplacingOccurrencesOfString:@"    " withString:@"  "];
    while ((r = [returnString rangeOfString:@"  "]).location != NSNotFound) {
        if (r.location + r.length == [returnString length]) {
            returnString = [returnString stringByReplacingCharactersInRange:r withString:@""];
        } else {
            returnString = [returnString stringByReplacingCharactersInRange:r withString:@"\n● "];
        }
    }
    
    return [@"\n● " stringByAppendingString:returnString];
}

- (NSString *)checkInInstructionsFormatted {
    NSString *cii = [_checkInInstructions stringByReplacingOccurrencesOfString:@"<ul><li>" withString:@"<br/>"];
    cii = [cii stringByReplacingOccurrencesOfString:@"<li>" withString:@"<br/>"];
    return [@"● " stringByAppendingString:stringByStrippingHTMLReplaceBreak(cii, @"\n● ")];
}

- (NSString *)roomFeesDescriptionFormmatted {
    if (stringIsEmpty(_roomFeesDescription)) {
        return @"";
    }
    
    NSString *rff = [_roomFeesDescription stringByReplacingOccurrencesOfString:@"<ul><li>" withString:@"<br/>"];
    rff = [rff stringByReplacingOccurrencesOfString:@"<li>" withString:@"<br/>"];
    
    NSRange r = [rff rangeOfString:@"<p>"];
    if (r.location != NSNotFound) {
        rff = [rff stringByReplacingCharactersInRange:r withString:@""];
    }
    
    r = [rff rangeOfString:@"</p>"];
    if (r.location != NSNotFound) {
        rff = [rff stringByReplacingCharactersInRange:r withString:@"\n"];
    }
    
    rff = [rff stringByReplacingOccurrencesOfString:@"<p>" withString:@"\n\n"];
    return [@"" stringByAppendingString:stringByStrippingHTMLReplaceBreak(rff, @"\n● ")];
}

@end
