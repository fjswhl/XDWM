//
//  SHUUserInfoViewController.m
//  XDWM
//
//  Created by 王澍宇 on 14-2-10.
//  Copyright (c) 2014年 WeAround. All rights reserved.
//

#import "SHUUserInfoViewController.h"
#import "SHUModifyViewController.h"
#import "LINUserModel.h"
#import "MKNetworkEngine.h"
#import "ADDRMACRO.h"
#import "LINRootViewController.h"
#import "LINOrderViewController.h"

@interface SHUUserInfoViewController ()

@property (strong, nonatomic) MKNetworkEngine *engine;
@property (strong, nonatomic) NSMutableDictionary *userInfo;
@property (strong, nonatomic) LINUserModel *user;

@end

@implementation SHUUserInfoViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)logout:(id)sender {
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    docPath = [docPath stringByAppendingString:@"/infoDic.plist"];
    NSFileManager *fm = [NSFileManager new];
    [fm removeItemAtPath:docPath error:nil];
    
    //          清除一些控制器内以存的信息
    id vc = self.tabBarController.viewControllers[1];
    if (vc) {
        
        [[vc topViewController] setValue:[NSMutableArray new] forKey:@"OrderList"];
    }
    
    [self.tabBarController setSelectedIndex:0];
    

}

- (LINUserModel *)user{
    LINRootViewController* rootVC = (LINRootViewController *)self.tabBarController;
    return rootVC.user;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    _userInfo = [NSMutableDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/infoDic.plist",docPath]];
//    
//    [_userInfo removeObjectForKey:__PASSWORD__];
    
//     _engine = [[MKNetworkEngine alloc] initWithHostName:__HOSTNAME__];
    
    [self updateUserInfo];


    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(RefreshViewControlEventValueChanged) forControlEvents:UIControlEventValueChanged];
    


}

- (void)viewWillAppear:(BOOL)animated{
    [self updateUserInfo];
}

- (void)RefreshViewControlEventValueChanged
{
    LINOrderViewController *orderVC = (LINOrderViewController *)[(UINavigationController* )self.tabBarController.viewControllers[0] topViewController];
    [orderVC fetchUserInfoToRootVC];
    
    [self updateUserInfo];
    
    [self.tableView reloadData];
    
    [self.refreshControl endRefreshing];
}

- (void)updateUserInfo{
    _userName.text = self.user.userName;
    _point.text = self.user.userPoint;
    _sex.text = self.user.userSex;
    _tel.text = self.user.userTel;
    _mail.text = self.user.userEmail;
    _adress.text = self.user.userAddr;
    _apartnumber.text = self.user.userLouhao;
    _gate.text = self.user.userSushehao;
    _direction.text = self.user.userZuoyou;
    _area.text = self.user.userQuhao;
}

//- (void)getUserInfo
//{
//    MKNetworkOperation *op = [_engine operationWithPath:[NSString stringWithFormat:@"%@%@",__PHPDIR__,@"fetch_user_info.php"] params:_userInfo httpMethod:@"POST"];
//    
//    [op addCompletionHandler:^(MKNetworkOperation *compeletedOperation){
//        
//        NSDictionary *returnInfo = [compeletedOperation responseJSON];
//        
//        if (returnInfo) {
//            _userName.text = [returnInfo objectForKey:__USERNAME__];
//            _point.text = [returnInfo objectForKey:__USERPOINT__];
//            _sex.text = [returnInfo objectForKey:__USERSEX__];
//            _tel.text = [returnInfo objectForKey:__USERTEL__];
//            _mail.text = [returnInfo objectForKey:__USEREMAIL__];
//            _adress.text = [returnInfo objectForKey:__USERADDR__];
//            _apartnumber.text = [returnInfo objectForKey:__USERSUSHEHAO__];
//            _gate.text = [returnInfo objectForKey:__USERSUSHEHAO__];
//            _direction.text = [returnInfo objectForKey:__USERZUOYOU__];
//            _area.text = [returnInfo objectForKey:__USERQUHAO__];
//            
//        }else{
//            
//            [self getUserInfo];
//            
//        }
//        
//    }errorHandler:^(MKNetworkOperation *compeletedOperation, NSError *error){
//        NSLog(@"%@",error);
//    }];
//    
//    [_engine enqueueOperation:op];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToModify"]) {
        
        SHUModifyViewController *modifyVC = segue.destinationViewController;
        modifyVC.userTel = _tel.text;
        modifyVC.userMail = _mail.text;
        
    }
}

#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
