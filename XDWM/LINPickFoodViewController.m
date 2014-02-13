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



@interface LINPickFoodViewController ()
@property (nonatomic)       NSInteger count;
@property (nonatomic)       CGFloat pickedGoodPrice;
@property (nonatomic)       CGFloat pickedGoodTotalPrice;
@property (nonatomic, strong) NSArray *pickedGoodNumber;
@property (nonatomic, strong) NSString *pickedGoodName;
@property (nonatomic, strong) NSString *createTime;
@property (nonatomic, strong) NSString *createDay;
//@property (nonatomic, strong) NSString *pickedGoodPrice;
//@property (nonatomic, strong) NSString *pickedGoodTotalPrice;
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
    self.foodList = [NSMutableArray new];
    [self fetchGoodsInfo];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            return 3;
        }
    }
    // Return the number of rows in the section.
    return [self.foodList count];
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
    
    UIImageView *img = (UIImageView *)[cell.contentView viewWithTag:1];
    UILabel *title = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *price = (UILabel *)[cell.contentView viewWithTag:3];
    
    LINGoodModel *good = self.foodList[indexPath.row];
    NSString *imgName = [good goodImg];
    [img setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", __IMGDIR__, imgName]]];
    title.text = good.goodName;
    price.text = good.goodPrice;
    
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

- (void)fetchGoodsInfo{
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:__HOSTNAME__];
    NSString *index = [NSString stringWithFormat:@"%i", self.foodKindIndex];
    NSDictionary *infoDic = @{@"key": index};
    
    MKNetworkOperation *op = [engine operationWithPath:[NSString stringWithFormat:@"%@%@", __PHPDIR__, @"fetchgood.php"] params:infoDic httpMethod:@"POST"];
    
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
            NSLog(@"%@", key);
            NSDictionary *aGood = [goodInfo objectForKey:key];
            LINGoodModel *aGoodModel = [[LINGoodModel alloc] initWithDictionary:aGood];
            [self.foodList addObject:aGoodModel];
        }
        [self.tableView reloadData];
    } errorHandler:nil];
    
    [engine enqueueOperation:op];
    

}

- (void)buy:(UITapGestureRecognizer *)sender{
    UILabel *v = (UILabel *)sender.view;
    
    UITableViewCell *correspondCell = (UITableViewCell *)v.superview.superview.superview;
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:correspondCell];
    self.pickedGoodNumber = [NSArray arrayWithObjects:@(cellIndexPath.row), nil];
    
    LINGoodModel *pickedGood = self.foodList[cellIndexPath.row];
    self.pickedGoodName =   pickedGood.goodName;
    self.pickedGoodPrice = [pickedGood.goodPrice floatValue];
    self.pickedGoodTotalPrice = self.pickedGoodPrice;

    UITableView *infoView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 280, 180) style:UITableViewStylePlain];
    infoView.separatorInset = UIEdgeInsetsMake(0, 5, 0, 5);
    CXAlertView *confirmOrderView = [[CXAlertView alloc] initWithTitle:@"确认订单" contentView:infoView cancelButtonTitle:@"取消"];

    infoView.backgroundColor = [UIColor clearColor];
    infoView.delegate = self;
    infoView.dataSource = self;
    infoView.tag = 1;
    
    [confirmOrderView addButtonWithTitle:@"确定" type:CXAlertViewButtonTypeDefault handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
        [self confirmOrder];
        [alertView dismiss];
    }];
    [confirmOrderView show];
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
        cell.textLabel.text = @"收货人：黄凌      18629646590";
        cell.detailTextLabel.text = @"地址：丁香12号楼I区218右室";
        cell.contentView.backgroundColor = [UIColor colorWithRed:135/255.0 green:206/255.0 blue:250/255.0 alpha:1.0];
        
        return cell;
    }else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            gecell.textLabel.text = @"菜名：糖醋里脊";
        }else if (indexPath.row == 1){
            gecell.textLabel.text = [NSString stringWithFormat: @"单价：%.2f元", self.pickedGoodPrice];
            
            UILabel *totalPriceLabel = [UILabel new];
            totalPriceLabel.text = [NSString stringWithFormat: @"总价：%.2f元", self.pickedGoodTotalPrice];
            [totalPriceLabel sizeToFit];
            totalPriceLabel.center = CGPointMake(gecell.textLabel.center.x + 200, gecell.contentView.frame.size.height/2);
            [gecell.contentView addSubview:totalPriceLabel];
        }else if (indexPath.row == 2){
            if (self.count == 0) {
                self.count = 1;
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
            gecell.textLabel.text = [NSString stringWithFormat:@"购买数量： %i份", self.count];
            [gecell.contentView addSubview:stepper];
            
        }
        return gecell;
    }
    return nil;
}

- (void)orderAmountChanged:(UIStepper *)sender{
    NSLog(@"%lf", sender.value);
    self.count = (int)sender.value;
    self.pickedGoodTotalPrice = self.count * self.pickedGoodPrice;
    UITableView *infoTableview = (UITableView *)sender.superview.superview.superview.superview.superview;
    [infoTableview reloadData];
}

- (void)confirmOrder{
    LINGoodModel *aGood = self.foodList[[self.pickedGoodNumber[0] integerValue]];
    NSString *goodName = aGood.goodName;
    NSString *goodsHotel = aGood.goodHotel;
    NSString *goodsPrice = aGood.goodPrice;
    NSString *number = [NSString stringWithFormat:@"%i", self.count];
    NSString *totalPrice = [NSString stringWithFormat:@"%.2lf", self.pickedGoodTotalPrice];
    NSString *username = @"t";
    NSString *userTel = @"t";
    NSString *userAddr = @"t";
    NSString *userLouhao = @"t";
    NSString *userQuhao = @"t";
    NSString *userSushehao = @"t";
    NSString *userZuoyou = @"t";
    NSString *createTime = @"t";
    NSString *createDay = @"t";
    
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
                                 __CREATEDAY__:createDay};
    
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:__HOSTNAME__];
    MKNetworkOperation *op = [engine operationWithPath:[NSString stringWithFormat:@"%@%@", __PHPDIR__, @"submit_order.php"] params:forPostDic httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSLog(@"%@", [completedOperation responseString]);
    } errorHandler:nil];
    [engine enqueueOperation:op];
    
}
@end




















