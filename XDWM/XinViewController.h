//
//  XinViewController.h
//  Inform
//
//  Created by GX on 14-2-15.
//  Copyright (c) 2014年 WHG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"

@interface XinViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MJRefreshBaseViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView1;

@end
