//
//  LINRecordViewController.m
//  XDWM
//
//  Created by Lin on 14-2-15.
//  Copyright (c) 2014年 WeAround. All rights reserved.
//

#import "LINRecordViewController.h"
#import "MKNetworkEngine.h"
#import "MKNetworkOperation.h"
#import "ADDRMACRO.h"
#import "LINRootViewController.h"

@interface LINRecordViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) NSInteger count;  //表示下拉刷新时当前表已存在多少条记录

@property (strong, nonatomic) IBOutlet UITableView *tableview;

@property (strong, nonatomic) NSMutableArray *orderList;

@end

@implementation LINRecordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self fetchOrderList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)orderList{
    if (!_orderList) {
        _orderList = [NSMutableArray new];
    }
    return _orderList;
}
#pragma mark - tableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.orderList count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

#pragma mark - interact with server method

- (void)fetchOrderList{
    LINRootViewController *rootVC = (LINRootViewController *)self.tabBarController;
    NSDictionary *dicForPost = @{__USERNAME__:rootVC.user.userName,
                                 @"key":[NSString stringWithFormat:@"%i", self.count]};
    
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:__HOSTNAME__];
    MKNetworkOperation  *op = [engine operationWithPath:[NSString stringWithFormat:@"%@%@",__PHPDIR__,@"fetch_orderlist.php"] params:dicForPost httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSLog(@"%@", [completedOperation responseString]);
        NSString *st = [completedOperation responseString];
        NSDictionary *recordsInfo = [NSJSONSerialization JSONObjectWithData:[st dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        
        NSArray *keys = [[recordsInfo allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSInteger in1 = [(NSString *)obj1 integerValue];
            NSInteger in2 = [(NSString *)obj2 integerValue];
            if (in1 > in2) {
                return true;
            }
            return false;
        }];
        
        for (NSString *key in keys) {
            NSDictionary *aRecord = recordsInfo[key];
            [self.orderList addObject:aRecord];
        }
        [self.tableview reloadData];
    } errorHandler:nil];
    [engine enqueueOperation:op];
    
}
@end
















