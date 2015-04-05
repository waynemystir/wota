//
//  EanHotelInfoImage.h
//  ota-ios
//
//  Created by WAYNE SMALL on 4/5/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EanHotelInfoImage : NSObject

@property (nonatomic, strong) NSString *hotelImageId;
@property (nonatomic, strong) NSString *hotelImageName;
@property (nonatomic, strong) id hotelImageCategory;
@property (nonatomic, strong) id hotelImageType;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *thumbnailUrl;
@property (nonatomic, strong) NSString *supplierId;
@property (nonatomic) NSUInteger width;
@property (nonatomic) NSUInteger height;
@property (nonatomic, strong) id byteSize;

+ (EanHotelInfoImage *)imageFromDict:(NSDictionary *)dict;

@end
