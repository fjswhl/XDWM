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
#import <CoreData/CoreData.h>
@interface LINOrderViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic) NSInteger kFoodKindIndex;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

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
    NSFileManager *fm = [NSFileManager new];
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    if (![fm fileExistsAtPath:[NSString stringWithFormat:@"%@/infoDic.plist", docPath]]) {
        UINavigationController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"login"];
        [self presentViewController:loginVC animated:YES completion:nil];
        return;
    }
    
    LINRootViewController *rootVC = (LINRootViewController *)self.tabBarController;
        
    LINUserModel *user = rootVC.user;
    if (self.needRefreshUserInfo == TRUE || user == nil) {
        [self fetchUserInfoToRootVC];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSManagedObjectContext *)managedObjectContext{

    if (!_managedObjectContext) {
        id appDelegate = [[UIApplication sharedApplication] delegate];
        _managedObjectContext = [appDelegate managedObjectContext];
    }
    return _managedObjectContext;
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
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tabBarController.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;

        NSDictionary *userInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/infoDic.plist", docPath]];
        
        LINRootViewController *rootVC = (LINRootViewController *)self.tabBarController;
        LINUserModel *user = [LINUserModel new];
        
        user.userName = userInfo[__USERNAME__];
        user.userPassword = userInfo[__PASSWORD__];
        
        MKNetworkOperation *op = [self.engine operationWithPath:[NSString stringWithFormat:@"%@%@",__PHPDIR__,@"fetch_user_info.php"] params:@{__USERNAME__:user.userName} httpMethod:@"POST"];
        [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            NSString *st = [completedOperation responseString];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[st dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
            user.userAddr = dic[__USERADDR__];
            user.userEmail = dic[__USEREMAIL__];
            user.userLouhao = dic[__USERLOUHAO__];
            user.userPoint = dic[__USERPOINT__];
            user.userQuhao = dic[__USERQUHAO__];
            user.userSex = dic[__USERSEX__];
            user.userSushehao = dic[__USERSUSHEHAO__];
            user.userTel = dic[__USERTEL__];
            user.userZuoyou = dic[__USERZUOYOU__];
            rootVC.user = user;
            [hud hide:YES];
        } errorHandler:nil];
        [self.engine enqueueOperation:op];

    self.needRefreshUserInfo = false;
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





















