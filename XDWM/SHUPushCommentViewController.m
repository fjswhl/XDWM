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
#define kSendMessage @"20"

@interface SHUPushCommentViewController ()

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - push comment method

- (IBAction)pushComment:(id)sender {
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSDictionary *infoDic = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/infoDic.plist",docPath]];
    
    NSDate *date = [NSDate date];
    
    NSString *username = [infoDic objectForKey:__USERNAME__];
    NSString *commentContent = _commentContent.text;
    NSString *createTime = [[date description] substringToIndex:19];
    
    NSDictionary *commentDic = @{__USER_NAME__  : username,
                                 __CONTENT__    : commentContent,
                                 __CREATETIME__ : createTime};
    
//    NSLog(@"%@",infoDic); OK
    
    NSDictionary *userInfo = @{@"key1" : kSendMessage,
                               __USER_NAME__ : username,
                               __CONTENT__:commentContent,
                               __CREATETIME__:createTime};
    

    
    MKNetworkOperation *op = [_engine operationWithPath:[NSString stringWithFormat:@"%@%@",__PHPDIR__,@"messageboard.php"] params:userInfo httpMethod:@"POST"];
    
    [op addCompletionHandler:^(MKNetworkOperation *compeletedOpeartion){
        NSLog(@"%@", [compeletedOpeartion responseString]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"返回信息" message:@"留言成功" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        
        [alert show];
        
    }errorHandler:^(MKNetworkOperation *compeletedOpeartion,NSError *error){
        
        NSLog(@"%@",error);
        
    }];
    
    [_engine enqueueOperation:op];
}

#pragma mark - close keyboard

- (IBAction)textDidFinshEditing:(id)sender {
    [_commentContent resignFirstResponder];
}


@end
