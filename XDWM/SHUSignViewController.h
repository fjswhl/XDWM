//
//  SHUSignViewController.h
//  XDWM
//
//  Created by 王澍宇 on 14-2-10.
//  Copyright (c) 2014年 WeAround. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHUSignViewController : UITableViewController<UIPickerViewDataSource,UIPickerViewDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *userPassword;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirm;
@property (weak, nonatomic) IBOutlet UITextField *mail;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *gateNumber;

@property (weak, nonatomic) IBOutlet UILabel *aprtmentName;
@property (weak, nonatomic) IBOutlet UILabel *numberOfApartment;

@property (weak, nonatomic) IBOutlet UISegmentedControl *sex;
@property (weak, nonatomic) IBOutlet UISegmentedControl *area;
@property (weak, nonatomic) IBOutlet UISegmentedControl *direction;

@end
