#import "XinViewController.h"
#import "MJRefreshHeaderView.h"
#import "ANNOUNCEMEMNT.h"
#import "MKNetworkEngine.h"
#import "MKNetworkOperation.h"
#import "ADDRMACRO.h"

@interface XinViewController ()
@property (strong, nonatomic) IBOutlet UITableView *_tableView;
@property (strong, nonatomic) NSString *_identify;
@property (nonatomic, strong) MKNetworkEngine *_engine;
@property (strong ,nonatomic) IBOutlet UILabel *__title;
@property (strong ,nonatomic) IBOutlet UILabel *_content;
@property (strong ,nonatomic) IBOutlet UILabel *_date;
@property (strong ,nonatomic) IBOutlet UILabel *_author;
@property (strong, nonatomic) NSArray *_objects;
@property (strong, nonatomic) NSArray *_objects2;
@property (nonatomic, strong) MJRefreshHeaderView *_header;
@property CGRect _frame;

@end

@implementation XinViewController



- (void)viewDidLoad
{
    //文字文本背景设置
    self._tableView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
    [self._tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self._engine = [[MKNetworkEngine alloc] initWithHostName:__HOSTNAME__];
    self._identify = [[NSString alloc] init];
    self._identify = @"0";
    [self fetchDetail];
    self.__title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    self.__title.textAlignment = NSTextAlignmentCenter;
    self.__title.font = [UIFont boldSystemFontOfSize:30];
    self._content = [[UILabel alloc] init];
    self._author = [[UILabel alloc] init];
    self._author.textAlignment = NSTextAlignmentRight;
    self._date = [[UILabel alloc] init];
    self._date.textAlignment = NSTextAlignmentRight;
    
    //下拉刷新
    self._header = [MJRefreshHeaderView header];
    self._header.scrollView = self._tableView;
    self._header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        self._identify = @"0";
        [self fetchOtherInformData];
        [self fetchDetail];
        //[self._tableView reloadData];
//        [self performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:0];
    };
    [self._header beginRefreshing];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
    [refreshView endRefreshing];
}

- (void)dealloc{
    [self._header free];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//读取数据
- (void)fetchOtherInformData{
    //读取其他通知题目id
    NSDictionary *dicForPost1 = @{@"key1":@"20",@"key2":@"0"};
    MKNetworkOperation *op1 = [self._engine operationWithPath:[NSString stringWithFormat:@"%@%@", __PHPDIR__, @"fetch_ancmt.php"] params:dicForPost1 httpMethod:@"POST"];
    [op1 addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSString *st = [completedOperation responseString];
        st =[st stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
        NSDictionary *ancmt = [NSJSONSerialization JSONObjectWithData:[st dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        NSArray *array = [ancmt allValues];
        NSMutableArray *mutArray = [[NSMutableArray alloc] init];
        NSMutableArray *mutArray1 = [[NSMutableArray alloc] init];
        //        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 280, 44)];
        for (int i=0; i < [array count]; ++i) {
            NSDictionary *dic = [array objectAtIndex:i];
            NSString *str = dic[__TITLE__];
            [mutArray addObject:str];
            NSString *identity = dic[__ID__];
            [mutArray1 addObject:identity];
        }
        self._objects = mutArray;
        self._objects2 = mutArray1;
        //        labelTitle.textColor = [UIColor blueColor];
        //        labelTitle.text = [self._objects objectAtIndex:row];
        [self._header endRefreshing];
        [self._tableView reloadData];
    }errorHandler:nil];
    [self._engine enqueueOperation:op1];
}
- (void)fetchDetail{
    //读取通知详细内容
    NSDictionary *dicForPost1 = @{@"key1":@"10",@"key2":self._identify};
    MKNetworkOperation *op1 = [self._engine operationWithPath:[NSString stringWithFormat:@"%@%@", __PHPDIR__, @"fetch_ancmt.php"] params:dicForPost1 httpMethod:@"POST"];
    [op1 addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSString *st = [completedOperation responseString];
        st =[st stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@"  "];
        //NSLog(@"%@",st);
        NSDictionary *ancmt = [NSJSONSerialization JSONObjectWithData:[st dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        self.__title.text = ancmt[__TITLE__];
        self._content.frame = CGRectMake(20, self.__title.frame.size.height + self.__title.frame.origin.y + 10, 280, 800);
        [self._content setNumberOfLines:0];
        self._content.text = ancmt[__CONTENT__];
        [self._content sizeToFit];
        self._author.frame = CGRectMake(20, self._content.frame.size.height + 75, 280, 30);
        self._author.text = ancmt[__AUTHOR__];
        self._date.frame = CGRectMake(20, self._author.frame.size.height + self._author.frame.origin.y, 280, 30);
        self._date.text = ancmt[__CREATE_TIME__];
        self._frame = CGRectMake(0, 0, 0, self._date.frame.origin.y + self._date.frame.size.height + 10);
        
        if ([self._header isRefreshing]) {
            [self._header endRefreshing];
        }
        [self._tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        [self._tableView reloadData];
    }errorHandler:nil];
    [self._engine enqueueOperation:op1];
}

#pragma mark -
#pragma tableView Delegate And Data Sourse Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else return [self._objects count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* myView = [[UIView alloc] init];
    myView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 22)];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor colorWithRed:176/255.0 green:36/255.0 blue:40/255.0 alpha:1.0];
    if (section == 1){
        titleLabel.text = @"其他通知";
        titleLabel.font = [UIFont boldSystemFontOfSize:13];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [myView addSubview:titleLabel];
        return myView;
    }
    else{
        myView.backgroundColor = [myView.backgroundColor colorWithAlphaComponent:0.0];
       return myView;
    }
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 2.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = [indexPath section];
    if (section == 0) {
        return self._frame.size.height;
    }
    else
        return 35;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    if (section == 1) {
        self._identify = [self._objects2 objectAtIndex:row];
        [self fetchDetail];
        //[self._tableView reloadData];
      //  [self._tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];

    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    if (section == 0) {
        static NSString *CellTableIdentifier = @"CellTableIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellTableIdentifier];
            cell.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
        }
        //[self fetchDetail];
        cell.userInteractionEnabled = NO;
        [cell addSubview:self.__title];
        [cell addSubview:self._content];
        [cell addSubview:self._date];
        [cell addSubview:self._author];
        return cell;
    }
    else{
        static NSString *CellTableIdentifier = @"CellTableIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellTableIdentifier];
            cell.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
        }
        cell.textLabel.text = [self._objects objectAtIndex:row];
        cell.textLabel.textColor = [UIColor blueColor];
        return cell;
    }
}

@end
