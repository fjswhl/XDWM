//
//  TestViewController.m
//  XDWM
//
//  Created by Lin on 14-2-14.
//  Copyright (c) 2014年 WeAround. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()
@property (strong, nonatomic) IBOutlet UIView *testView;


@end

@implementation TestViewController

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
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 0)];
    
    label.text = @"fasdfjhasldkjfnlasdnmjfovijoasidnflkchjxoizvjoasdnfsdfsadfsdaffjlksdajfoasfnsakdlfnovisancovihasdnfasd";
    label.numberOfLines = 0;
    [label sizeToFit];
    [self.testView addSubview:label];


	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
