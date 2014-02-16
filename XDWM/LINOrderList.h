//
//  LINOrderList.h
//  XDWM
//
//  Created by Lin on 14-2-8.
//  Copyright (c) 2014年 WeAround. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LINUserModel.h"

#define __GOODSNAME__       @"goods_name"
#define __GOODSHOTEL__      @"goods_hotel"
#define __GOODSPRICE__      @"goods_price"
#define __NUMBER__          @"number"
#define __TOTALPRICE__      @"total_price"
#define __CREATETIME__      @"create_time"
#define __CREATEDAY__       @"create_time_day"
#define __ORDERLISTID__     @"orderlist_id"
@interface LINOrderList : NSObject

@property (nonatomic) NSInteger orderID;
@property (nonatomic, strong) NSString *goodsName;
@property (nonatomic, strong) NSString *goodsHotel;
@property (nonatomic, strong) NSString *goodsPrice;
@property (nonatomic) NSInteger number;
@property (nonatomic, strong) NSString *totalPrice;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userTel;
@property (nonatomic, strong) NSString *userAddr;
@property (nonatomic, strong) NSString *userLouhao;
@property (nonatomic, strong) NSString *userQuhao;
@property (nonatomic, strong) NSString *userSushehao;
@property (nonatomic, strong) NSString *userZuoyou;
@property (nonatomic, strong) NSString *createTime;
@property (nonatomic, strong) NSString *createDay;

- (LINOrderList *)initWithDictionary:(NSDictionary *)dic;
- (LINOrderList *)initWithUser:(LINUserModel *)user goodName:(NSString *)goodName goodsHotel:(NSString *)goodsHotel
                    goodsPrice:(NSString *)goodsPrice number:(NSString *)number totalPrice:(NSString *)totalPrice
                    createTime:(NSString *)createTime createDay:(NSString *)createDay;
@end
