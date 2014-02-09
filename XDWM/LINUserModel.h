//
//  LINUserModel.h
//  XDWM
//
//  Created by Lin on 14-2-8.
//  Copyright (c) 2014年 WeAround. All rights reserved.
//

#import <Foundation/Foundation.h>

#define __USERNAME__        @"username"
#define __PASSWORD__        @"password"
#define __USERSEX__         @"user_sex"
#define __USEREMAIL__       @"user_email"
#define __USERTEL__         @"user_tel"
#define __USERADDR__        @"user_add"
#define __USERLOUHAO__      @"user_louhao"
#define __USERSUSHEHAO__    @"user_sushehao"
#define __USERQUHAO__       @"user_quhao"
#define __USERZUOYOU__      @"user_zuoyou"
#define __USERPOINT__       @"user_point"

@interface LINUserModel : NSObject

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userPassword;
@property (nonatomic, strong) NSString *userSex;
@property (nonatomic, strong) NSString *userEmail;
@property (nonatomic, strong) NSString *userTel;
@property (nonatomic, strong) NSString *userAddr;
@property (nonatomic, strong) NSString *userLouhao;
@property (nonatomic, strong) NSString *userQuhao;
@property (nonatomic, strong) NSString *userSushehao;
@property (nonatomic, strong) NSString *userZuoyou;
@property (nonatomic, strong) NSString *userPoint;

@end
