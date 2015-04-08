//
//  AppEnvironment.m
//  ean-ota-ios
//
//  Created by WAYNE SMALL on 3/20/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "AppEnvironment.h"

NSString * const EAN_CID = @"55505";
NSString * const EAN_API_KEY = @"ds5gqba7fbetw3wwgq7nnjku";
NSString * const EAN_SHARED_SECRET = @"QzrgJ6Vc";
NSString * const EAN_API_EXPERIENCE = @"PARTNER_MOBILE_APP";
NSString * const EAN_GEN_REQ_BASE_URL = @"http://dev.api.ean.com";
NSString * const EAN_BOK_REQ_BASE_URL = @"https://book.api.ean.com";
NSString * const EAN_URL_EXT = @"ean-services/rs";
NSString * const EAN_H0TEL_LIST = @"hotel/v3/list";
NSString * const EAN_HOTEL_INFO = @"hotel/v3/info";
NSString * const EAN_ROOMS_AVAILABLE = @"hotel/v3/avail";
NSString * const EAN_BOOK_RESERVATION = @"hotel/v3/res";
NSString * const EAN_GEO_SEARCH = @"hotel/v3/geoSearch";

NSString * const GOOGLE_API_KEY = @"AIzaSyBTMg_o0S630MntWlqDC4J9tuNrh_YkLIo";

int const URL_REQUEST_TIMEOUT = 30;
NSString * const WOTA_CACHE_DIRECTORY = @"wota_cache_directory";
NSString * const WOTA_CACHE_CHILD_TRAVELERS_DIRECTORY = @"child_travelers_directory";
NSString * const WOTA_CACHE_GOOGLE_PLACE_DETAIL_DIRECTORY = @"google_place_detail_directory";

NSString * const EAN_PK_API_KEY = @"apiKey";
NSString * const EAN_PK_CID = @"cid";
NSString * const EAN_PK_CUSTIPADD = @"customerIpAddress";
NSString * const EAN_PK_CUSTUSERAGENT = @"customerUserAgent";
NSString * const EAN_PK_CUSTSESSID = @"customerSessionId";
NSString * const EAN_PK_MINORREV = @"minorRev";
NSString * const EAN_PK_LOCALE = @"locale";
NSString * const EAN_PK_CURRENCY_CODE = @"currencyCode";
NSString * const EAN_PK_CITY = @"city";
NSString * const EAN_PK_STATE_PROV_CODE = @"stateProvinceCode";
NSString * const EAN_PK_COUNTRY_CODE = @"countryCode";
NSString * const EAN_PK_POSTAL_CODE = @"postalCode";
NSString * const EAN_PK_ARRIVAL_DATE = @"arrivalDate";
NSString * const EAN_PK_DEPART_DATE = @"departureDate";
NSString * const EAN_PK_DESTINATION_STRING = @"destinationString";
NSString * const EAN_PK_TYPE = @"type";
NSString * const EAN_PK_LATITUDE = @"latitude";
NSString * const EAN_PK_LONGITUDE = @"longitude";
NSString * const EAN_PK_SEARCH_RADIUS = @"searchRadius";
NSString * const EAN_PK_SEARCH_RADIUS_UNIT = @"searchRadiusUnit";
NSString * const EAN_PK_GEO_SORT = @"sort";
NSString * const EAN_PK_HOTEL_ID = @"hotelId";
NSString * const EAN_PK_SUPPLIER_TYPE = @"supplierType";
NSString * const EAN_PK_RATE_KEY = @"rateKey";
NSString * const EAN_PK_ROOM_TYPE_CODE = @"roomTypeCode";
NSString * const EAN_PK_RATE_CODE = @"rateCode";
NSString * const EAN_PK_CHARGEABLE_RATE = @"chargeableRate";
NSString * const EAN_PK_ROOM1_FIRST_NAME = @"room1FirstName";
NSString * const EAN_PK_ROOM1_LAST_NAME = @"room1LastName";
NSString * const EAN_PK_ROOM1_BED_TYPE_ID = @"room1BedTypeId";
NSString * const EAN_PK_ROOM1_SMOKING_PREF = @"room1SmokingPreference";
NSString * const EAN_PK_AFFILIATE_CONFIRMATION_ID = @"affiliateConfirmationId";
NSString * const EAN_PK_EMAIL = @"email";
NSString * const EAN_PK_FIRST_NAME = @"firstName";
NSString * const EAN_PK_LAST_NAME = @"lastName";
NSString * const EAN_PK_HOME_PHONE = @"homePhone";
NSString * const EAN_PK_CC_TYPE = @"creditCardType";
NSString * const EAN_PK_CC_NUMBER = @"creditCardNumber";
NSString * const EAN_PK_CC_IDENTIFIER = @"creditCardIdentifier";
NSString * const EAN_PK_CC_EXPIR_MONTH = @"creditCardExpirationMonth";
NSString * const EAN_PK_CC_EXPIR_YEAR = @"creditCardExpirationYear";
NSString * const EAN_PK_CC_ADDRESS1 = @"address1";
NSString * const EAN_PK_CC_CITY = @"city";
NSString * const EAN_PK_CC_STATE_PROV_CODE = @"stateProvinceCode";
NSString * const EAN_PK_CC_COUNTRY_CODE = @"countryCode";
NSString * const EAN_PK_CC_POSTAL_CODE = @"postalCode";

NSString * kEanGeneralRequestUrl() {
    return [NSString stringWithFormat:@"%@/%@", EAN_GEN_REQ_BASE_URL, EAN_URL_EXT];
}

NSString * kEanHotelListRequestUrl() {
    return [NSString stringWithFormat:@"%@/%@", kEanGeneralRequestUrl(), EAN_H0TEL_LIST];
}

NSString * kEanHotelInfoRequestUrl() {
    return [NSString stringWithFormat:@"%@/%@", kEanGeneralRequestUrl(), EAN_HOTEL_INFO];
}

NSString * kEanAvailableRoomsRequestUrl() {
    return [NSString stringWithFormat:@"%@/%@", kEanGeneralRequestUrl(), EAN_ROOMS_AVAILABLE];
}

NSString * kEanBookReservationUrl() {
    return [NSString stringWithFormat:@"%@/%@/%@", EAN_BOK_REQ_BASE_URL, EAN_URL_EXT, EAN_BOOK_RESERVATION];
//    return @"https://book.api.ean.com/ean-services/rs/hotel/v3/res?";
}

NSString * kEanGeoSearchRequestUrl() {
    return [NSString stringWithFormat:@"%@/%@", kEanGeneralRequestUrl(), EAN_GEO_SEARCH];
}

NSString * kWotaCacheDirectory() {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
                      stringByAppendingFormat:@"/%@", WOTA_CACHE_DIRECTORY];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return path;
}

NSString * kWotaCacheChildTravelersDirectory() {
    NSString *path = [kWotaCacheDirectory() stringByAppendingFormat:@"/%@", WOTA_CACHE_CHILD_TRAVELERS_DIRECTORY];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return path;
}

NSString * kWotaCacheGooglePlaceDetailDirectory() {
    NSString *path = [kWotaCacheDirectory() stringByAppendingFormat:@"/%@", WOTA_CACHE_GOOGLE_PLACE_DETAIL_DIRECTORY];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return path;
}

NSDateFormatter * kEanApiDateFormatter() {
    static NSDateFormatter *_eanApiDateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _eanApiDateFormatter = [[NSDateFormatter alloc] init];
        [_eanApiDateFormatter setDateFormat:@"MM/dd/yyyy"];
    });
    return _eanApiDateFormatter;
}