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

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.foodList count];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 96;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    
    
}

@end




















