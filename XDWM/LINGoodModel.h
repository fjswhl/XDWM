//
//  LINGoodModel.h
//  XDWM
//
//  Created by Lin on 14-2-8.
//  Copyright (c) 2014年 WeAround. All rights reserved.
//

#import <Foundation/Foundation.h>

#define __GOODNAME__    @"goods_name"
#define __GOODHOTEL__   @"goods_hotel"
#define __GOODPRICE__   @"goods_price"
#define __GOODNUM__     @"goods_number"
#define __GOODINTRO__   @"goods_introduce"
#define __GOODPIC__     @"goods_big_img"
#define __GOODCTIME__   @"goods_create_time"

@interface LINGoodModel : NSObject
@property (strong, nonatomic) NSString *goodName;
@property (strong, nonatomic) NSString *goodHotel;
@property (strong, nonatomic) NSString *goodPrice;
@property (nonatomic) NSInteger goodNumber;
@property (strong, nonatomic) NSString *goodIntroduce;
@property (strong, nonatomic) NSString *goodImg;
@property (strong, nonatomic) NSString *goodCreateTime;

- (LINGoodModel *)initWithDictionary:(NSDictionary *)dic;
@end
