//
//  AppEnvironment.h
//  ean-ota-ios
//
//  Created by WAYNE SMALL on 3/20/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UITransparentFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:0.0]


extern NSString * const EAN_CID;
extern NSString * const EAN_API_KEY;
extern NSString * const EAN_SHARED_SECRET;
extern NSString * const EAN_API_EXPERIENCE;
extern NSString * const EAN_GEN_REQ_BASE_URL;
extern NSString * const EAN_BOK_REQ_BASE_URL;
extern NSString * const EAN_URL_EXT;
extern NSString * const EAN_H0TEL_LIST;
extern NSString * const EAN_HOTEL_INFO;
extern NSString * const EAN_ROOMS_AVAILABLE;

extern NSString * const GOOGLE_API_KEY;

extern int const URL_REQUEST_TIMEOUT;

/**
 * URL parameter keys
 */

extern NSString * const EAN_PK_API_KEY;
extern NSString * const EAN_PK_CID;
extern NSString * const EAN_PK_CUSTIPADD;
extern NSString * const EAN_PK_CUSTUSERAGENT;
extern NSString * const EAN_PK_CUSTSESSID;
extern NSString * const EAN_PK_MINORREV;
extern NSString * const EAN_PK_LOCALE;
extern NSString * const EAN_PK_CURRENCY_CODE;
extern NSString * const EAN_PK_CITY;
extern NSString * const EAN_PK_STATE_PROV_CODE;
extern NSString * const EAN_PK_COUNTRY_CODE;
extern NSString * const EAN_PK_POSTAL_CODE;
extern NSString * const EAN_PK_ARRIVAL_DATE;
extern NSString * const EAN_PK_DEPART_DATE;
extern NSString * const EAN_PK_DESTINATION_STRING;
extern NSString * const EAN_PK_TYPE;
extern NSString * const EAN_PK_LATITUDE;
extern NSString * const EAN_PK_LONGITUDE;
extern NSString * const EAN_PK_SEARCH_RADIUS;
extern NSString * const EAN_PK_SEARCH_RADIUS_UNIT;
extern NSString * const EAN_PK_GEO_SORT;

/**
 * Various URL's
 */

extern NSString * kEanGeneralRequestUrl();
extern NSString * kEanHotelListRequestUrl();
extern NSString * kEanHotelInfoRequestUrl();
extern NSString * kEanAvailableRoomsRequestUrl();
extern NSString * kEanGeoSearchRequestUrl();

/**
 * Other stuff
 */
extern NSString * kWotaCacheDirectory();
extern NSString *kWotaCacheChildTravelersDirectory();