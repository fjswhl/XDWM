//
//  SHULoginViewController.m
//  XDWM
//
//  Created by 王澍宇 on 14-2-9.
//  Copyright (c) 2014年 WeAround. All rights reserved.
//

#import "SHULoginViewController.h"
#import "MKNetworkEngine.h"
#import "LINUserModel.h"
#import "ADDRMACRO.h"
#import "LINOrderViewController.h"

@interface SHULoginViewController ()

@property (strong, nonatomic) MKNetworkEngine *engine;

- (IBAction)Login:(id)sender;
- (IBAction)SignUp:(id)sender;
- (IBAction)textFieldDoneEditing:(id)sender;

@end

@implementation SHULoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Login and SignUp

- (IBAction)Login:(id)sender {
    
    _loginButton.enabled = NO;   // 防止多次触发
     
    if ([_userID.text isEqualToString:@""] || [_userPassword.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"用户名或密码不能为空" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alert show];
        
        _loginButton.enabled = YES;
        
    }else{
        
        NSString *userName = _userID.text;
        NSString *userPassword = _userPassword.text;
        
        NSDictionary *infoDic = @{__USERNAME__ : userName,
                                  __PASSWORD__ : userPassword};
        
        _engine = [[MKNetworkEngine alloc] initWithHostName:__HOSTNAME__];
        
        MKNetworkOperation *op = [_engine operationWithPath:[NSString stringWithFormat:@"%@%@",__PHPDIR__,@"user_login.php"] params:infoDic httpMethod:@"POST"];
        
        [op addCompletionHandler:^(MKNetworkOperation *compeletedOperation){
            
            NSData *reData = [compeletedOperation responseData];
            NSString *st = [[NSString alloc] initWithData:reData encoding:NSUTF8StringEncoding];
            
            NSLog(@"%@",st);
            
            if ([st isEqualToString:@"200"]){
                
                /*      将用户信息保存到本地      */
                NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                [infoDic writeToFile:[NSString stringWithFormat:@"%@/infoDic.plist",docPath] atomically:YES];
                
                /*      隐藏跟导航控制器     */
                
                self.navigationController.navigationBarHidden = YES;
                
             //   [self performSegueWithIdentifier:@"segueToMain" sender:self];
                LINOrderViewController *orderVC = (LINOrderViewController *)self.presentingViewController;
                [orderVC fetchGoodInfoToRootVC]; //调父视图的方法或者给父视图传消息
                
                [self dismissViewControllerAnimated:YES completion:nil];
                
                
            }else if([st isEqualToString:@"404"]){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"返回消息"
                                                                message:@"用户名不存在"
                                                               delegate:self
                                                      cancelButtonTitle:@"知道了"
                                                      otherButtonTitles:nil];
                [alert show];
                
                _loginButton.enabled = YES;
                
            }else if([st isEqualToString:@"401"]){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"返回消息"
                                                                message:@"用户名密码错误"
                                                               delegate:self
                                                      cancelButtonTitle:@"知道了"
                                                      otherButtonTitles:nil];
                [alert show];
                
                _loginButton.enabled = YES;
            }
            
        }errorHandler:^(MKNetworkOperation *compeletedOperation, NSError *error){
            
            NSLog(@"%@",error);
            
        }];
        
        [_engine enqueueOperation:op];
    }

}

- (IBAction)SignUp:(id)sender {
    
    [self performSegueWithIdentifier:@"segueToSignUp" sender:self];
}

#pragma mark - TextFiled Method

- (IBAction)textFieldDoneEditing:(id)sender
{
    [self resignFirstResponder];
}

@end
