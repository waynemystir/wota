//
//  EanHotelInfoImage.m
//  ota-ios
//
//  Created by WAYNE SMALL on 4/5/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "EanHotelInfoImage.h"

@implementation EanHotelInfoImage

+ (EanHotelInfoImage *)imageFromDict:(NSDictionary *)dict {
    if (nil == dict) {
        return nil;
    }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    EanHotelInfoImage *image = [[EanHotelInfoImage alloc] init];
    
    image.hotelImageId = [dict objectForKey:@"hotelImageId"];
    image.hotelImageName = [dict objectForKey:@"name"];
    image.hotelImageCategory = [dict objectForKey:@"category"];
    image.hotelImageType = [dict objectForKey:@"type"];
    image.caption = [dict objectForKey:@"caption"];
    image.url = [dict objectForKey:@"url"];
    image.thumbnailUrl = [dict objectForKey:@"thumbnailUrl"];
    image.supplierId = [dict objectForKey:@"supplierId"];
    image.width = [[dict objectForKey:@"width"] integerValue];
    image.height = [[dict objectForKey:@"height"] integerValue];
    image.byteSize = [dict objectForKey:@"byteSize"];
    
    return image;
}

@end
