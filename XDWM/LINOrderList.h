//
//  LINOrderList.h
//  XDWM
//
//  Created by Lin on 14-2-8.
//  Copyright (c) 2014年 WeAround. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LINOrderList : NSObject
@property (nonatomic) NSInteger orderID;
@property (nonatomic, strong) NSString *goodsName;
@property (nonatomic, strong) NSString *goodsHotel;
@property (nonatomic, strong) NSString *goodsPrice;
@property (nonatomic) NSInteger number;
@property (nonatomic, strong) NSString *totalPrice;
@property (nonatomic, strong) NSString *userName;
@end
