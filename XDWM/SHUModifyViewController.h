//
//  SHUModifyViewController.h
//  XDWM
//
//  Created by 王澍宇 on 14-2-10.
//  Copyright (c) 2014年 WeAround. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHUModifyViewController : UITableViewController<UIAlertViewDelegate>

@property (strong, nonatomic) NSString *userTel;
@property (strong, nonatomic) NSString *userMail;

@property (weak, nonatomic) IBOutlet UITextField *tel;
@property (weak, nonatomic) IBOutlet UITextField *mail;

@property (weak, nonatomic) IBOutlet UISegmentedControl *sex;

@property (weak, nonatomic) IBOutlet UITextField *oldPassword;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;

@end
