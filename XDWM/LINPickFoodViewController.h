//
//  LINPickFoodViewController.h
//  XDWM
//
//  Created by Lin on 14-2-5.
//  Copyright (c) 2014年 WeAround. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LINGoodModel.h"
#import "LINOrderList.h"
#import "LINRootViewController.h"
#import "MKNetworkEngine.h"
#import "MKNetworkOperation.h"
@interface LINPickFoodViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *foodList;
@property (nonatomic) NSInteger foodKindIndex;

@end
