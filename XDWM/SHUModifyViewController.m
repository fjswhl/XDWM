//
//  SHUModifyViewController.m
//  XDWM
//
//  Created by 王澍宇 on 14-2-10.
//  Copyright (c) 2014年 WeAround. All rights reserved.
//

#import "SHUModifyViewController.h"
#import "LINUserModel.h"
#import "MKNetworkEngine.h"
#include "ADDRMACRO.h"
@interface SHUModifyViewController ()

@property (strong ,nonatomic) NSString *localUsername;
@property (strong ,nonatomic) NSString *localPassword;

@property (strong, nonatomic) MKNetworkEngine *engine;
@property (nonatomic) BOOL isModifyingPassword;

- (IBAction)confirmModify:(id)sender;
- (IBAction)cancelModify:(id)sender;
- (IBAction)TextFiledDidFinshEditing:(id)sender;

@end

@implementation SHUModifyViewController

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
    
    _engine = [[MKNetworkEngine alloc] initWithHostName:__HOSTNAME__];
    
//    NSLog(@"%@ and %@",_userTel,_userMail);

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

- (IBAction)confirmModify:(id)sender {
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSMutableDictionary *localUserInfo = [NSMutableDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/infoDic.plist",docPath]];
    
    _localUsername = [localUserInfo objectForKey:__USERNAME__];
    _localPassword = [localUserInfo objectForKey:__PASSWORD__];
    
    if ([_tel.text isEqualToString:@""]) {
        _tel.text = _userTel;
    }
    
    if ([_mail.text isEqualToString:@""]) {
        _mail.text = _userMail;
    }
    
    NSString *sex = [_sex titleForSegmentAtIndex:[_sex selectedSegmentIndex]];
    
    NSDictionary *tempInfo = @{__USERTEL__   : _tel.text,
                               __USEREMAIL__ : _mail.text,
                               __USERSEX__   : sex};
    
    NSMutableDictionary *userInfo = [tempInfo mutableCopy];
    
    if ([_password.text isEqualToString:@""]) {
        _isModifyingPassword = NO;
    }else{
        _isModifyingPassword = YES;
    }
    
    if (_isModifyingPassword && [_password.text isEqualToString:_confirmPassword.text]) {
        
        [userInfo setObject:_confirmPassword.text forKey:__PASSWORD__];
        [userInfo setObject:_localUsername forKey:__USERNAME__];
        
    }
    
    MKNetworkOperation *op = [_engine operationWithPath:[NSString stringWithFormat:@"%@%@",__PHPDIR__,@"update_user_info.php"] params:userInfo httpMethod:@"POST"];
    
    [op addCompletionHandler:^(MKNetworkOperation *compeletedOperation){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"返回信息"
                                                        message:@"修改成功"
                                                       delegate:self
                                              cancelButtonTitle:@"知道了"
                                              otherButtonTitles:nil];
        [alert show];
        
        
    }errorHandler:^(MKNetworkOperation *compeletedOperation, NSError *error){
        
        NSLog(@"%@",error);
        
    }];
    
    [_engine enqueueOperation:op];
}

- (IBAction)TextFiledDidFinshEditing:(id)sender
{
    [sender resignFirstResponder];
}

- (IBAction)cancelModify:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if ([alertView.message isEqualToString:@"修改成功"]) {
            [self dismissViewControllerAnimated:YES completion:Nil];
        }
    }
}

@end
