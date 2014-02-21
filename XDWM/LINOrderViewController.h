//
//  LINOrderViewController.h
//  XDWM
//
//  Created by Lin on 14-2-4.
//  Copyright (c) 2014年 WeAround. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHUSignViewController.h"
@interface LINOrderViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
- (void)fetchUserInfoToRootVC;
@end
