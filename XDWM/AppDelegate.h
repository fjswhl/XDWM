//
//  AppDelegate.h
//  XDWM
//
//  Created by Lin on 14-2-4.
//  Copyright (c) 2014年 WeAround. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperationManager.h"
#import "MKNetworkEngine.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, UIViewControllerAnimatedTransitioning>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MKNetworkEngine *engine;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@end
