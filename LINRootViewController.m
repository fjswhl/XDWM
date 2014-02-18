//
//  LINRootViewController.m
//  XDWM
//
//  Created by Lin on 14-2-9.
//  Copyright (c) 2014年 WeAround. All rights reserved.
//

#import "LINRootViewController.h"
#import "SHULoginViewController.h"
@interface LINRootViewController ()

@end

@implementation LINRootViewController

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

- (LINUserModel *)user{
    if (!_user) {
        _user = [LINUserModel new];
    }
    return _user;
}
@end
