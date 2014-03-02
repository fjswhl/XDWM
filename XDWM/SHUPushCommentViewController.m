//
//  SHUPushCommentViewController.m
//  XDWM
//
//  Created by 王澍宇 on 14-2-10.
//  Copyright (c) 2014年 WeAround. All rights reserved.
//

#import "SHUPushCommentViewController.h"
#import "SHUCommentModel.h"
#import "LINUserModel.h"
#import "MKNetworkEngine.h"
#include "ADDRMACRO.h"
#import "MBProgressHUD.h"
#define kSendMessage @"20"

@interface SHUPushCommentViewController ()<UITextViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) MKNetworkEngine *engine;

- (IBAction)pushComment:(id)sender;

@end

@implementation SHUPushCommentViewController

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
    
    _engine = [[MKNetworkEngine alloc] initWithHostName:__HOSTNAME__];
    self.commentContent.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(numberOfWordsLeft) name:@"CalculteWordsLeft" object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [self.commentContent becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)numberOfWordsLeft
{
    NSInteger commentLength = [_commentContent.text length];
    
    _wordsLeft.text = [NSString stringWithFormat:@"您还能输入%ld字", 64 - commentLength];
}

#pragma mark - push comment method

- (IBAction)pushComment:(id)sender {
    if ([_commentContent.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"内容不能为空的，亲" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }else if([_commentContent.text length] > 64){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"留言超过字数限制" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            return;
    }
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSDictionary *infoDic = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/infoDic.plist",docPath]];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *username = [infoDic objectForKey:__USERNAME__];
    NSString *commentContent = _commentContent.text;
//    NSString *createTime = [[date description] substringToIndex:19];
    NSString *createTime = [dateFormatter stringFromDate:date];
//    NSDictionary *commentDic = @{__USER_NAME__  : username,
//                                 __CONTENT__    : commentContent,
//                                 __CREATETIME__ : createTime};
    
//    NSLog(@"%@",infoDic); OK
    //          转动HUD
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    NSDictionary *userInfo = @{@"key1" : kSendMessage,
                               __USER_NAME__ : username,
                               __CONTENT__:commentContent,
                               __CREATETIME__:createTime};
    

    
    MKNetworkOperation *op = [_engine operationWithPath:[NSString stringWithFormat:@"%@%@",__PHPDIR__,@"messageboard.php"] params:userInfo httpMethod:@"POST"];
    
    [op addCompletionHandler:^(MKNetworkOperation *compeletedOpeartion){
        NSLog(@"%@", [compeletedOpeartion responseString]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"返回信息" message:@"留言成功" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        alert.delegate = self;
        [alert show];
        [hud hide:YES];
        
    }errorHandler:^(MKNetworkOperation *compeletedOpeartion,NSError *error){
        [hud hide:YES];
        MBProgressHUD *errorHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        errorHud.mode = MBProgressHUDModeText;
        errorHud.labelText = @"网络错误，请稍后重试";
        [errorHud hide:YES afterDelay:1.5f];
    }];
    
    [_engine enqueueOperation:op];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - close keyboard

- (IBAction)textDidFinshEditing:(id)sender {
    [_commentContent resignFirstResponder];
}

#pragma mark - textview delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([@"\n" isEqualToString:text]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CalculteWordsLeft" object:nil];
}

#pragma  mark - uialertView delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    [self.navigationController popViewControllerAnimated:YES];
}
@end















