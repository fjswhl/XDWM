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
#import "LINOrderList.h"
#import "MJRefresh.h"
@interface LINRecordViewController ()<UITableViewDataSource, UITableViewDelegate, MJRefreshBaseViewDelegate>
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
    [self setBarTitle];
	// Do any additional setup after loading the view.
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = self.tableview;
    header.delegate = self;
    
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = self.tableview;
    footer.delegate = self;
    
    [header beginRefreshing];
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


#pragma mark - refresh control datasource
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView{
    [self fetchOrderListWithRefreshView:refreshView];
}


#pragma mark - tableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.orderList count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.contentView.layer.borderColor = [UIColor blueColor].CGColor;
    cell.contentView.layer.borderWidth = 1.0;
    
    UILabel *hotelLabel = (UILabel *)[cell.contentView viewWithTag:1];
    UILabel *goodNameLabel = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *totalPriceLabel = (UILabel *)[cell.contentView viewWithTag:3];
    UILabel *numberLabel = (UILabel *)[cell.contentView viewWithTag:4];
    UILabel *createtimeLabel = (UILabel *)[cell.contentView viewWithTag:5];
    
    NSDictionary *aRecord = self.orderList[indexPath.row];
    hotelLabel.text = aRecord[__GOODSHOTEL__];
    goodNameLabel.text = aRecord[__GOODSNAME__];
    totalPriceLabel.text = aRecord[__TOTALPRICE__];
    numberLabel.text = aRecord[__NUMBER__];
    createtimeLabel.text = aRecord[__CREATETIME__];
    return cell;
}

#pragma mark - tableview delegate
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.orderList removeObjectAtIndex:indexPath.row];
        self.count = [self.orderList count];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
#pragma mark - interact with server method

- (void)fetchOrderListWithRefreshView:(MJRefreshBaseView *)refreshView{

    //  如果是下拉刷新，则重置一些数据
    if ([refreshView isKindOfClass:[MJRefreshHeaderView class]]) {
        self.count = 0;
        self.orderList = [NSMutableArray new];
    }
    
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
        self.count += [self.orderList count];
        [self.tableview reloadData];
        if (refreshView) {
            [refreshView endRefreshing];
        }
    } errorHandler:nil];
    [engine enqueueOperation:op];
    
}

- (void)setBarTitle{
    LINRootViewController *rootVC = (LINRootViewController *)self.tabBarController;
    self.navigationItem.title = [NSString stringWithFormat:@"%@的订单", rootVC.user.userName];
}
@end
















