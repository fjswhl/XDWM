//
//  LINOrderViewController.m
//  XDWM
//
//  Created by Lin on 14-2-4.
//  Copyright (c) 2014年 WeAround. All rights reserved.
//

#import "LINOrderViewController.h"
#import "LINPickFoodViewController.h"
#import "LINRecordViewController.h"
#import "SHULoginViewController.h"
#import "LINUserModel.h"
#import "LINRootViewController.h"
#import "MKNetworkEngine.h"
#import "MKNetworkOperation.h"
#import "ADDRMACRO.h"
#import "MBProgressHUD.h"
@interface LINOrderViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic) NSInteger kFoodKindIndex;

@property (strong, nonatomic) MKNetworkEngine *engine;
@end

@implementation LINOrderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//          启动时检查用户是否登入，如果没登入，则跳转到登入界面；如果登入了，则把用户信息写到RootViewController下的user属性中
#pragma mark view life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.engine = [[MKNetworkEngine alloc] initWithHostName:__HOSTNAME__];
}
- (void)viewWillAppear:(BOOL)animated{
    [self fetchUserInfoToRootVC];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableview data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"foodKind"];
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:1];
    if (indexPath.section == 0 && indexPath.row == 0) {

        titleLabel.textAlignment = NSTextAlignmentCenter;
    } else if (indexPath.section == 0 && indexPath.row == 1){
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = @"绿茉莉套餐（10选3）";
    } else if (indexPath.section == 0 && indexPath.row == 2){
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = @"脆皮鸡烤肉饭";
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"    请选择菜品种类";
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return @"    已经有超过1000次\n    通过我们的网站解决他们的晚饭\n    我们期待为更多的同学服务......\n    预定晚餐,17:00前下单,18:30之前送到！";
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:1];
    if (indexPath.row == 1) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"暂未开放,敬请期待!";
        [hud hide:YES afterDelay:1.5];
        [self.tableview deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    self.kFoodKindIndex = indexPath.row + 1;
    
    [self performSegueWithIdentifier:@"performFoodSegue" sender:self];
    [self.tableview deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - storyboard

/*              kFoodKindIndex如果是1， 则加载锅巴米饭；如果是2，加载绿茉莉*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"performFoodSegue"]) {
        //[segue.destinationViewController setInteger:self.kFoodKindIndex forKey:@"kFoodKindIndex"];
        LINPickFoodViewController *pickVC = segue.destinationViewController;
        [pickVC setFoodKindIndex:self.kFoodKindIndex];
    }
}

- (void)fetchUserInfoToRootVC{
    NSFileManager *fm = [NSFileManager new];
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    if (![fm fileExistsAtPath:[NSString stringWithFormat:@"%@/infoDic.plist", docPath]]) {
        UINavigationController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"login"];
        [self presentViewController:loginVC animated:YES completion:nil];
    }else{
        NSDictionary *userInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/infoDic.plist", docPath]];
        
        LINRootViewController *rootVC = (LINRootViewController *)self.tabBarController;
        rootVC.user.userName = userInfo[__USERNAME__];
        rootVC.user.userPassword = userInfo[__PASSWORD__];
        
        MKNetworkOperation *op = [self.engine operationWithPath:[NSString stringWithFormat:@"%@%@",__PHPDIR__,@"fetch_user_info.php"] params:@{__USERNAME__:rootVC.user.userName} httpMethod:@"POST"];
        [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            NSString *st = [completedOperation responseString];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[st dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
            rootVC.user.userAddr = dic[__USERADDR__];
            rootVC.user.userEmail = dic[__USEREMAIL__];
            rootVC.user.userLouhao = dic[__USERLOUHAO__];
            rootVC.user.userPoint = dic[__USERPOINT__];
            rootVC.user.userQuhao = dic[__USERQUHAO__];
            rootVC.user.userSex = dic[__USERSEX__];
            rootVC.user.userSushehao = dic[__USERSUSHEHAO__];
            rootVC.user.userTel = dic[__USERTEL__];
            rootVC.user.userZuoyou = dic[__USERZUOYOU__];
            
        } errorHandler:nil];
        [self.engine enqueueOperation:op];
        
    }
}

#pragma sign vc delegate method

//- (void)userDidSignedUp{
//    [self fetchUserInfoToRootVC];
//    LINRecordViewController *recordVC = (LINRecordViewController *)self.tabBarController.viewControllers[1];
//    if (recordVC) {
//        recordVC.orderList = [NSMutableArray new];
//    }
//}
@end





















