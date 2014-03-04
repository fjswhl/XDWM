//
//  LINPickFoodViewController.m
//  XDWM
//
//  Created by Lin on 14-2-5.
//  Copyright (c) 2014年 WeAround. All rights reserved.
//

#import "LINPickFoodViewController.h"
#import "UIImageView+WebCache.h"
#import "ADDRMACRO.h"
#import "CXAlertView.h"
#import "LINRecordViewController.h"
#import "MJRefresh.h"
#import <CoreData/CoreData.h>
@interface LINPickFoodViewController ()<MJRefreshBaseViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic)       NSInteger count;
@property (nonatomic)       NSInteger addFoodCount;
@property (nonatomic)       CGFloat pickedGoodPrice;
@property (nonatomic)       CGFloat pickedGoodTotalPrice;
@property (nonatomic, strong) NSMutableArray *pickedGoodNumber;
@property (nonatomic, strong) NSString *pickedGoodName;
@property (nonatomic, strong) NSString *createTime;
@property (nonatomic, strong) NSString *createDay;

//@property (nonatomic)       NSInteger badgeNumber; //   for record vc's tab bar item's badge
@property (nonatomic) NSInteger flag;////
@property (nonatomic, strong) MJRefreshHeaderView *header;
@property (nonatomic, strong) MKNetworkEngine *engine;

//      CoreData Stuff
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic) BOOL needReflesh;

@end

@implementation LINPickFoodViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization

    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];


    
    self.foodList = [NSMutableArray new];
    self.engine = [[MKNetworkEngine alloc] initWithHostName:__HOSTNAME__];

    self.header = [MJRefreshHeaderView header];
    self.header.delegate = self;
    self.header.scrollView = self.tableView;
//    [self.header beginRefreshing];
    [self fetchGoodsInfoWithRefreshView:nil];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (self.foodKindIndex == 2) {
        self.navigationItem.title = @"绿茉莉套餐";
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
        self.navigationItem.titleView = contentView;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textColor = [UIColor whiteColor];
        label.tag = 1;
        label.text = @"已选:0/3";
        label.font = [UIFont fontWithName:@"Helvetica Neue" size:13.0];
        [label sizeToFit];
        label.center = CGPointMake(200, 23);
        [contentView addSubview:label];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
        title.textColor = [UIColor whiteColor];
        title.text = @"绿茉莉套餐";
        [title sizeToFit];
        title.center = CGPointMake(110, 23);
        [contentView addSubview:title];
        
        UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleBordered target:self action:@selector(popUpConfirmView)];
        self.navigationItem.rightBarButtonItem = rightBarButton;
    }else if (self.foodKindIndex == 1){
        self.navigationItem.title = @"锅巴米饭";
    }
    

}

- (void)viewWillAppear:(BOOL)animated{
    NSFileManager *fm = [NSFileManager new];
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    if (![fm fileExistsAtPath:[NSString stringWithFormat:@"%@/infoDic.plist", docPath]]){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSArray *)foodList{
    if (_foodList) {
        return _foodList;
    }
    _foodList = [NSArray new];
    return _foodList;
}

- (void)dealloc{
    [self.header free];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)pickedGoodNumber{
    if (!_pickedGoodNumber) {
        _pickedGoodNumber = [[NSMutableArray alloc] init];
        return _pickedGoodNumber;
    }
    return _pickedGoodNumber;
}

#pragma mark - refresh control delegate
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView{
    self.needReflesh = TRUE;
    [self fetchGoodsInfoWithRefreshView:refreshView];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self isInfoTableView:tableView]) {
        return 2;
    }
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self isInfoTableView:tableView]) {
        if (section == 0) {
            return 1;
        }else if (section == 1){
            return 4;
        }
    }
    // Return the number of rows in the section.
  //  return [self.foodList count];
    return [[self.fetchedResultsController fetchedObjects] count];
}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 96;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isInfoTableView:tableView]) {
        return [self infoTableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:4];
    label.layer.borderColor = [UIColor redColor].CGColor;
    label.layer.borderWidth = 1.5;
    label.layer.cornerRadius = 6;
    //如果是绿茉莉 更改label的名称
    if (self.foodKindIndex == 2) {
        label.text = @"加入菜单";
    }
    
    UIImageView *img = (UIImageView *)[cell.contentView viewWithTag:1];
    UILabel *title = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *price = (UILabel *)[cell.contentView viewWithTag:3];
    
//    LINGoodModel *good = self.foodList[indexPath.row];
//    NSString *imgName = [good goodImg];
//    [img setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", __IMGDIR__, imgName]]];
//    title.text = good.goodName;
//    price.text = good.goodPrice;
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *image = [object valueForKey:@"goodImg"];
    [img setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", __IMGDIR__, image]]];
    title.text = [object valueForKey:@"goodName"];
    price.text = [object valueForKey:@"goodPrice"];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buy:)];
    [label addGestureRecognizer:tapGestureRecognizer];
    
    if (indexPath.row % 2 == 0) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:255/255.0 green:248/255.0 blue:220/255.0 alpha:1.0];
    }
    if (indexPath.row % 2 == 1) {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}


#pragma mark - tableview delegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ([self isInfoTableView:tableView]) {
        if (section == 1) {
            return 5;
        }
        return 0;
    }
    return 0;
}

#pragma mark - interaction method

- (void)fetchGoodsInfoWithRefreshView:(MJRefreshBaseView *)refreshView{
    if (self.needReflesh == false) {
        if ([self.fetchedResultsController.fetchedObjects count] > 0) {
            [refreshView endRefreshing];
            return;
        }
    }
    
    //      转动HUD
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"正在努力加载...";
    
    [self deleteGoodInDatabase];
    NSString *index = [NSString stringWithFormat:@"%li", (long)self.foodKindIndex];
    NSDictionary *infoDic = @{@"key": index};
    
    MKNetworkOperation *op = [self.engine operationWithPath:[NSString stringWithFormat:@"%@%@", __PHPDIR__, @"fetchgood.php"] params:infoDic httpMethod:@"POST"];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
//        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//        NSData *reData = [completedOperation responseData];
//        NSString *st = [[NSString alloc] initWithData:reData encoding:enc];
        NSString *st = [completedOperation responseString];
        NSDictionary *goodInfo = [NSJSONSerialization JSONObjectWithData:[st dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        
        //下面将获取的数据写入模型
        NSArray *keys = [[goodInfo allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSInteger in1 = [(NSString *)obj1 integerValue];
            NSInteger in2 = [(NSString *)obj2 integerValue];
            if (in1 > in2) {
                return true;
            }
            return false;
        }];
        
        for (NSString *key in keys) {
            NSDictionary *aGood = [goodInfo objectForKey:key];
            LINGoodModel *aGoodModel = [[LINGoodModel alloc] initWithDictionary:aGood];
 //           [self.foodList addObject:aGoodModel];
            
            [self insertNewGood:aGoodModel];
            
        }
        [refreshView endRefreshing];
        


        [self.fetchedResultsController performFetch:nil];
        [hud hide:YES];
        [self.tableView reloadData];
    } errorHandler:nil];
    
    [self.engine enqueueOperation:op];
    

}

- (void)buy:(UITapGestureRecognizer *)sender{
    UILabel *v = (UILabel *)sender.view;
    
    UITableViewCell *correspondCell = (UITableViewCell *)v.superview.superview.superview;
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:correspondCell];

    
//    LINGoodModel *pickedGood = self.foodList[cellIndexPath.row];
    NSManagedObject *pickedGood = self.fetchedResultsController.fetchedObjects[cellIndexPath.row];
    
    self.pickedGoodName =  [pickedGood valueForKey:@"goodName"];
    self.pickedGoodPrice = [(NSString *)[pickedGood valueForKey:@"goodPrice"] floatValue];
    self.pickedGoodTotalPrice = self.pickedGoodPrice;
    
    if (self.foodKindIndex == 1) {
        self.pickedGoodNumber = [NSMutableArray arrayWithObjects:@(cellIndexPath.row), nil];
        [self popUpConfirmView];
    }else if (self.foodKindIndex == 2){
        if (self.count < 3) {
            self.count += 1;
            
            //              做一些动画
            UIGraphicsBeginImageContext(CGSizeMake(139, 97));
            UIImageView *img = (UIImageView *)[correspondCell viewWithTag:1];
            [img.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *im = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            CGRect rect = [correspondCell.contentView convertRect:img.frame toView:self.tabBarController.view];
            UIImageView *testView = [[UIImageView alloc] initWithImage:im];
            testView.frame = rect;
            [self.tabBarController.view addSubview:testView];
            
            [UIView animateWithDuration:0.7 animations:^{
                CGRect toRect = CGRectMake(250, 40, 0, 0);
                testView.transform = CGAffineTransformMakeRotation(M_PI);
                testView.frame = toRect;
            }];
            [self updateNavBar];
            [self.pickedGoodNumber addObject:[NSNumber numberWithInteger:cellIndexPath.row]];
        }else{
            CXAlertView *alertView = [[CXAlertView alloc] initWithTitle:@"最多只能选3种菜" message:@"需要重置菜单的话请点击重置" cancelButtonTitle:@"取消"];
            [alertView addButtonWithTitle:@"重置" type:CXAlertViewButtonTypeDefault handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                [self resetOrderInfo];
                [alertView dismiss];
            }];
            [alertView show];
        }
    }
}

- (void)updateNavBar{
    UILabel *label = (UILabel *)[self.navigationItem.titleView viewWithTag:1];
    label.text = [NSString  stringWithFormat:@"已选:%li/3", (long)self.count];
}
- (BOOL)isInfoTableView:(UITableView *)tableview{
    if (tableview.tag == 1) {
        return YES;
    }
    return NO;
}
- (UITableViewCell *)infoTableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *gecell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (indexPath.section == 0 && indexPath.row == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        LINRootViewController *rootVC = (LINRootViewController *)self.tabBarController;
        LINUserModel *user = rootVC.user;
        NSString *username = user.userName;
        NSString *userTel = user.userTel;
        NSString *userAddr = user.userAddr;
        NSString *userLouhao = user.userLouhao;
        NSString *userQuhao = user.userQuhao;
        NSString *userSushehao = user.userSushehao;
        NSString *userZuoyou = user.userZuoyou;
        cell.textLabel.text = [NSString stringWithFormat: @"收货人:%@   %@", username, userTel];
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:16];
        cell.detailTextLabel.text = [NSString stringWithFormat: @"地址：%@%@号楼%@%@%@室",userAddr, userLouhao,userQuhao,userSushehao,userZuoyou];
        cell.contentView.backgroundColor = [UIColor colorWithRed:135/255.0 green:206/255.0 blue:250/255.0 alpha:1.0];
        
        return cell;
    }else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            NSString *firstGoodName = [self.fetchedResultsController.fetchedObjects[[self.pickedGoodNumber[0] integerValue]] goodName];
            gecell.textLabel.text = [NSString stringWithFormat:@"菜名：%@", firstGoodName];
            if ([self.pickedGoodNumber count] == 3) {
                gecell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
            }
            if ([self.pickedGoodNumber count] > 1) {
                for (NSInteger i = 1; i < [self.pickedGoodNumber count]; i++) {
                    NSString *aGoodName = [self.fetchedResultsController.fetchedObjects[[self.pickedGoodNumber[i] integerValue]] goodName];
                    gecell.textLabel.text = [gecell.textLabel.text stringByAppendingFormat:@",%@", aGoodName];
                }
            }
            self.pickedGoodName = [gecell.textLabel.text stringByReplacingOccurrencesOfString:@"菜名：" withString:@""];
        }else if (indexPath.row == 1){
            gecell.textLabel.text = [NSString stringWithFormat: @"单价：%.2f元", self.pickedGoodPrice];
            
            UILabel *totalPriceLabel = [UILabel new];
            totalPriceLabel.text = [NSString stringWithFormat: @"总价：%.2f元", self.pickedGoodTotalPrice];
            [totalPriceLabel sizeToFit];
            totalPriceLabel.center = CGPointMake(gecell.textLabel.center.x + 200, gecell.contentView.frame.size.height/2);
            [gecell.contentView addSubview:totalPriceLabel];
        }else if (indexPath.row == 2){
            if (self.count == 0 || (self.foodKindIndex == 2 && self.flag == 0)) {
                self.count = 1;
                self.flag = 1;
            }
    
            UIStepper *stepper = [[UIStepper alloc] initWithFrame:CGRectMake(170, 0, 70, 29)];
            stepper.value = self.count;
            stepper.center = CGPointMake(stepper.center.x, gecell.contentView.frame.size.height / 2);
            stepper.minimumValue = 1;
            stepper.maximumValue = 100;
            stepper.stepValue = 1;
            stepper.continuous = YES;
            stepper.autorepeat = YES;
        
            stepper.transform = CGAffineTransformMakeScale(0.8, 1);
            
            [stepper addTarget:self action:@selector(orderAmountChanged:) forControlEvents:UIControlEventValueChanged];
            gecell.textLabel.text = [NSString stringWithFormat:@"购买数量： %li份", (long)self.count];
            [gecell.contentView addSubview:stepper];
            
        }else if (indexPath.row == 3){
            UIStepper *stepper = [[UIStepper alloc] initWithFrame:CGRectMake(170, 0, 70, 29)];
            stepper.value = self.addFoodCount;
            stepper.center = CGPointMake(stepper.center.x, gecell.contentView.frame.size.height / 2);
            stepper.minimumValue = 0;
            stepper.maximumValue = 10;
            stepper.stepValue = 1;
            stepper.continuous = YES;
            stepper.autorepeat = YES;
            stepper.transform = CGAffineTransformMakeScale(0.8, 1);
            [stepper addTarget:self action:@selector(addFoodCountChanged:) forControlEvents:UIControlEventValueChanged];
            gecell.textLabel.text = [NSString stringWithFormat:@"加饭： %li份", (long)self.addFoodCount];
            [gecell.contentView addSubview:stepper];
        }
        return gecell;
    }
    return nil;
}


- (void)orderAmountChanged:(UIStepper *)sender{
    self.count = (int)sender.value;
    self.pickedGoodTotalPrice = self.count * self.pickedGoodPrice;
    UITableView *infoTableview = (UITableView *)sender.superview.superview.superview.superview.superview;
    [infoTableview reloadData];
}

- (void)addFoodCountChanged:(UIStepper *)sender{
    self.addFoodCount = (int)sender.value;
    UITableView *infoTableview = (UITableView *)sender.superview.superview.superview.superview.superview;
    [infoTableview reloadData];
}

- (void)confirmOrder{
//    LINGoodModel *aGood = self.foodList[[self.pickedGoodNumber[0] integerValue]];
    NSManagedObject *aGood = self.fetchedResultsController.fetchedObjects[[self.pickedGoodNumber[0] integerValue]];
    LINRootViewController *rootVC = (LINRootViewController *)self.tabBarController;
    LINUserModel *user = rootVC.user;
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];

    NSString *goodName = self.pickedGoodName;
    NSString *goodsHotel = [[aGood valueForKey:@"goodHotel"]  stringByAppendingString:@"(来自iOS客户端)"];
    NSString *goodsPrice = [aGood valueForKey:@"goodPrice"];
    NSString *number = [NSString stringWithFormat:@"%li", (long)self.count];
    NSString *totalPrice = [NSString stringWithFormat:@"%.2lf", self.pickedGoodTotalPrice];
    NSString *username = user.userName;
    NSString *userTel = user.userTel;
    NSString *userAddr = user.userAddr;
    NSString *userLouhao = user.userLouhao;
    NSString *userQuhao = user.userQuhao;
    NSString *userSushehao = user.userSushehao;
    NSString *userZuoyou = user.userZuoyou;
    
    NSString *addFoodNumber = [NSString stringWithFormat:@"%li", (long)self.addFoodCount];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *createTime = [dateFormatter stringFromDate:today];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *createDay = [dateFormatter stringFromDate:today];
    
    NSDictionary *forPostDic = @{__GOODNAME__:goodName,
                                 __GOODHOTEL__:goodsHotel,
                                 __GOODPRICE__:goodsPrice,
                                 __GOODPRICE__:goodsPrice,
                                 __NUMBER__:number,
                                 __TOTALPRICE__:totalPrice,
                                 __USERNAME__:username,
                                 __USERTEL__:userTel,
                                 __USERADDR__:userAddr,
                                 __USERLOUHAO__:userLouhao,
                                 __USERQUHAO__:userQuhao,
                                 __USERSUSHEHAO__:userSushehao,
                                 __USERZUOYOU__:userZuoyou,
                                 __CREATETIME__:createTime,
                                 __CREATEDAY__:createDay,
                                 __ADDFOODNUM__:addFoodNumber};

    MKNetworkOperation *op = [self.engine operationWithPath:[NSString stringWithFormat:@"%@%@", __PHPDIR__, @"submit_order.php"] params:forPostDic httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSLog(@"%@", [completedOperation responseString]);
 //       CXAlertView *alertView = [[CXAlertView alloc] initWithTitle:nil message:@"订单成功提交！" cancelButtonTitle:@"确定"];
        LINRootViewController *rootVC = (LINRootViewController *)self.tabBarController;
        LINRecordViewController *recordVC = rootVC.viewControllers[1];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tabBarController.view animated:YES];
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        hud.labelText = @"订单提交成功！";
        [hud hide:YES afterDelay:1];
        recordVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%li",(long)[recordVC.tabBarItem.badgeValue integerValue] + 1];
 //       [alertView show];
    } errorHandler:nil];
    [self.engine enqueueOperation:op];
    
}

- (void)popUpConfirmView{
    if (self.count != 0 || self.foodKindIndex == 1) {
        UITableView *infoView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 280, 180) style:UITableViewStylePlain];
        infoView.separatorInset = UIEdgeInsetsMake(0, 5, 0, 5);
        CXAlertView *confirmOrderView = [[CXAlertView alloc] initWithTitle:@"确认订单" contentView:infoView cancelButtonTitle:nil];
        
        infoView.backgroundColor = [UIColor clearColor];
        infoView.delegate = self;
        infoView.dataSource = self;
        infoView.tag = 1;
        
        [confirmOrderView addButtonWithTitle:@"取消" type:CXAlertViewButtonTypeDefault handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
            [self resetOrderInfo];
            [alertView dismiss];
        }];
        [confirmOrderView addButtonWithTitle:@"确定" type:CXAlertViewButtonTypeDefault handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
            [self confirmOrder];
            [self resetOrderInfo];
            [alertView dismiss];
        }];
        [confirmOrderView show];
    }

}

- (void)resetOrderInfo{
    self.count = 0;
    self.addFoodCount = 0;
    self.flag = 0;
    self.pickedGoodNumber = [NSMutableArray new];
    [self updateNavBar];
}

#pragma  mark - Core Data Related Methods
- (NSFetchedResultsController *)fetchedResultsController{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Good"];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"goodID" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    [self updateFetchRequest:fetchRequest];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"fetchrequest executed failed %@,%@", error, [error userInfo]);
    }
    return _fetchedResultsController;
}

- (void)insertNewGood:(LINGoodModel *)good{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newGood = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    [newGood setValue:good.goodID forKey:@"goodID"];
    [newGood setValue:good.goodCreateTime forKey:@"goodCreateTime"];
    [newGood setValue:good.goodHotel forKey:@"goodHotel"];
    [newGood setValue:good.goodImg forKey:@"goodImg"];
    [newGood setValue:good.goodIntroduce forKey:@"goodIntroduce"];
    [newGood setValue:good.goodName forKey:@"goodName"];
    [newGood setValue:good.goodPrice forKey:@"goodPrice"];
    
    if (![context save:nil]) {
        NSLog(@"context save failed in LINPickFoodVC");
    }
}

- (void)updateFetchRequest:(NSFetchRequest *)request{
    if (self.foodKindIndex == FoodHotelGBMF) {
//        [self.fetchedResultsController.fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(goodHotel = '锅巴米饭')"]];
        [request setPredicate:[NSPredicate predicateWithFormat:@"(goodHotel = '锅巴米饭')"]];
    }else if (self.foodKindIndex == FoodHotelLML){
//        [self.fetchedResultsController.fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(goodHotel = '绿茉莉套餐')"]];
        [request setPredicate:[NSPredicate predicateWithFormat:@"(goodHotel = '绿茉莉套餐')"]];
    }
}

- (void)deleteGoodInDatabase{
    NSArray *forDelete = [self.fetchedResultsController fetchedObjects];
    for (NSManagedObject *aObject in forDelete) {
        [self.fetchedResultsController.managedObjectContext deleteObject:aObject];
    }
    [self.fetchedResultsController.managedObjectContext save:nil];
}
@end




















