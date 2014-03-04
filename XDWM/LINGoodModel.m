//
//  LINGoodModel.m
//  XDWM
//
//  Created by Lin on 14-2-8.
//  Copyright (c) 2014年 WeAround. All rights reserved.
//

#import "LINGoodModel.h"

@implementation LINGoodModel

- (LINGoodModel *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.goodID = dic[__GOODID__];
        self.goodName = dic[__GOODNAME__];
        self.goodCreateTime = dic[__GOODCTIME__];
        self.goodHotel = dic[__GOODHOTEL__];
        self.goodImg = dic[__GOODPIC__];
        self.goodIntroduce = dic[__GOODINTRO__];
        self.goodNumber = [dic[__GOODNUM__] integerValue];
        self.goodPrice = dic[__GOODPRICE__];
    }
    return self;
}
@end
