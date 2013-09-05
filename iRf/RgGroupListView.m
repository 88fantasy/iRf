//
//  RgGroupListView.m
//  iRf
//
//  Created by pro on 12-11-30.
//
//

#import "iRfRgService.h"
#import "SBJson.h"
#import "RgGroupListView.h"
#import "MBProgressHUD.h"

@interface RgGroupListView ()

@end

static NSString *kCellIdentifier = @"MyIdentifier";


@implementation RgGroupListView
@synthesize menuList,objs,searchObj;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"收货汇总查询";
        
        if (GetSystemVersion >= 6.0){
            UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
            refresh.tintColor = [UIColor lightGrayColor];
            refresh.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Pull down to refresh...", @"Pull down to refresh status")] ;
            [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
            self.refreshControl = refresh;
        }
        else {
            if (_refreshHeaderView == nil) {
                EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.view.bounds.size.height, self.view.frame.size.width, self.view.bounds.size.height)];
                view.delegate = self;
                [self.view addSubview:view];
                _refreshHeaderView = view;
                
            }
            //  update the last update date
            [_refreshHeaderView refreshLastUpdatedDate];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    titleFontSize = 20;
    detailFontSize = 17;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *searchbtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch                                                                          target:self action:@selector(setSearchJson:)];
    
    UIBarButtonItem *actionbtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize                                                                          target:self action:@selector(groupAction)];
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: searchbtn,actionbtn,nil] animated:YES];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections
    return [self.menuList count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (UIInterfaceOrientationIsPortrait(orientation)&& !IsPad) {
        return [[self.menuList objectAtIndex:section] objectForKey:@"goodsname"];
    }
    else {
        NSDictionary *sectionboj = [self.menuList objectAtIndex:section] ;
        NSArray *array = [sectionboj objectForKey:@"array"];
        int total = 0;
        for (int i=0; i<[array count]; i++) {
            NSDictionary *row = [array objectAtIndex:i];
            total += [[row objectForKey:@"goodsqty"] integerValue];
        }
        NSString *title = [NSString stringWithFormat:@"%@  %@ %@ %d%@",
                           [sectionboj objectForKey:@"goodsname"],
                           [sectionboj objectForKey:@"goodstype"],
                           [sectionboj objectForKey:@"cusgdsid"],
                           total,
                           [sectionboj objectForKey:@"goodsunit"]];
        return title;
    }

}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
//    
//    
//    
//    UIView* customView = [[UIView alloc] init];
//    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//    headerLabel.backgroundColor = [UIColor clearColor];
//    headerLabel.opaque = YES;
//    headerLabel.textColor = [UIColor whiteColor];
    
//    headerLabel.highlightedTextColor = [UIColor whiteColor];
    
//    headerLabel.shadowColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.25f];
//    headerLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
    
//    headerLabel.font = [UIFont boldSystemFontOfSize:20];
//    headerLabel.frame = CGRectMake(10.0, 0.0, 232.0,40.0);
//    
//    if (UIInterfaceOrientationIsPortrait(orientation)) {
//        headerLabel.numberOfLines=2;
//        headerLabel.text= [[self.menuList objectAtIndex:section] objectForKey:@"goodsname"];
//    }
//    else {
//        headerLabel.numberOfLines=1;
//        NSDictionary *sectionboj = [self.menuList objectAtIndex:section] ;
//        headerLabel.text= [NSString stringWithFormat:@"%@  %@ %@",
//                           [sectionboj objectForKey:@"goodsname"],
//                           [sectionboj objectForKey:@"goodstype"],
//                           [sectionboj objectForKey:@"cusgdsid"] ];
//    }
//    
//    [customView setBackgroundColor:[UIColor colorWithRed:0.64f green:0.68f blue:0.72f alpha:1.0f]];
//    [customView addSubview:headerLabel];
//    
//    return  customView;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSArray *array = [[self.menuList objectAtIndex:section] objectForKey:@"array"];
    return [array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = [[self.menuList objectAtIndex:indexPath.section] objectForKey:@"array"];
    
    NSDictionary *obj = [array objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier] ;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
    
//    NSString *goodsname = [obj objectForKey:@"goodsname"];
    NSString *goodstype = [obj objectForKey:@"goodstype"];
    NSString *goodsqty = [obj objectForKey:@"goodsqty"];
    NSString *goodsunit = [obj objectForKey:@"goodsunit"];
    NSString *factdoc = [obj objectForKey:@"factdoc"];
    NSString *socompanyname = [obj objectForKey:@"socompanyname"];
    NSString *uvender = [obj objectForKey:@"uvender"];
    NSString *lotno = [obj objectForKey:@"lotno"];
    NSString *invno = [obj objectForKey:@"invno"];
    NSString *unitprice = [obj objectForKey:@"invprice"];
    NSString *retailprice = [obj objectForKey:@"retailprice"];
    NSString *total = [obj objectForKey:@"invttl"];
    
    NSString *title;
    NSString *detail;
    
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (UIInterfaceOrientationIsPortrait(orientation)&& !IsPad) {
        title = [NSString stringWithFormat:@"%@   %@%@",goodstype,goodsqty,goodsunit];
        detail = [NSString stringWithFormat:@"单价:%@  总价:%@ 零售价:%@\n批号:%@  发票号:%@\n厂牌:%@\n供应商:%@\n客户:%@",unitprice,total,retailprice,lotno,invno,factdoc,uvender,socompanyname ];
        
        
    }
    else {
        title = [NSString stringWithFormat:@"%@%@   单价:%@  总价:%@ 零售价:%@",goodsqty,goodsunit,unitprice,total,retailprice];
        detail = [NSString stringWithFormat:@"批号:%@  发票号:%@\n厂牌:%@   供应商:%@\n客户:%@",lotno,invno,factdoc,uvender,socompanyname ];
    }
	cell.textLabel.text = title;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    [cell.textLabel setFont: [UIFont fontWithName:@"Heiti SC" size:titleFontSize]];
    cell.detailTextLabel.text = detail;
    [cell.textLabel setFont: [UIFont fontWithName:@"Heiti SC" size:detailFontSize]];
    cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    
    
    return cell;
}

#pragma mark rorate methods
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation) && !IsPad) {
        self.tableView.rowHeight = 150;
    }
    else {
        self.tableView.rowHeight = 100;
    }
    [self reload];
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}


- (void) reload {
    
    self.menuList = [NSMutableArray array];
    if (objs != nil) {
        
        for (int i=0; i<[objs count]; i++) {
            NSDictionary *obj = [objs objectAtIndex:i];
//            NSString *said = [obj objectForKey:@"said"];
            NSString *ugoodsid = [obj objectForKey:@"ugoodsid"];
            NSString *goodsname = [obj objectForKey:@"goodsname"];
            NSString *goodstype = [obj objectForKey:@"goodstype"];
//            NSString *goodsqty = [obj objectForKey:@"goodsqty"];
            NSString *goodsunit = [obj objectForKey:@"goodsunit"];
//            NSString *prodarea = [obj objectForKey:@"prodarea"];
            NSString *cusgdsid = [obj objectForKey:@"cusgdsid"];
            
            int j=0;
            for (; j<[self.menuList count]; j++) {
                if ([ugoodsid isEqualToString:[[self.menuList objectAtIndex:j] objectForKey:@"ugoodsid"]]) {
                    break;
                }
            }
            if (j==[self.menuList count]) {
                NSMutableArray *array = [NSMutableArray arrayWithObject:obj];
                NSDictionary *sa = [NSDictionary dictionaryWithObjectsAndKeys:
                                    ugoodsid,@"ugoodsid",
                                    goodsname,@"goodsname",
                                    goodstype,@"goodstype",
                                    cusgdsid,@"cusgdsid",
                                    goodsunit,@"goodsunit",
                                    array,@"array",
                                    nil];
                [self.menuList addObject:sa];
            }
            else{
                NSMutableArray *array = [[self.menuList objectAtIndex:j] objectForKey:@"array"];
                [array addObject:obj];
            }
        
            
        }
        
    }
    [self.tableView reloadData];
    [self doneLoadingTableViewData];
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    //  put here just for demo
    _reloading = YES;
    
    [self getAllRgGroup];
}

- (void)doneLoadingTableViewData{
    
    //  model should call this when its done loading
    _reloading = NO;
    if (GetSystemVersion >= 6.0){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm:ss a"];
        NSString *lastUpdated = [NSString stringWithFormat:@"%@ on %@",NSLocalizedString(@"Last Updated", @"Last Updated"), [formatter stringFromDate:[NSDate date]]];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated] ;
        
        
        [self.refreshControl endRefreshing];
    }
    else {
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    }
    
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.0];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}


#pragma mark -
#pragma mark RgListSearchViewDelegate Methods
- (void) setSearchJson:(id)sender{
    RgListSearchView *rsv = [[RgListSearchView alloc] initWithNibName:@"RgListSearchView" bundle:nil];
    rsv.rgListSearchViewDelegate = self;
    [self.navigationController pushViewController:rsv animated:YES];
    
    NSString *goodspy = [self.searchObj objectForKey:@"goodspy"];
    if (goodspy != nil && ![@"" isEqualToString:goodspy]) {
        rsv.goodspy.text = [goodspy stringByReplacingOccurrencesOfString:@"%" withString:@""];
    }
    NSString *goodsname = [self.searchObj objectForKey:@"goodsname"];
    if (goodsname != nil && ![@"" isEqualToString:goodsname]) {
        rsv.goodsname.text = [goodsname stringByReplacingOccurrencesOfString:@"%" withString:@""];
    }
    
    NSString *prodarea = [self.searchObj objectForKey:@"prodarea"];
    if (prodarea != nil && ![@"" isEqualToString:prodarea]) {
        rsv.prodarea.text = [prodarea stringByReplacingOccurrencesOfString:@"%" withString:@""];
    }
    
    NSString *uvender = [self.searchObj objectForKey:@"uvender"];
    if (uvender != nil && ![@"" isEqualToString:uvender]) {
        rsv.vender.text = [uvender stringByReplacingOccurrencesOfString:@"%" withString:@""];
    }
    
    rsv.lotno.text = [self.searchObj objectForKey:@"lotno"];
    rsv.invno.text = [self.searchObj objectForKey:@"invno"];
    rsv.startdate.text = [self.searchObj objectForKey:@"startdate"];
    rsv.enddate.text = [self.searchObj objectForKey:@"enddate"];
    
    NSString *rgflag = [self.searchObj objectForKey:@"rgflag"];
    if (rgflag == nil) {
        [rsv.rgflag setSelectedSegmentIndex:0];
    }
    else if ([rgflag isEqualToString:@"1"]){
        [rsv.rgflag setSelectedSegmentIndex:2];
    }
    else {
        [rsv.rgflag setSelectedSegmentIndex:1];
    }
    NSString *fuzzy = [self.searchObj objectForKey:@"isFuzzy"];
    if ([@"1" isEqualToString:fuzzy]) {
        [rsv.fuzzy setOn:YES];
    }
    else {
        [rsv.fuzzy setOn:NO];
    }
}

-(void)searchCallBack:(NSDictionary *)_fields{
    self.searchObj = _fields;
    [self getAllRgGroup];
}

#pragma mark -
#pragma mark fetchDataFromServer Methods

- (void) getAllRgGroup{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // Set determinate mode
	hud.mode = MBProgressHUDModeIndeterminate;
	hud.labelText = @"Loading";
    hud.removeFromSuperViewOnHide = YES;
    
    
   
    iRfRgService* service = [iRfRgService service];
    NSDictionary *setting = [CommonUtil getSettings];
    NSString *username = [setting objectForKey:kSettingUserKey];
    NSString *password = [setting objectForKey:kSettingPwdKey];
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *json = [writer stringWithObject:self.searchObj];
    [service getAllRgGroupJSON:self action:@selector(getAllRgGroupHandler:)
             username: username
             password: password
            queryjson:json
     ];
}

// Handle the response from getRg.

- (void) getAllRgGroupHandler: (id) value {
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
        NSError* result = (NSError*)value;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"连接失败"
                                                        message: [result localizedFailureReason]
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
	}
    
	// Handle faults
	else if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
        SoapFault * result = (SoapFault*)value;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"soap连接失败"
                                                        message: [result faultString]
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
	}
    
    
	// Do something with the NSString* result
    else{
        NSString* result = (NSString*)value;
        //	resultText.text = [@"getRg returned the value: " stringByAppendingString:result] ;
        NSLog(@"%@", result);
        
        
        
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        NSLog(@"%@",json);
        
        
        if (json != nil) {
            NSDictionary *ret = (NSDictionary*)json;
            NSString *retflag = (NSString*) [ret objectForKey:kRetFlagKey];
            
            if ([retflag boolValue]) {
                NSArray *rows = (NSArray*) [ret objectForKey:kMsgKey];
                self.objs = rows;
                [self reload];
            }
            else{
                NSString *msg = (NSString*) [ret objectForKey:kMsgKey];
                if ([msg isKindOfClass:[NSNull class]]) {
                    msg = @"空指针";
                }
                [CommonUtil alert:NSLocalizedString(@"Error", @"Error") msg:msg];
            }
            
        }
        else{
            
        }
    }
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

#pragma mark -
#pragma mark Group Actions

- (void) groupAction
{
    
}

#pragma mark -
#pragma mark - refresh handle

-(void)refreshView:(UIRefreshControl *)refresh
{
    if (refresh.refreshing) {
        refresh.attributedTitle = [[NSAttributedString alloc]initWithString:NSLocalizedString(@"Loading...", @"Loading Status")] ;
        
        [self getAllRgGroup];
        
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:2];
        
    }
}

@end
