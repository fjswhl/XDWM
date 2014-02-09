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

@interface LINPickFoodViewController (){
    NSInteger count;
}
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
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buy)];
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
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSData *reData = [completedOperation responseData];
        NSString *st = [[NSString alloc] initWithData:reData encoding:enc];

        NSDictionary *goodInfo = [NSJSONSerialization JSONObjectWithData:[st dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        
        //下面将获取的数据写入模型
        NSArray *keys = [goodInfo allKeys];
        for (NSString *key in keys) {
            NSDictionary *aGood = [goodInfo objectForKey:key];
            LINGoodModel *aGoodModel = [[LINGoodModel alloc] initWithDictionary:aGood];
            [self.foodList addObject:aGoodModel];
        }
        [self.tableView reloadData];
    } errorHandler:nil];
    
    [engine enqueueOperation:op];
    

}

- (void)buy{
    NSLog(@"I wannna buy");
    UITableView *infoView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 280, 180) style:UITableViewStylePlain];
    infoView.separatorInset = UIEdgeInsetsMake(0, 5, 0, 5);
    CXAlertView *confirmOrderView = [[CXAlertView alloc] initWithTitle:@"确认订单" contentView:infoView cancelButtonTitle:@"取消"];

    infoView.backgroundColor = [UIColor clearColor];
    infoView.delegate = self;
    infoView.dataSource = self;
    infoView.tag = 1;
    
    [confirmOrderView addButtonWithTitle:@"确定" type:CXAlertViewButtonTypeDefault handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
        ;
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
            gecell.textLabel.text = @"单价：7元";
        }else if (indexPath.row == 2){
            count = 1;
    
            UIStepper *stepper = [[UIStepper alloc] initWithFrame:CGRectMake(170, 0, 70, 29)];
            stepper.center = CGPointMake(stepper.center.x, gecell.contentView.frame.size.height / 2);
            stepper.minimumValue = 1;
            stepper.maximumValue = 100;
            stepper.stepValue = 1;
            stepper.continuous = YES;
            stepper.transform = CGAffineTransformMakeScale(0.8, 1);
            
            [stepper addTarget:self action:@selector(orderAmountChanged) forControlEvents:UIControlEventValueChanged];
            count = stepper.value;
            gecell.textLabel.text = [NSString stringWithFormat:@"购买数量： %i份", count];
            [gecell.contentView addSubview:stepper];
            
        }
        return gecell;
    }
    return nil;
}

- (void)orderAmountChanged{

}
@end




















