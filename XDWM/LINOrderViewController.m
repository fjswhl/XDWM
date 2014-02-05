//
//  LINOrderViewController.m
//  XDWM
//
//  Created by Lin on 14-2-4.
//  Copyright (c) 2014年 WeAround. All rights reserved.
//

#import "LINOrderViewController.h"
#import "LINPickFoodViewController.h"
@interface LINOrderViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic) NSInteger kFoodKindIndex;
@end

@implementation LINOrderViewController

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
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.tabBarController.tabBar.hidden == YES) {
            [self.tabBarController.tabBar setHidden:NO];

    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableview data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"foodKind"];
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:1];
    if (indexPath.section == 0 && indexPath.row == 0) {

        titleLabel.textAlignment = NSTextAlignmentCenter;
    } else if (indexPath.section == 0 && indexPath.row == 1){
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = @"绿茉莉套餐（10选3）";
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"请选择菜品种类";
    }
    return nil;
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:1];
    
    self.kFoodKindIndex = indexPath.row + 1;
    [UIView animateWithDuration:0.5f animations:^{
        [self.tabBarController.tabBar setHidden:YES];
    }];
    
    [self performSegueWithIdentifier:@"performFoodSegue" sender:self];
    [self.tableview deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - storyboard

/*              kFoodKindIndex如果是1， 则加载锅巴米饭；如果是2，加载绿茉莉*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"performFoodSegue"]) {
        //[segue.destinationViewController setInteger:self.kFoodKindIndex forKey:@"kFoodKindIndex"];
        LINPickFoodViewController *pickVC = segue.destinationViewController;
        [pickVC setFoodKindIndex:self.kFoodKindIndex];
    }
}
@end





















