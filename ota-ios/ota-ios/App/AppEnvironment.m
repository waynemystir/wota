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
NSString * const EAN_BOK_REQ_BASE_URL = @"https://dev.api.ean.com";
NSString * const EAN_URL_EXT = @"ean-services/rs";
NSString * const EAN_H0TEL_LIST = @"hotel/v3/list";
NSString * const EAN_HOTEL_INFO = @"hotel/v3/info";
NSString * const EAN_ROOMS_AVAILABLE = @"hotel/v3/avail";
NSString * const EAN_GEO_SEARCH = @"hotel/v3/geoSearch";

NSString * const GOOGLE_API_KEY = @"AIzaSyBTMg_o0S630MntWlqDC4J9tuNrh_YkLIo";

int const URL_REQUEST_TIMEOUT = 30;

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

NSString * kEanGeoSearchRequestUrl() {
    return [NSString stringWithFormat:@"%@/%@", kEanGeneralRequestUrl(), EAN_GEO_SEARCH];
}
