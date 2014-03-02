//
//  LINRootViewController.h
//  XDWM
//
//  Created by Lin on 14-2-9.
//  Copyright (c) 2014年 WeAround. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LINUserModel.h"
@interface LINRootViewController : UITabBarController
@property (strong, nonatomic) LINUserModel *user;

- (LINUserModel *)user;
@end
