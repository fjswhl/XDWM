//
//  LINPickFoodViewController.h
//  XDWM
//
//  Created by Lin on 14-2-5.
//  Copyright (c) 2014年 WeAround. All rights reserved.
//

#import <UIKit/UIKit.h>


#define FoodHotelGBMF 1
#define FoodHotelLML 2
#define FoodHotelKRF 3
@interface LINPickFoodViewController : UITableViewController

@property (strong, nonatomic) NSArray *foodList;
@property (nonatomic) NSInteger foodKindIndex;

@end
