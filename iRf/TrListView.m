//
//  NtrListView.m
//  iRf
//
//  Created by user on 11-8-30.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "TrListView.h"
#import "iRfRgService.h"
#import "SBJson.h"
#import "TrView.h"
#import "POAPinyin.h"

static NSString *kCellIdentifier = @"MyIdentifier";
static NSString *kTitleKey = @"title";
static NSString *kExplainKey = @"explanation";
static NSString *kObjKey = @"obj";


@implementation TrListView

@synthesize menuList,refreshButtonItem,activityView,activityIndicator;
@synthesize tablelistView,filteredListContent, savedSearchTerm, savedScopeButtonIndex, searchWasActive;
@synthesize titleSegmentIndex,titleArray,titleBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.prompt = @"货品对应关系";
        
        if (_refreshHeaderView == nil) {
            self.tablelistView  = (UITableView*)self.view;
            EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.view.bounds.size.height, self.view.frame.size.width, self.view.bounds.size.height)];
            view.delegate = self;
            [self.view addSubview:view];
            _refreshHeaderView = view;
            [view release];
            
        }
        
        if (self.refreshButtonItem == nil) {
            self.refreshButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh                                                                          target:self action:@selector(scrollToRefresh:)];
            
        }
        
        self.navigationItem.rightBarButtonItem = self.refreshButtonItem;
        
        //  update the last update date
        [_refreshHeaderView refreshLastUpdatedDate];
    }
    return self;
}

- (void)dealloc
{
    _refreshHeaderView=nil; 
    [refreshButtonItem release];
    [activityView release];
    [activityIndicator release];
    [tablelistView release];
    [filteredListContent release];
    [menuList release];
    [titleArray release];
    [titleBtn release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) alert:(NSString*)title msg:(NSString*)msg {
    // open an alert with just an OK button
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];	
    [alert release];
}

//显示等待进度条
- (void) displayActiveIndicatorView
{
    //    self.navigationItem.rightBarButtonItem = nil;
    if (activityView==nil){        
        activityView = [[UIAlertView alloc] initWithTitle:nil 
                                                  message: NSLocalizedString(@"Loading...",@"Loading...")
                                                 delegate: self
                                        cancelButtonTitle: nil
                                        otherButtonTitles: nil];
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator.frame = CGRectMake(120.f, 48.0f, 38.0f, 38.0f);
        [activityView addSubview:activityIndicator];
    }
    [activityIndicator startAnimating];
    [activityView show];
    
}

//取消等待进度条
- (void) dismissActiveIndicatorView
{
    if (activityView)
    {
        [activityIndicator stopAnimating];
        [activityView dismissWithClickedButtonIndex:0 animated:YES];
    }
}

- (void) getTrGds{
    
    [self displayActiveIndicatorView];
    
    iRfRgService* service = [iRfRgService service];
    NSDictionary *setting = [CommonUtil getSettings];
    NSString *username = [setting objectForKey:kSettingUserKey];
    NSString *password = [setting objectForKey:kSettingPwdKey];
    
    [service getTrGds:self action:@selector(getTrGdsHandler:) 
             username: username 
             password: password
             page:0];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    
    //增加未维护客户码和货位的过滤项
    
    self.titleArray = [NSArray arrayWithObjects:@"全部",@"无客户码", @"无货位", @"无基本码",nil];
    titleSegmentIndex = 0;
//	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
//	segmentedControl.selectedSegmentIndex = 0;
//	segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
////	segmentedControl.frame = CGRectMake(0, 0, 400, kCustomButtonHeight);
//	[segmentedControl addTarget:self action:@selector(switchSegment:) forControlEvents:UIControlEventValueChanged];
//	
////	defaultTintColor = [segmentedControl.tintColor retain];	// keep track of this for later
//    
//	self.navigationItem.titleView = segmentedControl;
//	[segmentedControl release];
    
    self.titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.titleBtn setTitle:@"全部▾" forState:UIControlStateNormal];    
    [self.titleBtn addTarget:self action:@selector(showConditionList) forControlEvents:UIControlEventTouchUpInside];
    self.titleBtn.frame = CGRectMake(0, 0, 200, 31);
    [self.titleBtn setCenter:self.navigationItem.titleView.center];
    self.navigationItem.titleView = self.titleBtn;
//    [testbtn release];
	
	// restore search settings if they were saved in didReceiveMemoryWarning.
    if (self.savedSearchTerm)
	{
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
	self.searchDisplayController.searchBar.placeholder = NSLocalizedString(@"Search", @"Search");
	[self.tablelistView reloadData];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.filteredListContent = nil;
    self.menuList = nil;
    _refreshHeaderView = nil;
    self.activityView = nil;
    self.refreshButtonItem = nil;
    self.activityIndicator = nil;
    self.tablelistView = nil;
    self.titleArray = nil;
    self.titleBtn = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    //填写你需要锁定的方向参数
    return UIInterfaceOrientationIsLandscape( interfaceOrientation ) || (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSDictionary *) tableView:(UITableView *)tableView rowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *row = nil;
    NSMutableArray *list = nil;
    NSInteger count = 0;
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        list =  self.filteredListContent;
    }
	else
	{
        list = self.menuList;
    }
    if (titleSegmentIndex == TrListTitleSegAll) {
        row = [list objectAtIndex:indexPath.row];
    }
    else {
        NSString *key = nil;
        if (titleSegmentIndex == TrListTitleSegNoCusid){
            key = @"cusgdsid";
        }
        else if (titleSegmentIndex == TrListTitleSegNoLocno){
            key = @"locno";        }
        else if (titleSegmentIndex == TrListTitleSegNoBasecode){
            key = @"basecode";
        }
        for (int i=0,j=list.count; i<j; i++) {
            NSDictionary *tmprow = [list objectAtIndex:i];
            NSDictionary *obj = [tmprow objectForKey:kObjKey];
            NSString *value = [obj objectForKey:key];
            if (value == nil || [@"" isEqualToString:value]) {
                if (indexPath.row == count) {
                    row = tmprow;
                    break;
                }
                count++;
            }
        }
    }
    return row;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSMutableArray *list = nil;
    NSInteger count = 0;
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        list =  self.filteredListContent;
    }
	else
	{
        list = self.menuList;
    }
    if (titleSegmentIndex == TrListTitleSegAll) {
        count =  [list count];
    }
    else{
        NSString *key = nil;
        if (titleSegmentIndex == TrListTitleSegNoCusid){
            key = @"cusgdsid";
        }
        else if (titleSegmentIndex == TrListTitleSegNoLocno){
            key = @"locno";        }
        else if (titleSegmentIndex == TrListTitleSegNoBasecode){
            key = @"basecode";
        }
        for (int i=0,j=list.count; i<j; i++) {
            NSDictionary *obj = [[list objectAtIndex:i] objectForKey:kObjKey];
            NSString *value = [obj objectForKey:key];
            if (value == nil || [@"" isEqualToString:value]) {
                count++;
            }
        }
    }
    self.navigationItem.prompt = [NSString stringWithFormat:@"货品对应关系(%d)",count] ;
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *row = [self tableView:tableView rowAtIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[row objectForKey:kCellIdentifier]];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[row objectForKey:kCellIdentifier]] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	cell.textLabel.text = [row objectForKey:kTitleKey];
    [cell.textLabel setFont: [UIFont fontWithName:@"Heiti SC" size:20]];
    cell.detailTextLabel.text = [row objectForKey:kExplainKey];
    cell.detailTextLabel.textAlignment = UITextAlignmentRight;
    
    NSDictionary *obj = [row objectForKey:kObjKey];
    
    NSString *cusgdsid = (NSString*) [obj objectForKey:@"cusgdsid"];
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    UIView *backgrdView = [[UIView alloc] initWithFrame:cell.frame];
    if ([cusgdsid isEqualToString:@""]|| (!IsInternet&&[cusgdsid rangeOfString:@"tmp" options:NSCaseInsensitiveSearch].location != NSNotFound)) {    
        backgrdView.backgroundColor = [UIColor greenColor];
    }
    else{
        backgrdView.backgroundColor = [UIColor whiteColor];
    }
    cell.backgroundView = backgrdView;
    [backgrdView release];
    return cell;
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
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

#pragma mark -
#pragma mark ScanView delegate
//-(void)confirmCallBack:(BOOL )_confirm  values:(NSDictionary *)_obj{
//    NSUInteger index = [self.objs indexOfObject:_obj];
//    NSDictionary *obj = [self.objs objectAtIndex:index];
//    [obj setValue:@"1" forKey:@"rgflag"];
//    [obj release];
//}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *row = [self tableView:tableView rowAtIndexPath:indexPath];
    // Navigation logic may go here. Create and push another view controller.
    
    NSDictionary *obj = [row objectForKey:kObjKey];
    TrView* targetViewController = [[TrView alloc] initWithNibName:@"TrView" bundle:nil values:obj];
    //    targetViewController.scanViewDelegate = self;
	[[self navigationController] pushViewController:targetViewController animated:YES];
    
}

#pragma mark -
#pragma mark UIViewController delegate

- (void)viewWillAppear:(BOOL)animated
{
    if (!_firstloaded) {
        [self getTrGds];
        _firstloaded = YES;
    }
    
	// this UIViewController is about to re-appear, make sure we remove the current selection in our table view
	NSIndexPath *tableSelection = [self.tablelistView indexPathForSelectedRow];
	[self.tablelistView deselectRowAtIndexPath:tableSelection animated:YES];
    
    [self.tablelistView reloadData];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    // save the state of the search UI so that it can be restored if the view is re-created
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
}

// Handle the response from getRg.

- (void) getTrGdsHandler: (id) value {
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
        NSError* result = (NSError*)value;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"连接失败" 
                                                        message: [result localizedFailureReason]
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
	}
    
	// Handle faults
	else if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
        SoapFault * result = (SoapFault*)value;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"soap连接失败" 
                                                        message: [result faultString]
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
	}				
    
    
	// Do something with the NSString* result
    else{
        NSString* result = (NSString*)value;
        //	resultText.text = [@"getRg returned the value: " stringByAppendingString:result] ;
        NSLog(@"%@", result);
        
        
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        id json = [parser objectWithString:result];
        
        [parser release];
        
        if (json != nil) {
            NSDictionary *ret = (NSDictionary*)json;
            NSString *retflag = (NSString*) [ret objectForKey:kRetFlagKey];
            
            if ([retflag boolValue]) {
                NSArray *rows = (NSArray*) [ret objectForKey:kMsgKey];
                NSUInteger count = [rows count];
                if (count <1) {
                    [self alert:@"提示" msg:@"没有找到货品关系"];
                }
                else{
                    
                    self.menuList = [NSMutableArray array];
                    
                    for (int i=0; i<[rows count]; i++) {
                        NSDictionary *obj = [rows objectAtIndex:i];
                        NSString *text = [obj objectForKey:@"goodsname"];
                    
                        NSString *detailText = [obj objectForKey:@"goodstype"];
                        detailText = [detailText stringByAppendingString:@"     "];
                        detailText = [detailText stringByAppendingString:[obj objectForKey:@"factno"]];
                        
                        NSString *idv = [obj objectForKey:@"ugoodsid"];
                        
                        [self.menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                  text, kTitleKey,
                                                  detailText, kExplainKey,
                                                  obj,kObjKey,
                                                  idv,kCellIdentifier,
                                                  nil]];
                    }
                    
                    
                    self.filteredListContent = [NSMutableArray arrayWithCapacity:[self.menuList count]];
                    
                    [self.tablelistView reloadData];
                    [self doneLoadingTableViewData];
                }
                
            }
            else{
                NSString *msg = (NSString*) [ret objectForKey:kMsgKey];
                if ([msg isKindOfClass:[NSNull class]]) {
                    msg = @"空指针";
                }
                [self alert:NSLocalizedString(@"Error",@"Error") msg:msg];
            }
            
        }
        else{
            
        }
    }
    [self dismissActiveIndicatorView];
    
}


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    //  put here just for demo
    _reloading = YES;
    
    [self getTrGds];
}

- (void)doneLoadingTableViewData{
    
    //  model should call this when its done loading
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tablelistView];
    
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollView != self.searchDisplayController.searchResultsTableView)
	{
       [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
    
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (scrollView != self.searchDisplayController.searchResultsTableView)
	{
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:4.0];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

- (IBAction) scrollToRefresh:(id)sender{
    
    [self getTrGds];
}


#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	[self.filteredListContent removeAllObjects]; // First clear the filtered array.
	
    
    NSString *searchKey = nil;
    if ([scope isEqualToString:@"规格"] )
    {
        searchKey = @"goodstype";
    }
    else if([scope isEqualToString:@"厂家"] )
    {
        searchKey = @"factno";
    }
    else if ([scope isEqualToString:@"货品码"]) {
        searchKey = @"cusgdsid";
    }
    else if ([scope isEqualToString:@"拼音"]) {
        searchKey = @"goodsname";
    }
    else{
        searchKey = @"goodsname";
    }
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
	for (NSDictionary *row in menuList)
	{
       
        NSString *field = [[row objectForKey:kObjKey] objectForKey:searchKey];
        NSUInteger result = NSNotFound;
        if ([scope isEqualToString:@"拼音"]) {
            NSString *pinyin = [POAPinyin quickConvert:field byConvertMode:POAPinyinConvertModeFirstWord];
            result = [pinyin  rangeOfString:[searchText uppercaseString]].location;
        }
        else{
            result = [field  rangeOfString:searchText].location;
        }
        if ( result != NSNotFound )
        {
            [self.filteredListContent addObject:row];
        }
        
	}
    [searchKey release];
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark -
#pragma mark  titleview segment action

- (IBAction)switchSegment:(id)sender
{
	// The segmented control was clicked, handle it here
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	titleSegmentIndex =  segmentedControl.selectedSegmentIndex;
    [self.tablelistView reloadData];
}


#pragma mark -
#pragma mark - LeveyPopListViewDelegate

- (void) showConditionList
{
    LeveyPopListView *lplv = [[LeveyPopListView alloc] initWithTitle:@"请选择筛选条件..." options:self.titleArray];
    lplv.delegate = self;
    [lplv showInView:self.view animated:YES];
    [lplv release];
    [self.titleBtn setEnabled:NO];
}

- (void)leveyPopListView:(LeveyPopListView *)popListView didSelectedIndex:(NSInteger)anIndex
{
    titleSegmentIndex =  anIndex;
    [self.titleBtn setTitle:[NSString stringWithFormat:@"%@▾",[self.titleArray objectAtIndex:anIndex]] forState:UIControlStateNormal];
    [self.tablelistView reloadData];
    [self.titleBtn setEnabled:YES];
}

- (void)leveyPopListViewDidCancel
{
    [self.titleBtn setEnabled:YES];
}

@end
