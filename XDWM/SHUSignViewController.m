//
//  SHUSignViewController.m
//  XDWM
//
//  Created by 王澍宇 on 14-2-10.
//  Copyright (c) 2014年 WeAround. All rights reserved.
//

#import "SHUSignViewController.h"
#import "MKNetworkEngine.h"
#import "CXAlertView.h"
#import "LINUserModel.h"
#import "ADDRMACRO.h"

@interface SHUSignViewController ()

@property (strong, nonatomic) MKNetworkEngine *engine;

@property (strong, nonatomic) NSDictionary *signInfoDic;
@property (strong, nonatomic) NSArray *apartments;
@property (strong, nonatomic) NSArray *numberOfapartments;

@property (strong, nonatomic) UIPickerView *pcikerView;

- (IBAction)pickAdress:(id)sender;
- (IBAction)SignUp:(id)sender;
- (IBAction)dismissModal:(id)sender;
- (IBAction)textFiledDidDoneEdting:(id)sender;

@end

@implementation SHUSignViewController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSString *signInfoPath = [[NSBundle mainBundle] pathForResource:@"SignUp Info" ofType:@"plist"];
    _signInfoDic = [NSDictionary dictionaryWithContentsOfFile:signInfoPath];
    
    _apartments = [_signInfoDic valueForKey:@"ApartmentNames"];
    _numberOfapartments = [_signInfoDic valueForKey:@"ApartmentNumbers"];
    
    _pcikerView = [[UIPickerView alloc] init];
    _pcikerView.delegate = self;
    _pcikerView.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pickAdress:(id)sender {
    
    CXAlertView *alert = [[CXAlertView alloc] initWithTitle:nil
                                                contentView:_pcikerView
                                          cancelButtonTitle:@"取消"];
    
    _pcikerView.frame = CGRectMake(0, 0, 280, 180);
    
    [alert addButtonWithTitle:@"确定" type:CXAlertViewButtonTypeDefault handler:^(CXAlertView *alert,CXAlertButtonItem *item){
        
        NSInteger rowForApart  = [_pcikerView selectedRowInComponent:0];
        NSInteger rowForNumber = [_pcikerView selectedRowInComponent:1];
        
        _aprtmentName.text = [_apartments objectAtIndex:rowForApart];
        _numberOfApartment.text = [_numberOfapartments objectAtIndex:rowForNumber];
        
        [alert dismiss];
        
    }];
    
    [alert show];
    
}

#pragma mark - SignUp and Cancel Method

- (IBAction)SignUp:(id)sender {
    
    if ([_userName.text isEqualToString:@""] ||
        [_userPassword.text isEqualToString:@""] ||
        [_passwordConfirm.text isEqualToString:@""] ||
        [_mail.text isEqualToString:@""] ||
        [_phoneNumber.text isEqualToString:@""] ||
        [_gateNumber.text isEqualToString:@""]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告"
                                                        message:@"所有项均为必填项" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alert show];
    }else{
        if (![_userPassword.text isEqualToString:_passwordConfirm.text]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告"
                                                            message:@"两次输入密码不同" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
            [alert show];
            
        }else{
            
            NSString *userName = _userName.text;
            NSString *userPassword = _userPassword.text;
            NSString *userSex = [_sex titleForSegmentAtIndex:[_sex selectedSegmentIndex]];
            NSString *userEmail = _mail.text;
            NSString *userTel = _phoneNumber.text;
            NSString *userAddr = _aprtmentName.text;
            NSString *userLouhao = _numberOfApartment.text;
            NSString *userQuhao = [_area titleForSegmentAtIndex:[_sex selectedSegmentIndex]];
            NSString *userSushehao = _gateNumber.text;
            NSString *userZuoyou = [_direction titleForSegmentAtIndex:[_direction selectedSegmentIndex]];
            
            NSDictionary *userInfo = @{__USERNAME__     : userName,
                                       __PASSWORD__     : userPassword,
                                       __USERSEX__      : userSex,
                                       __USEREMAIL__    : userEmail,
                                       __USERTEL__      : userTel,
                                       __USERADDR__     : userAddr,
                                       __USERLOUHAO__   : userLouhao,
                                       __USERSUSHEHAO__ : userSushehao,
                                       __USERZUOYOU__   : userZuoyou,
                                       __USERQUHAO__    : userQuhao};
            
            _engine = [[MKNetworkEngine alloc] initWithHostName:__HOSTNAME__];
            
            MKNetworkOperation *op = [_engine operationWithPath:[NSString stringWithFormat:@"%@%@",__PHPDIR__,@"user_register.php"] params:userInfo httpMethod:@"POST"];
            
            [op addCompletionHandler:^(MKNetworkOperation *compeletedOperation){
                
                NSData *reData = [compeletedOperation responseData];
                NSString *st = [[NSString alloc] initWithData:reData encoding:NSUTF8StringEncoding];
                
                NSLog(@"%@",st);
                
                if ([st isEqualToString:@"200"]) {
                    
                    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                    
                    NSDictionary *infoDic = @{__USERNAME__ : userName,
                                              __PASSWORD__ : userPassword};
                    
                    [infoDic writeToFile:[NSString stringWithFormat:@"%@/infoDic.plist",docPath] atomically:YES];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"返回信息"
                                                                    message:@"注册成功"
                                                                   delegate:self
                                                          cancelButtonTitle:@"知道了"
                                                          otherButtonTitles:nil];
                    [alert show];
                }else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"返回信息"
                                                                    message:@"注册成功"
                                                                   delegate:self
                                                          cancelButtonTitle:@"知道了"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
                
                
            }errorHandler:^(MKNetworkOperation *compeletedOperation, NSError *error){
                NSLog(@"%@",error);
            }];
            
            [_engine enqueueOperation:op];
        }
    }
    
}



- (IBAction)dismissModal:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:Nil];
}

#pragma mark - PickerView Method

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return [_apartments count];
    }else{
        return [_numberOfapartments count];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        return [_apartments objectAtIndex:row];
    }else{
        return [_numberOfapartments objectAtIndex:row];
    }
}

#pragma mark - close keyboard

- (IBAction)textFiledDidDoneEdting:(id)sender
{
    [sender resignFirstResponder];
}

#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if ([alertView.message isEqualToString:@"注册成功"]) {
            [self dismissViewControllerAnimated:YES completion:Nil];
        }
    }
}

#pragma mark - Table view data source

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
