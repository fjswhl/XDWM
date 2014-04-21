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
#import "LINGoodModel.h"
#import "LINOrderList.h"
#import "LINRootViewController.h"
#import "MKNetworkEngine.h"
#import "MKNetworkOperation.h"
#import "MBProgressHUD.h"
@interface LINPickFoodViewController ()<MJRefreshBaseViewDelegate, NSFetchedResultsControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIScrollViewDelegate>

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

@property (strong, nonatomic) UITableView *infoTableView;

@property (nonatomic) BOOL wuwan; //0午1晚
//      下面的属性烤肉饭专用
@property (strong, nonatomic) NSArray *flavors;
@property (strong, nonatomic) NSArray *daxiao;
@property (nonatomic) NSInteger pickedDaxiao;
@property (nonatomic) NSInteger pickedFlavor;

@property (nonatomic) BOOL needSelectFlavor;
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


//          设置标题,并获取数据
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
    }else if (self.foodKindIndex == FoodHotelKRF){
        self.navigationItem.title = @"脆皮鸡烤肉饭";
    }
}

- (void)viewWillAppear:(BOOL)animated{
    NSFileManager *fm = [NSFileManager new];
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    if (![fm fileExistsAtPath:[NSString stringWithFormat:@"%@/infoDic.plist", docPath]]){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

# pragma mark - Getter
- (NSArray *)foodList{
    if (_foodList) {
        return _foodList;
    }
    _foodList = [NSArray new];
    return _foodList;
}

- (NSArray *)daxiao
{
    if (_daxiao) {
        return _daxiao;
    }
    _daxiao = @[@"大份",@"小份"];
    return _daxiao;
}

- (NSArray *)flavors{
    if (_flavors) {
        return _flavors;
    }
    _flavors = @[@"沙拉",@"土豆",@"黑椒",@"茄子",@"番茄",@"红酒",@"麻辣咖哩"];
    return _flavors;
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
            if (self.foodKindIndex == FoodHotelKRF) {
                if (self.needSelectFlavor == true) {
                    return 6;
                }
                return 5;
            }
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
//    NSLog(@"%@", image);
    [img setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", __IMGDIR__, image]]];

    UIImageView *placeHolder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PlaceHolder1.png"]];
    placeHolder.frame = CGRectMake(0, 0, 30, 30);
    placeHolder.center = img.center;
    [cell.contentView insertSubview:placeHolder belowSubview:img];
    
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
    if ([self isInfoTableView:tableView] && indexPath.row == 4) {
        return indexPath;
    }
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self isInfoTableView:tableView]) {
        if (indexPath.row == 5) {
            return 162;
        }
        return 44;
    }
    return 98;
}
//          infoTableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self isInfoTableView:tableView]) {
        NSIndexPath *addedIndexPath = [NSIndexPath indexPathForRow:5 inSection:1];
        [self.infoTableView deselectRowAtIndexPath:indexPath animated:YES];
        if (self.needSelectFlavor == NO) {
            self.needSelectFlavor = YES;
            [self.infoTableView insertRowsAtIndexPaths:@[addedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.infoTableView scrollToRowAtIndexPath:addedIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }else if (self.needSelectFlavor == YES){
            self.needSelectFlavor = NO;
            [self.infoTableView deleteRowsAtIndexPaths:@[addedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        self.infoTableView.scrollEnabled = !self.infoTableView.scrollEnabled;
    }
    return;
}

#pragma mark - ScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
        [UIView animateWithDuration:1.0f animations:^{
            self.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0, 50);
        }];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    [UIView animateWithDuration:0.7f animations:^{
        self.tabBarController.tabBar.transform = CGAffineTransformIdentity;
    }];
}

//- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
//    [UIView animateWithDuration:0.7f animations:^{
//        self.tabBarController.tabBar.transform = CGAffineTransformIdentity;
//    }];
//}
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
        
        [self deleteGoodInDatabase];
        
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
    
    if (self.foodKindIndex == 1 || self.foodKindIndex == FoodHotelKRF) {
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
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.contentView.backgroundColor = [UIColor colorWithRed:134/255.0 green:34/255.0 blue:34/255.0 alpha:1.0];
        
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
            
            UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:@[@"午", @"晚"]];
            seg.tag = 10;
            [seg addTarget:self action:@selector(chooseTime:) forControlEvents:UIControlEventValueChanged];
            seg.selectedSegmentIndex = (int)self.wuwan;
            
            seg.frame = CGRectMake(182, 0, 70, 29);
            seg.center = CGPointMake(seg.center.x, gecell.contentView.frame.size.height / 2);
            [gecell.contentView addSubview:seg];
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
            
            if (self.foodKindIndex == FoodHotelKRF) {
                stepper.enabled = NO;
            }
        }else if (indexPath.row == 4){
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"口味&饭量:";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@", self.daxiao[self.pickedDaxiao], self.flavors[self.pickedFlavor]];
            return cell;
        }else if (indexPath.row == 5){
            UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
            pickerView.frame = CGRectMake(0, 0, 320, 162);
            pickerView.dataSource = self;
            pickerView.delegate = self;
            [pickerView selectRow:self.pickedDaxiao inComponent:0 animated:YES];
            [pickerView selectRow:self.pickedFlavor inComponent:1 animated:YES];
            [gecell.contentView addSubview:pickerView];
        }
        return gecell;
    }
    return nil;
}


- (void)orderAmountChanged:(UIStepper *)sender{
    self.count = (int)sender.value;
    self.pickedGoodTotalPrice = self.count * self.pickedGoodPrice + self.addFoodCount;
    UITableView *infoTableview = (UITableView *)sender.superview.superview.superview.superview.superview;
    [infoTableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1],[NSIndexPath indexPathForRow:2 inSection:1], [NSIndexPath indexPathForRow:3 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)addFoodCountChanged:(UIStepper *)sender{
    self.addFoodCount = (int)sender.value;
    self.pickedGoodTotalPrice = self.count * self.pickedGoodPrice + self.addFoodCount;
    UITableView *infoTableview = (UITableView *)sender.superview.superview.superview.superview.superview;
    [infoTableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1],[NSIndexPath indexPathForRow:2 inSection:1], [NSIndexPath indexPathForRow:3 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)chooseTime:(UISegmentedControl *)sender{
    if (sender.selectedSegmentIndex == 0) {
        self.wuwan = false;
    }else if (sender.selectedSegmentIndex == 1){
        self.wuwan = true;
    }
}

- (void)confirmOrder{
//    LINGoodModel *aGood = self.foodList[[self.pickedGoodNumber[0] integerValue]];
    if (self.needSelectFlavor == YES) {
        self.needSelectFlavor = NO;
        [self.infoTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:5 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];

    }
    NSManagedObject *aGood = self.fetchedResultsController.fetchedObjects[[self.pickedGoodNumber[0] integerValue]];
    LINRootViewController *rootVC = (LINRootViewController *)self.tabBarController;
    LINUserModel *user = rootVC.user;
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];

    NSString *goodName = self.pickedGoodName;
//      处理脆皮鸡的订单名
    if (self.foodKindIndex == FoodHotelKRF) {
        UITableViewCell *cell = [self.infoTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:1]];
        goodName = [goodName stringByAppendingFormat:@"(%@)", cell.detailTextLabel.text];
    }
    
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
    
//      确定订单午晚
    UITableViewCell *cell = [self.infoTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    UISegmentedControl *seg = (UISegmentedControl *)[cell.contentView viewWithTag:10];
    NSString *wuwan = [seg titleForSegmentAtIndex:seg.selectedSegmentIndex];
    
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
                                 __ADDFOODNUM__:addFoodNumber,
                                 __COMEFROM__:@"iOS",
                                 __WUWAN__:wuwan,
                                 __ADDFOODNUM__:[NSString stringWithFormat:@"%li", (long)self.addFoodCount]};


    
    MKNetworkOperation *op = [self.engine operationWithPath:[NSString stringWithFormat:@"%@%@", __PHPDIR__, @"submit_order.php"] params:forPostDic httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {

 //       CXAlertView *alertView = [[CXAlertView alloc] initWithTitle:nil message:@"订单成功提交！" cancelButtonTitle:@"确定"];
        LINRootViewController *rootVC = (LINRootViewController *)self.tabBarController;
        LINRecordViewController *recordVC = rootVC.viewControllers[1];
        NSString *restring = [completedOperation responseString];
        NSLog(@"%@", restring);
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tabBarController.view animated:YES];
        if (![restring hasPrefix:@"200"]) {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = restring;
            [hud hide:YES afterDelay:1.5];
        }else{
            hud.mode = MBProgressHUDModeCustomView;
            hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
            hud.labelText = @"订单提交成功！";
            recordVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%li",(long)[recordVC.tabBarItem.badgeValue integerValue] + 1];
            [hud hide:YES afterDelay:1.0f];
        }


 //       [alertView show];
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tabBarController.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"网络不给力,请稍后重试";
        [hud hide:YES afterDelay:1.0f];
    }];
    [self.engine enqueueOperation:op];
    
}

- (void)popUpConfirmView{
    if (self.count != 0 || self.foodKindIndex == 1 || self.foodKindIndex == FoodHotelKRF) {
        self.infoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 280, 280) style:UITableViewStylePlain];
        self.infoTableView.separatorInset = UIEdgeInsetsMake(0, 5, 0, 5);
        CXAlertView *confirmOrderView = [[CXAlertView alloc] initWithTitle:@"确认订单" contentView:self.infoTableView cancelButtonTitle:nil];

        self.infoTableView.backgroundColor = [UIColor clearColor];
        self.infoTableView.delegate = self;
        self.infoTableView.dataSource = self;
        self.infoTableView.tag = 1;
        
        [confirmOrderView addButtonWithTitle:@"取消" type:CXAlertViewButtonTypeDefault handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
            [self resetOrderInfo];
            [alertView dismiss];
        }];
        [confirmOrderView addButtonWithTitle:@"确定" type:CXAlertViewButtonTypeDefault handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
            [self confirmOrder];
            [self resetOrderInfo];
            [alertView dismiss];
        }];
        confirmOrderView.buttonColor = [UIColor colorWithRed:134/255.0 green:34/255.0 blue:34/255.0 alpha:1.0f];
        confirmOrderView.tintColor = [UIColor colorWithRed:134/255.0 green:34/255.0 blue:34/255.0 alpha:1.0f];
        if (self.foodKindIndex == FoodHotelGBMF){
            confirmOrderView.contentScrollViewMaxHeight = 230;
        }else if (self.foodKindIndex == FoodHotelKRF){
            confirmOrderView.contentScrollViewMaxHeight = 270;
        }
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
    }else if (self.foodKindIndex == FoodHotelKRF){
        [request setPredicate:[NSPredicate predicateWithFormat:@"(goodHotel = '脆皮鸡烤肉饭')"]];
    }
}

- (void)deleteGoodInDatabase{
    NSArray *forDelete = [self.fetchedResultsController fetchedObjects];
    for (NSManagedObject *aObject in forDelete) {
        [self.fetchedResultsController.managedObjectContext deleteObject:aObject];
    }
    [self.fetchedResultsController.managedObjectContext save:nil];
}

#pragma mark - Pickerview Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component == 0) {
        return 2;
    }else if (component == 1){
        return 7;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (component == 0) {
        return self.daxiao[row];
    }else{
        return self.flavors[row];
    }
    return nil;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    if (component == 0) {
        return 100;
    }else if (component == 1){
        return 220;
    }
    return 0;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
//    NSString *daxiao = nil;
//    NSString *flavor = nil;
    if (component == 0) {
//        daxiao = self.daxiao[row];
        self.pickedDaxiao = row;
        //调整单价
        if (row == 0) {
            self.pickedGoodPrice = 10;
            [self needUpdateInfoTable];
        }else if (row == 1){
            self.pickedGoodPrice = 8;
            [self needUpdateInfoTable];
        }
    }else if (component == 1){
//        flavor = self.flavors[row];
        self.pickedFlavor = row;
        [self.infoTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:4 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
//    if (daxiao == nil) {
//        daxiao = self.daxiao[self.pickedDaxiao];
//    }
//    if (flavor == nil) {
//        flavor = self.flavors[self.pickedFlavor];
//    }
//   UITableViewCell *cell = [self.infoTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:1]];
//   cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@", daxiao, flavor];

//    self.pickedGoodName = [cell.detailTextLabel.text stringByAppendingString:self.pickedGoodName];
}

- (void)needUpdateInfoTable{
    self.pickedGoodTotalPrice = self.pickedGoodPrice * self.count + self.addFoodCount;
        [self.infoTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:4 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
}


@end










