//
//  XinViewController.m
//  Inform
//
//  Created by GX on 14-2-15.
//  Copyright (c) 2014年 WHG. All rights reserved.
//

#import "XinViewController.h"
#import "ANNOUNCEMEMNT.h"
#import "MJRefreshHeaderView.h"
#import "MKNetworkEngine.h"
#import "MKNetworkOperation.h"
#import "ADDRMACRO.h"


@interface XinViewController ()
@property (copy, nonatomic) IBOutlet UILabel *title;
@property (copy, nonatomic) IBOutlet UILabel *content;
@property (copy, nonatomic) IBOutlet UILabel *date;
@property (copy, nonatomic) IBOutlet UILabel *author;
@property (strong, nonatomic) IBOutlet UIView *view2;
@property (strong, nonatomic) IBOutlet UILabel *other;
@property (strong, nonatomic) NSArray *objects;
@property (strong, nonatomic) NSArray *objects2;
@property (nonatomic, strong) MJRefreshHeaderView *header;


@end

@implementation XinViewController
@synthesize tableView1;
@synthesize author;
@synthesize title;
@synthesize date;
@synthesize content;
@synthesize view2;
@synthesize other;
@synthesize objects;
@synthesize objects2;
@synthesize header;

- (void)viewDidLoad
{
    view2 = [[UIView alloc] init];
    header = [MJRefreshHeaderView header];
    header.scrollView = self.tableView1;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        NSDictionary *dicForPost = @{@"key1":@"10",@"key2":@"0"};
        MKNetworkEngine* engine = [[MKNetworkEngine alloc] initWithHostName:__HOSTNAME__];
        MKNetworkOperation *op = [engine operationWithPath:[NSString stringWithFormat:@"%@%@", __PHPDIR__, @"fetch_ancmt.php"] params:dicForPost httpMethod:@"POST"];
        [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            NSString *st = [completedOperation responseString];
            st =[st stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@"  "];
            NSDictionary *ancmt = [NSJSONSerialization JSONObjectWithData:[st dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
            title.frame = CGRectMake(0, 10, 320, 30);
            title.text = ancmt[__TITLE__];
            content.frame = CGRectMake(20, 65, 280, 800);
            [content setNumberOfLines:0];
            //NSLog(@"5");
            content.text = ancmt[__CONTENT__];
            [content sizeToFit];
            author.frame = CGRectMake(20, content.frame.size.height + 75, 280, 30);
            author.text = ancmt[__AUTHOR__];
            date.frame = CGRectMake(20, author.frame.size.height + author.frame.origin.y, 280, 30);
            date.text = ancmt[__CREATE_TIME__];
            other.frame = CGRectMake(20, 10 + date.frame.size.height + date.frame.origin.y, 300, 30);
            view2.frame = CGRectMake(0, 10 + other.frame.size.height + other.frame.origin.y, 320, 150);
        }errorHandler:nil];
        [engine enqueueOperation:op];
        
        
        NSDictionary *dicForPost1 = @{@"key1":@"20",@"key2":@"0"};
        MKNetworkEngine* engine1 = [[MKNetworkEngine alloc] initWithHostName:__HOSTNAME__];
        MKNetworkOperation *op1 = [engine1 operationWithPath:[NSString stringWithFormat:@"%@%@", __PHPDIR__, @"fetch_ancmt.php"] params:dicForPost1 httpMethod:@"POST"];
        [op1 addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            for(UIView *View in [view2 subviews])
                if([View isKindOfClass:[UIButton class]])
                    [View removeFromSuperview];
            NSString *st = [completedOperation responseString];
            st =[st stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
            NSDictionary *ancmt = [NSJSONSerialization JSONObjectWithData:[st dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
            NSArray *array = [ancmt allValues];
            NSMutableArray *mutArray = [[NSMutableArray alloc] init];
            NSMutableArray *mutArray1 = [[NSMutableArray alloc] init];
            for (int i=0; i < 5; ++i) {
                NSDictionary *dic = [array objectAtIndex:i];
                NSString *str = dic[__TITLE__];
                [mutArray addObject:str];
                NSString *identity = dic[__ID__];
                [mutArray1 addObject:identity];
            }
            //NSLog(@"2");
            objects = mutArray;
            objects2 = mutArray1;
            //view2.backgroundColor = [UIColor yellowColor];
            for (int i=0; i < 5; ++i) {
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake( 40, 30*i, 280, 20)];
                button.tag = i;
                [button setTitle:[objects objectAtIndex:i] forState:UIControlStateNormal];
                [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
                [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
                [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
                [view2 insertSubview:button atIndex:10];
            }
        }errorHandler:nil];
        [engine1 enqueueOperation:op1];
        [self performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:2.0];
    };
    [header beginRefreshing];
    tableView1.allowsSelection = NO;
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
    [refreshView endRefreshing];
}
- (void)dealloc{
    //NSLog(@"3");
    [self.header free];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellTableIdentifier = @"CellTableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellTableIdentifier];
    }
    NSDictionary *dicForPost = @{@"key1":@"10",@"key2":@"0"};
    MKNetworkEngine* engine = [[MKNetworkEngine alloc] initWithHostName:__HOSTNAME__];
    MKNetworkOperation *op = [engine operationWithPath:[NSString stringWithFormat:@"%@%@", __PHPDIR__, @"fetch_ancmt.php"] params:dicForPost httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSString *st = [completedOperation responseString];
        st =[st stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@"  "];
        NSDictionary *ancmt = [NSJSONSerialization JSONObjectWithData:[st dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 320, 30)];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont boldSystemFontOfSize:30];
        title.text = ancmt[__TITLE__];
        content = [[UILabel alloc] initWithFrame:CGRectMake(20, 65, 280, 800)];
        [content setNumberOfLines:0];
        content.text = ancmt[__CONTENT__];
        [content sizeToFit];
        author = [[UILabel alloc] initWithFrame:CGRectMake(20, content.frame.size.height + 75, 280, 30)];
        author.text = ancmt[__AUTHOR__];
        author.textAlignment = NSTextAlignmentRight;
        date = [[UILabel alloc] initWithFrame:CGRectMake(20, author.frame.size.height + author.frame.origin.y, 280, 30)];
        date.text = ancmt[__CREATE_TIME__];
        date.textAlignment = NSTextAlignmentRight;
        other = [[UILabel alloc] initWithFrame:CGRectMake(20, 10 + date.frame.size.height + date.frame.origin.y, 300, 30)];
        other.text = @"其他通知";
        other.font = [UIFont boldSystemFontOfSize:20];
        [cell addSubview:title];
        [cell addSubview:content];
        [cell addSubview:author];
        [cell addSubview:date];
        [cell addSubview:other];
        view2.frame = CGRectMake(0, 10 + other.frame.size.height + other.frame.origin.y, 320, 150);
        [cell insertSubview:view2 atIndex:10];
        //NSLog(@"1");
    }errorHandler:nil];
    [engine enqueueOperation:op];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat x = view2.frame.origin.y + view2.frame.size.height + 20;
    return 1000;
}

-(IBAction) buttonClicked:(id)sender {
    UIButton *button = sender;
    title.text = button.currentTitle;
    NSString *identify = [objects2 objectAtIndex:button.tag];
    NSDictionary *dicForPost1 = @{@"key1":@"10",@"key2":identify};
    MKNetworkEngine* engine1 = [[MKNetworkEngine alloc] initWithHostName:__HOSTNAME__];
    MKNetworkOperation *op1 = [engine1 operationWithPath:[NSString stringWithFormat:@"%@%@", __PHPDIR__, @"fetch_ancmt.php"] params:dicForPost1 httpMethod:@"POST"];
    [op1 addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSString *st = [completedOperation responseString];
        st =[st stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@"  "];
        NSDictionary *ancmt = [NSJSONSerialization JSONObjectWithData:[st dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        content.frame = CGRectMake(20, title.frame.size.height + title.frame.origin.y + 10, 280, 800);
        [content setNumberOfLines:0];
        content.text = ancmt[__CONTENT__];
        [content sizeToFit];
        author.frame = CGRectMake(20, content.frame.size.height + 75, 280, 30);
        author.text = ancmt[__AUTHOR__];
        date.frame = CGRectMake(20, author.frame.size.height + author.frame.origin.y, 280, 30);
        date.text = ancmt[__CREATE_TIME__];
        other.frame = CGRectMake(20, 10 + date.frame.size.height + date.frame.origin.y, 300, 30);
        view2.frame = CGRectMake(0, 10 + other.frame.size.height + other.frame.origin.y, 320, [objects count] * 30);
    }errorHandler:nil];
    [engine1 enqueueOperation:op1];
    [tableView1 scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}
@end
