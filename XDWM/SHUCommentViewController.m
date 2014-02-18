//
//  SHUCommentViewController.m
//  XDWM
//
//  Created by 王澍宇 on 14-2-10.
//  Copyright (c) 2014年 WeAround. All rights reserved.
//

#import "SHUCommentViewController.h"
#import "MKNetworkEngine.h"
#import "SHUCommentCell.h"
#import "SHUCommentModel.h"
#import "ADDRMACRO.h"
#import "MJRefresh.h"

#define kPullComment   @"10"
#define kPullBegin     @"0"
#define kDeltaPull     @"15"

@interface SHUCommentViewController ()

@property (strong, nonatomic) MKNetworkEngine *engine;
@property (strong, nonatomic) NSMutableDictionary *commentDic;

@property (strong, nonatomic) NSMutableArray *users;
@property (strong, nonatomic) NSMutableArray *contents;
@property (strong, nonatomic) NSMutableArray *dates;

@property (nonatomic) NSInteger refreshCount;

@property (strong, nonatomic) MJRefreshHeaderView *header;
@property (strong, nonatomic) MJRefreshFooterView *footer;

@end

@implementation SHUCommentViewController

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
    
    _users = [[NSMutableArray alloc] init];
    _contents = [[NSMutableArray alloc] init];
    _dates = [[NSMutableArray alloc] init];
    
    self.footer = [MJRefreshFooterView footer];
    self.footer.scrollView  = self.tableView;
    
    self.header = [MJRefreshHeaderView header];
    self.header.scrollView = self.tableView;
    
    __weak SHUCommentViewController *weak_self = self;
    
    weak_self.footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView){
        
        ++_refreshCount;
        
        NSInteger valueForKey2 = _refreshCount * [kDeltaPull integerValue];
        NSNumber *valeForKey2_Object = [NSNumber numberWithInteger:valueForKey2];
        
        NSDictionary *postParams = @{@"key1" : kPullComment,
                                     @"key2" : [valeForKey2_Object stringValue]};
        
        MKNetworkOperation *op = [_engine operationWithPath:[NSString stringWithFormat:@"%@%@",__PHPDIR__,@"messageboard.php"] params:postParams httpMethod:@"POST"];
        
        [op addCompletionHandler:^(MKNetworkOperation *compeletedOpearation){
            
            NSDictionary *returnDic = [compeletedOpearation responseJSON];
            
            //        NSLog(@"%@",compeletedOpearation.responseString);
            
            if (returnDic) {
                _commentDic = [returnDic mutableCopy];
                
                for (int i = 0; i < [[_commentDic allKeys] count]; ++i) {
                    
                    NSDictionary *dic = [_commentDic objectForKey:[NSString stringWithFormat:@"%d",i]];
                    
                    NSString *user = [dic objectForKey:__USER_NAME__];
                    NSString *content = [dic objectForKey:__CONTENT__];
                    NSString *date = [dic objectForKey:__CREATETIME__];
                    
                    [_users addObject:user];
                    [_contents addObject:content];
                    [_dates addObject:date];
                }
                
                [refreshView endRefreshing];
                [self.tableView reloadData];
            }
            
        }errorHandler:^(MKNetworkOperation *completedOpeation, NSError *error){
            
            NSLog(@"%@",error);
            
        }];
        
        [_engine enqueueOperation:op];
        
    };
    
    weak_self.header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView){
        
        NSDictionary *postParams = @{@"key1" : kPullComment,
                                     @"key2" : kPullBegin};
        
        MKNetworkOperation *op2 = [_engine operationWithPath:[NSString stringWithFormat:@"%@%@",__PHPDIR__,@"messageboard.php"] params:postParams httpMethod:@"POST"];
        
        [op2 addCompletionHandler:^(MKNetworkOperation *compeletedOpearation){
            
            NSDictionary *returnDic = [compeletedOpearation responseJSON];
            
            //        NSLog(@"%@",compeletedOpearation.responseString);
            
            if (returnDic) {
                _commentDic = [returnDic mutableCopy];
                
                NSDictionary *dic = [_commentDic objectForKey:@"0"];
                
                NSString *user = [dic objectForKey:__USER_NAME__];
                NSString *content = [dic objectForKey:__CONTENT__];
                NSString *date = [dic objectForKey:__CREATETIME__];
                
                if (![_contents[0] isEqualToString:content] && ![_dates[0] isEqualToString:date]) {
                    [_users insertObject:user atIndex:0];
                    [_contents insertObject:content atIndex:0];
                    [_dates insertObject:date atIndex:0];
                }
                
                [refreshView endRefreshing];
                [self.tableView reloadData];
            }
            
        }errorHandler:^(MKNetworkOperation *completedOpeation, NSError *error){
            
            NSLog(@"%@",error);
            
        }];
        
        [_engine enqueueOperation:op2];
        
    };
    
    
    
    
    NSDictionary *postParams = @{@"key1" : kPullComment,
                                 @"key2" : kPullBegin};
    
    _engine = [[MKNetworkEngine alloc] initWithHostName:__HOSTNAME__];
    
    MKNetworkOperation *op = [_engine operationWithPath:[NSString stringWithFormat:@"%@%@",__PHPDIR__,@"messageboard.php"] params:postParams httpMethod:@"POST"];
    
    [op addCompletionHandler:^(MKNetworkOperation *compeletedOpearation){
        
        NSDictionary *returnDic = [compeletedOpearation responseJSON];
        
        //        NSLog(@"%@",compeletedOpearation.responseString);
        
        if (returnDic) {
            _commentDic = [returnDic mutableCopy];
            
            for (int i = 0; i < [[_commentDic allKeys] count]; ++i) {
                
                NSDictionary *dic = [_commentDic objectForKey:[NSString stringWithFormat:@"%d",i]];
                
                NSString *user = [dic objectForKey:__USER_NAME__];
                NSString *content = [dic objectForKey:__CONTENT__];
                NSString *date = [dic objectForKey:__CREATETIME__];
                
                [_users addObject:user];
                [_contents addObject:content];
                [_dates addObject:date];
            }
            
            [self.tableView reloadData];
        }
        
    }errorHandler:^(MKNetworkOperation *completedOpeation, NSError *error){
        
        NSLog(@"%@",error);
        
    }];
    
    [_engine enqueueOperation:op];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MJRefresh

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SHUCommentCell *cell = (SHUCommentCell *)[tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    
    cell.commentContent.text = [_contents objectAtIndex:indexPath.row];
    //    [cell.commentContent sizeToFit];
    
    cell.userName.text = [_users objectAtIndex:indexPath.row];
    //    [cell.userName sizeToFit];
    
    cell.createTime.text = [_dates objectAtIndex:indexPath.row];
    //    [cell.createTime sizeToFit];
    
    CGRect r = cell.frame;
    r.size.height = 0 + cell.commentContent.frame.size.height + cell.userName.frame.size.height + cell.createTime.frame.size.height;
    cell.frame = r;
    
    //    NSLog(@"%@",NSStringFromCGSize(cell.frame.size));
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}



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
