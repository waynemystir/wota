//
//  LoadEanData.m
//  ean-ota-ios
//
//  Created by WAYNE SMALL on 3/20/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "LoadEanData.h"
#import "AppDelegate.h"
#import "AppEnvironment.h"
#import <CommonCrypto/CommonDigest.h>
#import "ChildTraveler.h"
#import "EanCredentials.h"

static BOOL withIpAddressForBooking = YES;

void setWithIpAddress(BOOL withIp) {
    withIpAddressForBooking = withIp;
}

typedef NS_ENUM(NSUInteger, HTTP_METHOD) {
    HTTP_GET = 0,
    HTTP_POST = 1
};

#pragma mark EAN stuff

NSString * const EAN_API_EXPERIENCE = @"PARTNER_MOBILE_APP";
NSString * const EAN_MINOR_REV = @"30";
NSString * const EAN_GEN_REQ_BASE_URL = @"http://api.ean.com";
NSString * const EAN_BOK_REQ_BASE_URL = @"https://book.api.ean.com";
NSString * const EAN_URL_EXT = @"ean-services/rs";
NSString * const EAN_H0TEL_LIST = @"hotel/v3/list";
NSString * const EAN_HOTEL_INFO = @"hotel/v3/info";
NSString * const EAN_PAYMENT_TYPES = @"hotel/v3/paymentInfo";
NSString * const EAN_ROOMS_AVAILABLE = @"hotel/v3/avail";
NSString * const EAN_BOOK_RESERVATION = @"hotel/v3/res";
NSString * const EAN_ITINERARY_REQ = @"hotel/v3/itin";
NSString * const EAN_GEO_SEARCH = @"hotel/v3/geoSearch";

#pragma mark URL parameter keys

NSString * const EAN_PK_API_EXPERIENCE = @"apiExperience";
NSString * const EAN_PK_MINOR_REV = @"minorRev";
NSString * const EAN_PK_API_KEY = @"apiKey";
NSString * const EAN_PK_CID = @"cid";
NSString * const EAN_PK_SIG = @"sig";
NSString * const EAN_PK_CUSTIPADD = @"customerIpAddress";
NSString * const EAN_PK_CUSTUSERAGENT = @"customerUserAgent";
NSString * const EAN_PK_CUSTSESSID = @"customerSessionId";
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
NSString * const EAN_PK_NUMBER_OF_RESULTS = @"numberOfResults";
NSString * const EAN_PK_SEARCH_RADIUS = @"searchRadius";
NSString * const EAN_PK_SEARCH_RADIUS_UNIT = @"searchRadiusUnit";
NSString * const EAN_PK_GEO_SORT = @"sort";
NSString * const EAN_PK_HOTEL_ID = @"hotelId";
NSString * const EAN_PK_INCLUDE_DETAILS = @"includeDetails";
NSString * const EAN_PK_INCLUDE_ROOM_IMAGES = @"includeRoomImages";
NSString * const EAN_PK_OPTIONS = @"options";
NSString * const EAN_PK_SUPPLIER_TYPE = @"supplierType";
NSString * const EAN_PK_RATE_TYPE = @"rateType";
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

#pragma mark Various EAN parameter value constants

NSString * const EAN_ROOM_TYPES = @"ROOM_TYPES";
NSString * const EAN_ROOM_AMENITIES = @"ROOM_AMENITIES";
NSString * const EAN_HOTEL_IMAGES = @"HOTEL_IMAGES";

#pragma mark Various EAN parameter values

NSString * kEanGenerateSigMD5() {
    // Curtesy of http://stackoverflow.com/questions/2018550/how-do-i-create-an-md5-hash-of-a-string-in-cocoa
    NSTimeInterval uts = [[NSDate date] timeIntervalSince1970];
    NSUInteger utsInt = uts;
    NSString *unixTimeStamp = [NSString stringWithFormat:@"%lu", (unsigned long)utsInt];
    
    NSString *stringToHash = [NSString stringWithFormat:@"%@%@%@", [EanCredentials apiKey], [EanCredentials sharedSecret], unixTimeStamp];
    const char *cstr = [stringToHash UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cstr, (CC_LONG)strlen(cstr), result);
    
    return [[NSString stringWithFormat:
             @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}

NSString * kEanCustomerSessionId() {
    static NSString *_customerSessionId = nil;
    if (!_customerSessionId) {
        NSString *csid = [[[NSUUID UUID] UUIDString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _customerSessionId = [NSString stringWithFormat:@"Trotter-CustSessID-%@", csid];
    }
    return _customerSessionId;
}

NSString * kEanCustomerUserAgent() {
    static NSString *_customerUserAgent = nil;
    if (!_customerUserAgent) {
        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
        NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
        NSString *osVersion = [[UIDevice currentDevice] systemVersion];
        _customerUserAgent = [NSString stringWithFormat:@"%@/%@ (iOS %@) MOBILE_APP", appName, appVersion, osVersion];
    }
    return _customerUserAgent;
}

NSString * kEanCommonParameters(BOOL withIpAddress) {
    NSString *ipAddress = @"";
    if (withIpAddress) {
        ipAddress = [NSString stringWithFormat:@"&%@=%@", EAN_PK_CUSTIPADD, [AppDelegate externalIP]];
    } else {
        withIpAddressForBooking = YES;
    }
    
    return [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@%@&%@=%@&%@=%@",
            EAN_PK_API_EXPERIENCE, EAN_API_EXPERIENCE,
            EAN_PK_CID, [EanCredentials CID],
            EAN_PK_API_KEY, [EanCredentials apiKey],
            EAN_PK_SIG, kEanGenerateSigMD5(),
            EAN_PK_MINOR_REV, EAN_MINOR_REV,
            EAN_PK_LOCALE, [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier],
            EAN_PK_CURRENCY_CODE, [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode],
            ipAddress,
            EAN_PK_CUSTSESSID, kEanCustomerSessionId(),
            EAN_PK_CUSTUSERAGENT, kEanCustomerUserAgent()];
}

#pragma mark Various EAN URL's

NSString * kEanRequest(NSString * endPoint) {
    return [NSString stringWithFormat:@"%@/%@/%@?%@",
            EAN_GEN_REQ_BASE_URL, EAN_URL_EXT, endPoint, kEanCommonParameters(YES)];
}

NSString * kURLeanHotelList() {
    return kEanRequest(EAN_H0TEL_LIST);
}

NSString * kURLeanHotelInfo() {
    return kEanRequest(EAN_HOTEL_INFO);
}

NSString * kURLeanPaymentTypes() {
    return kEanRequest(EAN_PAYMENT_TYPES);
}

NSString * kURLeanAvailRooms() {
    return kEanRequest(EAN_ROOMS_AVAILABLE);
}

NSString * kURLeanBookReservation() {
    return [NSString stringWithFormat:@"%@/%@/%@?%@",
            EAN_BOK_REQ_BASE_URL, EAN_URL_EXT, EAN_BOOK_RESERVATION, kEanCommonParameters(withIpAddressForBooking)];
}

NSString * kURLeanItinReq() {
    return kEanRequest(EAN_ITINERARY_REQ);
}

@interface LoadEanData () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSMutableData *responseData;

@end

@implementation LoadEanData

+ (LoadEanData *)sharedInstance {
    static LoadEanData *_instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _instance = [[LoadEanData alloc] init];
    });
    
    return _instance;
}

+ (LoadEanData *)sharedInstance:(id<LoadDataProtocol>)delegate {
    LoadEanData *ean = [self sharedInstance];
    ean.delegate = delegate;
    return ean;
}

- (void)fireOffConnectionWithURL:(NSURL *)url httpMethod:(HTTP_METHOD)httpMethod {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    if ([[url absoluteString] containsString:EAN_BOOK_RESERVATION])
        // I chose 67 seconds because EAN servers have a 60 second timeout
        // http://developer.ean.com/docs/error-handling/special-cases/prevent-duplicates
        [request setTimeoutInterval:67];
    else
        [request setTimeoutInterval:URL_REQUEST_TIMEOUT];
    
    switch (httpMethod) {
        case HTTP_GET: {
            [request setHTTPMethod:@"GET"];
            break;
        }
        case HTTP_POST: {
            [request setHTTPMethod:@"POST"];
            break;
        }
            
        default: {
            [request setHTTPMethod:@"GET"];
            break;
        }
    }
    
//    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
//    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
//    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
//    NSString *userAgent = [NSString stringWithFormat:@"%@/%@ (iOS %@) MOBILE_APP", appName, appVersion, osVersion];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    self.responseData = [NSMutableData data];
    [connection start];
    
    TrotterLog(@"", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [url absoluteString]);
    if ([self.delegate respondsToSelector:@selector(requestStarted:)]) {
        [self.delegate requestStarted:connection];
    }
}

- (void)loadHotelsWithLatitude:(double)latitude
                     longitude:(double)longitude {
    [self loadHotelsWithLatitude:latitude
                       longitude:longitude
                     arrivalDate:nil
                      returnDate:nil];
}

- (void)loadHotelsWithLatitude:(double)latitude
                     longitude:(double)longitude
                   arrivalDate:(NSString *)arrivalDate
                    returnDate:(NSString *)returnDate {
    [self loadHotelsWithLatitude:latitude
                       longitude:longitude
                     arrivalDate:arrivalDate
                      returnDate:returnDate
                    searchRadius:@35
                   withProximity:NO];
}

- (void)loadHotelsWithLatitude:(double)latitude
                     longitude:(double)longitude
                   arrivalDate:(NSString *)arrivalDate
                    returnDate:(NSString *)returnDate
                  searchRadius:(NSNumber *)searchRadius
                 withProximity:(BOOL)withProximity {
    
    __weak typeof(self) wes = self;
    
    [EanCredentials waitForEnabledCredentialIterations:^(BOOL success) {
        if (success) {
            NSURL *url = [NSURL URLWithString:[wes URLhotelListWithLatitude:latitude
                                                                   longitude:longitude
                                                                 arrivalDate:arrivalDate
                                                                  returnDate:returnDate
                                                                searchRadius:searchRadius
                                                               withProximity:withProximity]];
            [wes fireOffConnectionWithURL:url httpMethod:HTTP_GET];
        } else {
            [wes performSelector:@selector(performRequestFailedCredentials) withObject:nil afterDelay:0.25];
        }
    }];
}

- (void)performRequestFailedCredentials {
    if ([self.delegate respondsToSelector:@selector(requestFailedCredentials)]) {
        [self.delegate requestFailedCredentials];
    }
}

- (NSString *)URLhotelListWithLatitude:(double)latitude
                             longitude:(double)longitude
                           arrivalDate:(NSString *)arrivalDate
                            returnDate:(NSString *)returnDate
                          searchRadius:(NSNumber *)searchRadius
                         withProximity:(BOOL)withProximity {
    NSString *appendage = nil;
    
    if (arrivalDate == nil || returnDate == nil) {
        appendage = [NSString stringWithFormat:@""];
    } else {
        appendage = [NSString stringWithFormat:@"&%@=%@&%@=%@",
                     EAN_PK_ARRIVAL_DATE, arrivalDate,
                     EAN_PK_DEPART_DATE, returnDate];
    }
    
    return [[[self URLhotelListWithLatitude:latitude longitude:longitude searchRadius:searchRadius withProximity:withProximity] stringByAppendingString:appendage] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)URLhotelListWithLatitude:(double)latitude
                             longitude:(double)longitude
                          searchRadius:(NSNumber *)searchRadius
                         withProximity:(BOOL)withProximity {
    NSString *st = withProximity ? @"PROXIMITY" : @"CITY_VALUE";
    
    return [NSString stringWithFormat:@"%@&%@=%f&%@=%f&%@=%@&%@=%@&%@=%@&%@=%@",
            kURLeanHotelList(),
            EAN_PK_LATITUDE, latitude,
            EAN_PK_LONGITUDE, longitude,
            EAN_PK_NUMBER_OF_RESULTS, @200,
            EAN_PK_SEARCH_RADIUS, searchRadius,
            EAN_PK_SEARCH_RADIUS_UNIT, @"MI",
            EAN_PK_GEO_SORT, st
            ];
}

- (void)loadHotelDetailsWithId:(NSString *)hotelId {
    NSURL *url = [NSURL URLWithString:[self URLhotelInfoWithId:hotelId]];
    [self fireOffConnectionWithURL:url httpMethod:HTTP_GET];
}

- (NSString *)URLhotelInfoWithId:(NSString *)hotelId {
    return [[NSString stringWithFormat:@"%@&%@=%@", kURLeanHotelInfo(), EAN_PK_HOTEL_ID, hotelId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (void)loadPaymentTypesWithHotelId:(NSString *)hotelId
                       supplierType:(NSString *)supplierType
                           rateType:(NSString *)rateType
                    completionBlock:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))completionBlock {
    NSURL *url = [NSURL URLWithString:[self URLpaymentTypesWithHotelId:hotelId supplierType:supplierType rateType:rateType]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:URL_REQUEST_TIMEOUT];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
//    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
//    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
//    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
//    NSString *userAgent = [NSString stringWithFormat:@"%@/%@ (iOS %@) MOBILE_APP", appName, appVersion, osVersion];
//    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        completionBlock(response, data, connectionError);
    }];
}

- (NSString *)URLpaymentTypesWithHotelId:(NSString *)hotelId
                            supplierType:(NSString *)supplierType
                                rateType:(NSString *)rateType {
    return [[NSString stringWithFormat:@"%@&%@=%@&%@=%@&%@=%@",
             kURLeanPaymentTypes(),
             EAN_PK_HOTEL_ID, hotelId,
             EAN_PK_SUPPLIER_TYPE, supplierType,
             EAN_PK_RATE_TYPE, rateType] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (void)loadAvailableRoomsWithHotelId:(NSString *)hotelId
                          arrivalDate:(NSString *)arrivalDate
                        departureDate:(NSString *)departureDate
                       numberOfAdults:(NSUInteger)numberOfAdults
                       childTravelers:(NSArray *)childTravelers {
    NSURL *url = [NSURL URLWithString:[self URLavailRoomsWithHotelId:hotelId arrivalDate:arrivalDate departureDate:departureDate numberOfAdults:numberOfAdults childTravelers:childTravelers]];
    [self fireOffConnectionWithURL:url httpMethod:HTTP_GET];
}

- (NSString *)URLavailRoomsWithHotelId:(NSString *)hotelId
                           arrivalDate:(NSString *)arrivalDate
                         departureDate:(NSString *)departureDate
                        numberOfAdults:(NSUInteger)numberOfAdults
                        childTravelers:(NSArray *)childTravelers {
    return [[NSString stringWithFormat:@"%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@&%@=%@",
             kURLeanAvailRooms(),
             EAN_PK_HOTEL_ID, hotelId,
             EAN_PK_ARRIVAL_DATE, arrivalDate,
             EAN_PK_DEPART_DATE, departureDate,
             EAN_PK_INCLUDE_DETAILS, @"true",
             EAN_PK_INCLUDE_ROOM_IMAGES, @"true",
             [self getRoomGroupParamWithNumberOfAdults:numberOfAdults childTravelers:childTravelers],
             EAN_PK_OPTIONS, [NSString stringWithFormat:@"%@", EAN_ROOM_TYPES]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)getRoomGroupParamWithNumberOfAdults:(NSUInteger)numberOfAdults
                                   childTravelers:(NSArray *)childTravelers {
    NSMutableString *roomGroup = [NSMutableString stringWithFormat:@"room1=%lu", (unsigned long)numberOfAdults];
    
    if (childTravelers == nil || [childTravelers count] == 0) {
        return roomGroup;
    }
    
    for (ChildTraveler *ct in childTravelers) {
        [roomGroup appendFormat:@",%lu", (unsigned long)ct.childAge];
    }
    
    return roomGroup;
}


- (void)bookHotelRoomWithHotelId:(NSString *)hotelId
                     arrivalDate:(NSString *)arrivalDate
                   departureDate:(NSString *)departureDate
                    supplierType:(NSString *)supplierType
                         rateKey:(NSString *)rateKey
                    roomTypeCode:(NSString *)roomTypeCode
                        rateCode:(NSString *)rateCode
                  chargeableRate:(float)chargeableRate
                  numberOfAdults:(NSUInteger)numberOfAdults
                  childTravelers:(NSArray *)childTravelers
                  room1FirstName:(NSString *)room1FirstName
                   room1LastName:(NSString *)room1LastName
                  room1BedTypeId:(NSString *)room1BedTypeId
          room1SmokingPreference:(NSString *)room1SmokingPreference
         affiliateConfirmationId:(NSUUID *)affiliateConfirmationId
                           email:(NSString *)email
                       firstName:(NSString *)firstName
                        lastName:(NSString *)lastName
                       homePhone:(NSString *)homePhone
                  creditCardType:(NSString *)creditCardType
                creditCardNumber:(NSString *)creditCardNumber
            creditCardIdentifier:(NSString *)creditCardIdentifier
       creditCardExpirationMonth:(NSString *)creditCardExpirationMonth
        creditCardExpirationYear:(NSString *)creditCardExpirationYear
                        address1:(NSString *)address1
                            city:(NSString *)city
               stateProvinceCode:(NSString *)stateProvinceCode
                     countryCode:(NSString *)countryCode
                      postalCode:(NSString *)postalCode {
    NSString *urlString = [[NSString stringWithFormat:@"%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%f&%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",
                     kURLeanBookReservation(),
                     EAN_PK_HOTEL_ID, hotelId,
                     EAN_PK_ARRIVAL_DATE, arrivalDate,
                     EAN_PK_DEPART_DATE, departureDate,
                     EAN_PK_SUPPLIER_TYPE, supplierType,
                     EAN_PK_RATE_KEY, rateKey,
                     EAN_PK_ROOM_TYPE_CODE, roomTypeCode,
                     EAN_PK_RATE_CODE, rateCode,
                     EAN_PK_CHARGEABLE_RATE, chargeableRate,
                     [self getRoomGroupParamWithNumberOfAdults:numberOfAdults childTravelers:childTravelers],
                     EAN_PK_ROOM1_FIRST_NAME, room1FirstName,
                     EAN_PK_ROOM1_LAST_NAME, room1LastName,
                     EAN_PK_ROOM1_BED_TYPE_ID, room1BedTypeId,
                     EAN_PK_ROOM1_SMOKING_PREF, room1SmokingPreference,
                     EAN_PK_AFFILIATE_CONFIRMATION_ID, [affiliateConfirmationId UUIDString],
                     EAN_PK_EMAIL, email,
                     EAN_PK_FIRST_NAME, firstName,
                     EAN_PK_LAST_NAME, lastName,
                     EAN_PK_HOME_PHONE, homePhone,
                     EAN_PK_CC_TYPE, creditCardType,
                     EAN_PK_CC_NUMBER, creditCardNumber,
                     EAN_PK_CC_IDENTIFIER, creditCardIdentifier,
                     EAN_PK_CC_EXPIR_MONTH, creditCardExpirationMonth,
                     EAN_PK_CC_EXPIR_YEAR, creditCardExpirationYear,
                     EAN_PK_CC_ADDRESS1, address1,
                     EAN_PK_CC_CITY, city,
                     EAN_PK_CC_STATE_PROV_CODE, stringIsEmpty(stateProvinceCode) ? @"" : stateProvinceCode,
                     EAN_PK_CC_COUNTRY_CODE, countryCode,
                     EAN_PK_CC_POSTAL_CODE, postalCode] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    TrotterLog(@"BOOKING:%@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    [self fireOffConnectionWithURL:url httpMethod:HTTP_POST];
}

- (void)loadItineraryWithAffiliateConfirmationId:(NSUUID *)affiliateConfirmationId {
    NSString *urlString = [[NSString stringWithFormat:@"%@&%@=%@",
                            kURLeanItinReq(),
                            EAN_PK_AFFILIATE_CONFIRMATION_ID, [affiliateConfirmationId UUIDString]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:urlString];
    [self fireOffConnectionWithURL:url httpMethod:HTTP_GET];
}

#pragma mark NSURLConnectionDataDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//    NSLog(@"%@.%@:::%@", self.class, NSStringFromSelector(_cmd), [[[connection currentRequest] URL] absoluteString]);
//    NSLog(@"%@.%@ RESPONSE:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [response description]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//    NSLog(@"%@.%@:::%@", self.class, NSStringFromSelector(_cmd), [[[connection currentRequest] URL] absoluteString]);
    
    NSString *urlString = [[[connection currentRequest] URL] absoluteString];
    
    if ([urlString containsString:EAN_H0TEL_LIST]) {
        
        [self.delegate requestFinished:self.responseData dataType:LOAD_EAN_HOTELS_LIST];
        
    } else if ([urlString containsString:EAN_HOTEL_INFO]) {
        
        [self.delegate requestFinished:self.responseData dataType:LOAD_EAN_HOTEL_DETAILS];
        
    } else if ([urlString containsString:EAN_PAYMENT_TYPES]) {
        
        [self.delegate requestFinished:self.responseData dataType:LOAD_EAN_PAYMENT_TYPES];
        
    } else if ([urlString containsString:EAN_ROOMS_AVAILABLE]) {
        
        [self.delegate requestFinished:self.responseData dataType:LOAD_EAN_AVAILABLE_ROOMS];
        
    } else if ([urlString containsString:EAN_BOOK_RESERVATION]) {
        
        [self.delegate requestFinished:self.responseData dataType:LOAD_EAN_BOOK];
        
    } else if ([urlString containsString:EAN_ITINERARY_REQ]) {
        
        [self.delegate requestFinished:self.responseData dataType:LOAD_EAN_ITIN];
        
    } else {
        assert(false);
    }

}

#pragma mark NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@.%@ ERROR:%@ URL:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [error localizedDescription], [[[connection currentRequest] URL] absoluteString]);
    
    NSString *urlString = [[[connection currentRequest] URL] absoluteString];
    LOAD_DATA_TYPE dt;
    
    if ([urlString containsString:EAN_H0TEL_LIST]) {
        
        dt = LOAD_EAN_HOTELS_LIST;
        
    } else if ([urlString containsString:EAN_HOTEL_INFO]) {
        
        dt = LOAD_EAN_HOTEL_DETAILS;
        
    } else if ([urlString containsString:EAN_PAYMENT_TYPES]) {
        
        dt = LOAD_EAN_PAYMENT_TYPES;
        
    } else if ([urlString containsString:EAN_ROOMS_AVAILABLE]) {
        
        dt = LOAD_EAN_AVAILABLE_ROOMS;
        
    } else if ([urlString containsString:EAN_BOOK_RESERVATION]) {
        
        dt = LOAD_EAN_BOOK;
        
    } else if ([urlString containsString:EAN_ITINERARY_REQ]) {
        
        dt = LOAD_EAN_ITIN;
        
    } else {
        assert(false);
    }
    
    switch (error.code) {
        case NSURLErrorTimedOut: {
            [self.delegate requestTimedOut:dt];
            break;
        }
            
        case NSURLErrorNotConnectedToInternet: {
            [self.delegate requestFailedOffline];
            break;
        }
            
        default: {
            [self.delegate requestFailed];
            break;
        }
    }
}

@end
