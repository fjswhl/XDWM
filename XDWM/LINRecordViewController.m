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
#import "AFHTTPRequestOperationManager.h"
#import "MBProgressHUD.h"
@interface LINRecordViewController ()<UITableViewDataSource, UITableViewDelegate, MJRefreshBaseViewDelegate, UIActionSheetDelegate>
@property (nonatomic) NSInteger count;  //表示下拉刷新时当前表已存在多少条记录，非常重要！ 用于正确获取服务器发来的数据

@property (strong, nonatomic) IBOutlet UITableView *tableview;


@property (strong, nonatomic) NSString *orderIDForDelete;
@property (strong, nonatomic) NSIndexPath *indexPathForDelete;

@property (strong, nonatomic) MJRefreshHeaderView *header;
@property (strong, nonatomic) MJRefreshFooterView *footer;

//@property (strong, nonatomic) MKNetworkEngine *engine;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;

@property (strong, nonatomic) UIView *buttonView;

// for animation when cell is inserted in table
@property (strong, nonatomic) NSMutableSet *indexSet;
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

//    self.engine = [[MKNetworkEngine alloc] initWithHostName:__HOSTNAME__];
	// Do any additional setup after loading the view.
    self.header = [MJRefreshHeaderView header];
    self.header.scrollView = self.tableview;
    self.header.delegate = self;
    
    self.footer = [MJRefreshFooterView footer];
    self.footer.scrollView = self.tableview;
    self.footer.delegate = self;
    
    [self.header beginRefreshing];
}

- (void)viewWillAppear:(BOOL)animated{
    [self setBarTitle];
    [self.tableview reloadData];
    
    [self addRefreshButton];

}

- (void)viewWillDisappear:(BOOL)animated{
    [self removeRefreshButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [self.header free];
    [self.footer free];
}
- (NSMutableArray *)orderList{
    if (!_orderList) {
        _orderList = [NSMutableArray new];
    }
    return _orderList;
}

- (NSMutableSet *)indexSet{
    if (!_indexSet) {
        _indexSet = [NSMutableSet new];
    }
    return _indexSet;
}

- (AFHTTPRequestOperationManager *)manager{
    if (!_manager) {
        id appdelegate = [[UIApplication sharedApplication] delegate];
        _manager = [appdelegate manager];
    }
    return _manager;
}


#pragma mark - refresh control delegate
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView{
    if ([refreshView isKindOfClass:[MJRefreshHeaderView class]]) {
        [self.indexSet removeAllObjects];
    }
    [self fetchOrderListWithRefreshView:refreshView];
}

- (void)refreshViewEndRefreshing:(MJRefreshBaseView *)refreshView{
    LINRootViewController *rootVC = (LINRootViewController *)self.tabBarController;
    LINRecordViewController *recordVC = rootVC.viewControllers[1];
    
    recordVC.tabBarItem.badgeValue = nil;

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
    cell.contentView.layer.borderColor = [UIColor colorWithRed:134/255.0 green:34/255.0 blue:34/255.0 alpha:1.0].CGColor;
    cell.contentView.layer.borderWidth = 1.0;
    
    UILabel *hotelLabel = (UILabel *)[cell.contentView viewWithTag:1];
    UILabel *goodNameLabel = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *totalPriceLabel = (UILabel *)[cell.contentView viewWithTag:3];
    UILabel *numberLabel = (UILabel *)[cell.contentView viewWithTag:4];
    UILabel *createtimeLabel = (UILabel *)[cell.contentView viewWithTag:5];
    UILabel *orderlistIDLabel = (UILabel *)[cell.contentView viewWithTag:6];
    
    NSDictionary *aRecord = self.orderList[indexPath.row];
    hotelLabel.text = aRecord[__GOODSHOTEL__];
    goodNameLabel.text = aRecord[__GOODSNAME__];
    totalPriceLabel.text = [aRecord[__TOTALPRICE__] stringByAppendingString:@"元"];
    numberLabel.text = [NSString stringWithFormat:@"数量：%@", aRecord[__NUMBER__]] ;
    createtimeLabel.text = aRecord[__CREATETIME__];
    orderlistIDLabel.text = [NSString stringWithFormat:@"No.%@", aRecord[__ORDERLISTID__]];
    return cell;
}

#pragma mark - tableview delegate
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:5];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *today = [dateFormatter stringFromDate:[NSDate date]];
    
    if ([today isEqualToString:[timeLabel.text substringToIndex:10]]) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [self.orderList removeObjectAtIndex:indexPath.row];
//        self.count = [self.orderList count];
        
        //  弹出确认删除的ActionSheet
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"确认删除这条订单吗?" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles: nil];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UILabel *idLabel = (UILabel *)[cell.contentView viewWithTag:6];
        self.orderIDForDelete = [idLabel.text substringFromIndex:3];
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
//        [self updateRemoteDatabaseWithOrderID: [idLabel.text substringFromIndex:3]];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        self.indexPathForDelete = indexPath;
    }
}

//      若用户确认删除，则更新数据库
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self.orderList removeObjectAtIndex:self.indexPathForDelete.row];
        self.count = [self.orderList count];
        [self.tableview deleteRowsAtIndexPaths:@[self.indexPathForDelete] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self updateRemoteDatabaseWithOrderID:self.orderIDForDelete];
        [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![self.indexSet containsObject:indexPath]) {
        [self.indexSet addObject:indexPath];
        UIView *mainView = cell.contentView;
        mainView.transform = CGAffineTransformMakeRotation(-M_PI_2 / 3);
        mainView.transform = CGAffineTransformTranslate(mainView.transform, -500, 200);
        mainView.alpha = 0.5;
        [UIView animateWithDuration:0.7 animations:^{
            mainView.transform = CGAffineTransformIdentity;
            mainView.alpha = 1;
        }];
    }
}
#pragma mark - interact with server method

- (void)fetchOrderListWithRefreshView:(MJRefreshBaseView *)refreshView{

    //  如果是下拉刷新，则重置一些数据
    if ([refreshView isKindOfClass:[MJRefreshHeaderView class]]) {
        self.count = 0;
//        self.orderList = [NSMutableArray new];
    }
    
    LINRootViewController *rootVC = (LINRootViewController *)self.tabBarController;
    NSDictionary *dicForPost = @{__USERNAME__:rootVC.user.userName,
                                 @"key":[NSString stringWithFormat:@"%li", (long)self.count]};
    
//    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:__HOSTNAME__];
//    MKNetworkOperation  *op = [self.engine operationWithPath:[NSString stringWithFormat:@"%@%@",__PHPDIR__,@"fetch_orderlist.php"] params:dicForPost httpMethod:@"POST"];
    
    [self.manager POST:[NSString stringWithFormat:@"%@%@", __DIR__,@"fetch_orderlist.php"]  parameters:dicForPost success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSString *st = responseObject;
//        NSDictionary *recordsInfo = [NSJSONSerialization JSONObjectWithData:[st dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        NSDictionary *recordsInfo = responseObject;
        
        NSArray *keys = [[recordsInfo allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSInteger in1 = [(NSString *)obj1 integerValue];
            NSInteger in2 = [(NSString *)obj2 integerValue];
            if (in1 > in2) {
                return true;
            }
            return false;
        }];
        
        //      如果是下拉刷新，则重置一些数据
        if ([refreshView isKindOfClass:[MJRefreshHeaderView class]]) {
//            self.count = 0;
            self.orderList = [NSMutableArray new];
        }
        
        for (NSString *key in keys) {
            NSDictionary *aRecord = recordsInfo[key];
            [self.orderList addObject:aRecord];
        }
        self.count += [keys count];
        if (refreshView) {
            [refreshView endRefreshing];
        }
        [self.tableview reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (refreshView) {
            [refreshView endRefreshing];
        }
    }];
//    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
////        NSLog(@"%@", [completedOperation responseString]);
//        NSString *st = [completedOperation responseString];
//        NSDictionary *recordsInfo = [NSJSONSerialization JSONObjectWithData:[st dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
//        
//        NSArray *keys = [[recordsInfo allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//            NSInteger in1 = [(NSString *)obj1 integerValue];
//            NSInteger in2 = [(NSString *)obj2 integerValue];
//            if (in1 > in2) {
//                return true;
//            }
//            return false;
//        }];
//
//        for (NSString *key in keys) {
//            NSDictionary *aRecord = recordsInfo[key];
//            [self.orderList addObject:aRecord];
//        }
//        self.count += [keys count];
//        if (refreshView) {
//            [refreshView endRefreshing];
//        }
//        [self.tableview reloadData];
//
//    } errorHandler:nil];
//    [self.engine enqueueOperation:op];
    
}

- (void)updateRemoteDatabaseWithOrderID:(NSString *)orderID{
    NSDictionary *dicForPost = @{__ORDERLISTID__: orderID};
//    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:__HOSTNAME__];
//    MKNetworkOperation *op = [engine operationWithPath:[NSString stringWithFormat:@"%@%@", __PHPDIR__, @"delete_order.php"] params:dicForPost httpMethod:@"POST"];
//    [engine enqueueOperation:op];
    [self.manager POST:[NSString stringWithFormat:@"%@%@", __DIR__,@"delete_order.php"] parameters:dicForPost success:nil failure:nil];
}
- (void)setBarTitle{
    LINRootViewController *rootVC = (LINRootViewController *)self.tabBarController;
    self.navigationItem.title = [NSString stringWithFormat:@"%@的订单", rootVC.user.userName];
}

#pragma mark - add buttonview

- (void)addRefreshButton{
    self.buttonView = [[UIView alloc] initWithFrame:CGRectMake(72, 518, 50, 50)];
    self.buttonView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refresh)];
    [self.buttonView addGestureRecognizer:tapGestureRecognizer];
    
    [self.tabBarController.view addSubview:self.buttonView];
}

- (void)removeRefreshButton{
    [self.buttonView removeFromSuperview];
}

- (void)refresh{
    [self.header beginRefreshing];
}
@end
















