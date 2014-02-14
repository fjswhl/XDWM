//
//  SHUCommentModel.h
//  XDWM
//
//  Created by 王澍宇 on 14-2-10.
//  Copyright (c) 2014年 WeAround. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHUCommentModel : NSObject

#define __USER_NAME__  @"user_name"
#define __CONTENT__    @"content"
#define __CREATETIME__ @"create_time"

@property (nonatomic, strong) NSString *user_name;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *create_time;

@end
