//
//  RgListView.m
//  iRf
//
//  Created by pro on 11-7-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "iRfRgService.h"
#import "SBJson.h"
#import "RgListView.h"
#import "RgView.h"
#import "RootViewController.h"
#import "DbUtil.h"

static NSString *kCellIdentifier = @"MyIdentifier";
static NSString *kTitleKey = @"title";
static NSString *kExplainKey = @"explanation";
//static NSString *kViewControllerKey = @"viewController";
static NSString *kObjKey = @"obj";
static NSString *retFlagKey = @"ret";
static NSString *msgKey = @"msg";

@implementation RgListView

@synthesize menuList,objs,refreshButtonItem,activityView,activityIndicator,searchObj;
@synthesize goalBar,goalBarView;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"未收货列表";
        
     
        
        canReload = YES;
        if (_refreshHeaderView == nil) {
            
            EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
            view.delegate = self;
            [self.tableView addSubview:view];
            _refreshHeaderView = view;
            [view release];
            
        }
        
        //  update the last update date
        [_refreshHeaderView refreshLastUpdatedDate];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style objs:(NSArray*)_arrays
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        canReload = NO;
        self.objs = _arrays;
        
    }
    return self;
}

- (void)dealloc
{
    searchObj = nil;
    _refreshHeaderView=nil;
    [refreshButtonItem release];
    [activityView release];
    [activityIndicator release];
    [searchObj release];
    [menuList release];
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

- (void) getAllRg{
    
    [self displayActiveIndicatorView];
    
    if ([RootViewController isSync] ) {
        FMDatabase *db = [DbUtil retConnectionForResource:@"iRf" ofType:@"rdb"];
        if (db != nil) {
            
            NSString *sql = @"select * from scm_rg where rgflag in ('',0)";
            NSString *goodsname = [self.searchObj objectForKey:@"goodsname"];
            if (![goodsname isEqualToString:@""] && goodsname != nil) {
                sql = [sql stringByAppendingFormat:@" and goodsname like '%@%%'",goodsname];
            }
            NSString *prodarea = [self.searchObj objectForKey:@"prodarea"];
            if (![prodarea isEqualToString:@""] && prodarea != nil) {
                sql = [sql stringByAppendingFormat:@" and prodarea like '%@%%'",prodarea];
            }
            NSString *lotno = [self.searchObj objectForKey:@"lotno"];
            if (![lotno isEqualToString:@""] && lotno != nil) {
                sql = [sql stringByAppendingFormat:@" and lotno like '%@%%'",lotno];
            }
            NSString *invno = [self.searchObj objectForKey:@"invno"];
            if (![invno isEqualToString:@""] && invno != nil) {
                sql = [sql stringByAppendingFormat:@" and invno like '%@%%'",invno];
            }
            NSString *startdate = [self.searchObj objectForKey:@"startdate"];
            if (![startdate isEqualToString:@""] && startdate != nil) {
                sql = [sql stringByAppendingFormat:@" and credate >= date('%@')",startdate];
            }
            NSString *enddate = [self.searchObj objectForKey:@"enddate"];
            if (![enddate isEqualToString:@""] && enddate != nil) {
                sql = [sql stringByAppendingFormat:@" and credate <= date('%@')",enddate];
            }
            
            FMResultSet *rs = [db executeQuery:sql];
            NSMutableArray *rows =  [NSMutableArray array];
            while ([rs next]) {
                
                NSMutableDictionary *row =  [NSMutableDictionary dictionary];
                
                for (int i=0; i < [rs columnCount]; i++) {
                    NSString *key = [rs columnNameForIndex:i];
                    NSString *value = [rs stringForColumnIndex:i];
                    
                    if (value == nil) {
                        [row setObject:@"" forKey:key];
                    }
                    else {
                        [row setObject:value forKey:key];
                    }
                    
                }
                
                [rows addObject: row];
            }
            
            [db close];
            
            self.objs = rows;
            [self reload];
        }
        
        [self dismissActiveIndicatorView];
    }
    else{
        iRfRgService* service = [iRfRgService service];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *username = [defaults stringForKey:@"username_preference"];
        NSString *password = [defaults stringForKey:@"password_preference"];
        
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        NSString *json = [writer stringWithObject:self.searchObj];
        [service getAllRg:self action:@selector(getAllRgHandler:)
                 username: username
                 password: password
                queryjson:json
         ];
    }
}

- (void) resetBarbutton
{
    if (self.editing) {
        [self setEditing:NO animated:YES];
    }
    if (canReload) {
        
        UIBarButtonItem *searchbtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch                                                                          target:self action:@selector(setSearchJson:)];
        
        UIBarButtonItem *batchbtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize                                                                          target:self action:@selector(batchMode)];
        
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: searchbtn,batchbtn,nil] animated:YES];
        
        [searchbtn release];
        [batchbtn release];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    titleFontSize = 20;
    detailFontSize = 17;
    
    [self resetBarbutton];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSString *yesterday = [df stringFromDate:[NSDate dateWithTimeIntervalSinceNow:- 24 * 60 * 60 * 1]]  ;
    [df release];
    self.searchObj = [NSDictionary dictionaryWithObjectsAndKeys:
                      @"0",@"rgflag",
                      yesterday,@"startdate",
                      nil];
    [self reload];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.menuList = nil;
    self.objs = nil;
    _refreshHeaderView = nil;
    self.activityView = nil;
    self.refreshButtonItem = nil;
    self.activityIndicator = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    //填写你需要锁定的方向参数
    return UIInterfaceOrientationIsLandscape( interfaceOrientation ) || (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    // Return the number of sections.
//    return [menuList count];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    self.title = [NSString stringWithFormat:@"未收货列表 (%d)" ,[self.menuList count]] ;
    return [self.menuList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[[self.menuList objectAtIndex:indexPath.row] objectForKey:kCellIdentifier]];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[[self.menuList objectAtIndex:indexPath.row] objectForKey:kCellIdentifier]] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	cell.textLabel.text = [[self.menuList objectAtIndex:indexPath.row] objectForKey:kTitleKey];
    [cell.textLabel setFont: [UIFont fontWithName:@"Heiti SC" size:titleFontSize]];
    cell.detailTextLabel.text = [[self.menuList objectAtIndex:indexPath.row] objectForKey:kExplainKey];
    [cell.detailTextLabel setFont: [UIFont fontWithName:@"Heiti SC" size:detailFontSize]];
    cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
    
    NSDictionary *obj = [[self.menuList objectAtIndex:indexPath.row] objectForKey:kObjKey];
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    UIView *backgrdView = [[UIView alloc] initWithFrame:cell.frame];
    
    NSString *rfflag = (NSString*) [obj objectForKey:@"rgflag"];
    if ([rfflag intValue]==1) {
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
    // Navigation logic may go here. Create and push another view controller.
    
    
    if (![self isEditing]) { //非多选状态
        NSDictionary *obj = [[self.menuList objectAtIndex: indexPath.row] objectForKey:kObjKey];
        RgView* targetViewController = [[RgView alloc] initWithNibName:@"RgView" bundle:nil values:obj];
        //    targetViewController.scanViewDelegate = self;
        [[self navigationController] pushViewController:targetViewController animated:YES];
    }
   
    
}

#pragma mark -
#pragma mark UIViewController delegate

- (void)viewWillAppear:(BOOL)animated
{
    if (canReload &&
            ([self.tableView numberOfRowsInSection:0] == 0 || [RootViewController isSync]) ) {
        [self getAllRg];
    }
	// this UIViewController is about to re-appear, make sure we remove the current selection in our table view
	NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:tableSelection animated:YES];
    
    [self.tableView reloadData];
    
}


// Handle the response from getRg.

- (void) getAllRgHandler: (id) value {
    
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
            NSString *retflag = (NSString*) [ret objectForKey:retFlagKey];
            
            if ([retflag boolValue]) {
                NSArray *rows = (NSArray*) [ret objectForKey:msgKey];
                self.objs = rows;
                [self reload];
            }
            else{
                NSString *msg = (NSString*) [ret objectForKey:msgKey];
                if ([msg isKindOfClass:[NSNull class]]) {
                    msg = @"空指针";
                }
                [self alert:NSLocalizedString(@"Error", @"Error") msg:msg];
            }
            
        }
        else{
            
        }
    }
    if (canReload) {
        [self dismissActiveIndicatorView];
    }
    
}

- (void) reload {
    [self resetBarbutton];
    
    self.menuList = [NSMutableArray array];
    if (objs != nil) {
        
        for (int i=0; i<[objs count]; i++) {
            NSDictionary *obj = [objs objectAtIndex:i];
            NSString *text = [obj objectForKey:@"goodsname"];
            NSString *labeltype = [obj objectForKey:@"labeltype"];
            NSString *goodstype = [obj objectForKey:@"goodstype"];
            NSString *goodsqty = [obj objectForKey:@"goodsqty"];
            NSString *goodsunit = [obj objectForKey:@"goodsunit"];
            NSString *prodarea = [obj objectForKey:@"prodarea"];
            NSString *companyname = [obj objectForKey:@"socompanyname"];
            
            NSString *detailText = @"";
            if ([labeltype isEqualToString:@"1"]) {
                detailText = [detailText stringByAppendingString:@"原件"];
            }
            else{
                detailText = [detailText stringByAppendingString:@"散件"];
            }
            
            if (goodstype != nil) {
                detailText = [detailText stringByAppendingString:@"     "];
                detailText = [detailText stringByAppendingString:goodstype];
            }
            if (goodsqty != nil) {
                detailText = [detailText stringByAppendingString:@"     "];
                detailText = [detailText stringByAppendingString:goodsqty];
            }
            if (goodsunit != nil) {
                detailText = [detailText stringByAppendingString:goodsunit];
            }
            if (prodarea != nil) {
                detailText = [detailText stringByAppendingString:@"     "];
                detailText = [detailText stringByAppendingString:prodarea];
            }
            if (companyname != nil) {
                detailText = [detailText stringByAppendingString:@"     "];
                detailText = [detailText stringByAppendingString:companyname];
            }
            
            
            
            NSString *idv = [obj objectForKey:@"spdid"];
            
            [self.menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                      text, kTitleKey,
                                      detailText, kExplainKey,
                                      obj,kObjKey,
                                      idv,kCellIdentifier,
                                      nil]];
            
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
    
    [self getAllRg];
}

- (void)doneLoadingTableViewData{
    
    //  model should call this when its done loading
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    
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

- (IBAction) setSearchJson:(id)sender{
    RgListSearchView *rsv = [[RgListSearchView alloc] initWithNibName:@"RgListSearchView" bundle:nil];
    rsv.rgListSearchViewDelegate = self;
    [self.navigationController pushViewController:rsv animated:YES];
    
    rsv.goodsname.text = [self.searchObj objectForKey:@"goodsname"];
    rsv.prodarea.text = [self.searchObj objectForKey:@"prodarea"];
    rsv.lotno.text = [self.searchObj objectForKey:@"lotno"];
    rsv.invno.text = [self.searchObj objectForKey:@"invno"];
    rsv.startdate.text = [self.searchObj objectForKey:@"startdate"];
    rsv.enddate.text = [self.searchObj objectForKey:@"enddate"];
    
    [rsv release];
}

-(void)searchCallBack:(NSDictionary *)_fields{
    self.searchObj = _fields;
    [self getAllRg];
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

- (void) batchMode
{
    UIBarButtonItem *cancelbtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel                                                                          target:self action:@selector(resetBarbutton)];
    
    UIBarButtonItem *confirmbtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone                                                                          target:self action:@selector(batchConfirm:)];
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: confirmbtn,cancelbtn,nil] animated:YES];
    
    [cancelbtn release];
    [confirmbtn release];
    if (!self.editing) {
        [self setEditing:YES animated:YES];
    }

}

- (void) batchConfirm:(UIBarButtonItem *)sender
{
    NSArray *rows = [self.tableView indexPathsForSelectedRows];
    if (rows.count>0) {
        UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"请选择对这%d条记录进行的操作",rows.count]
                                                        delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                          destructiveButtonTitle:@"批量收货"
                                               otherButtonTitles:nil, nil];
        [as showFromBarButtonItem:sender animated:YES];
        [as release];
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        NSArray *rows = [self.tableView indexPathsForSelectedRows];
        notDoRgCount = rows.count;
        doneDoRgCoount = 0;
        
        [self displayGoalBarView:0];
        iRfRgService* service = [iRfRgService service];
        //    service.logging = YES;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *username = [defaults stringForKey:@"username_preference"];
        NSString *password = [defaults stringForKey:@"password_preference"];
        
        for (int i=0; i<notDoRgCount; i++) {
            NSIndexPath *indexPath = [rows objectAtIndex:i];
            NSLog(@"%d",indexPath.row);
            
            if (objs!=nil) {
                NSDictionary *obj =  [objs objectAtIndex:indexPath.row];
                NSString *spdid = [obj objectForKey:@"spdid"];
                NSString *rgqty = [obj objectForKey:@"rgqty"];
                NSString *locno = [obj objectForKey:@"locno"];
                
                [service doRg:self
                       action:@selector(doRgHandler:)
                     username: username
                     password: password
                        splid: spdid
                        rgqty: rgqty
                        locno: locno];
                
                if ([RootViewController isSync]) {
                    FMDatabase *db = [DbUtil retConnectionForResource:@"iRf" ofType:@"rdb"];
                    if(db != nil) {
                        [db executeUpdate:@"update scm_rg set rgqty = ?,locno = ?,rgflag = 1 where spdid = ?", rgqty, locno, spdid];
                        [db close];
                    }
                }
            }
            
            
            [goalBar setPercent:doneDoRgCoount/notDoRgCount * 100 animated:YES];
        }
        
    }
    
    [self resetBarbutton];
}

- (void)doRgHandler:(id)value {
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
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
        SoapFault * result = (SoapFault*)value;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"soap连接失败"
                                                        message: [result faultString]
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
    
    
	// Do something with the NSString* result
    NSString* result = (NSString*)value;
	NSLog(@"doRg returned the value: %@", result);
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    id retObj = [parser objectWithString:result];
    NSLog(@"%@",retObj);
    [parser release];
    
    doneDoRgCoount ++;
    if (doneDoRgCoount >= notDoRgCount) {
        [self dismissGoalBarView];
        [self reloadTableViewDataSource];
    }
    else {
        int percent = doneDoRgCoount * 100 / notDoRgCount ;
        [self displayGoalBarView:percent];
    }
    
    if (retObj != nil) {
        NSDictionary *ret = (NSDictionary*)retObj;
        NSString *retflag = (NSString*) [ret objectForKey:retFlagKey];
        
        if ([retflag boolValue]==YES) {
            NSDictionary *msg = (NSDictionary*) [ret objectForKey:msgKey];
            NSString *spdid = (NSString*) [msg objectForKey:@"spdid"];
            if ([RootViewController isSync]) {
                FMDatabase *db = [DbUtil retConnectionForResource:@"iRf" ofType:@"rdb"];
                if(db != nil) {
                    [db executeUpdate:@"update scm_rg set rgdate = datetime('now') where spdid = ?",spdid];
                    [db close];
                }
            }
            
        }
        else{
            NSString *msg = (NSString*) [ret objectForKey:msgKey];
            if ([msg isKindOfClass:[NSNull class]]) {
                msg = @"空指针";
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                            message: msg
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
        
    }
    else{
        
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"commit");
}

//显示等待进度条
- (void) displayGoalBarView:(int)percent {
    if (goalBarView==nil){
        goalBarView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Loading...",@"Loading...")
                                                 message: @"\n\n\n\n\n\n\n"  //放大进度条显示区域
                                                delegate: self
                                       cancelButtonTitle: nil
                                       otherButtonTitles: nil];
        
        goalBar = [[KDGoalBar alloc] initWithFrame:CGRectMake(60.f, 55.0f, 177.0f, 177.0f)];
        [goalBar setAllowDragging:NO];
        [goalBar setAllowSwitching:NO];
        [goalBar setPercent:0 animated:NO];
        [goalBar setAllowTap:NO];
        [goalBarView addSubview:goalBar];
    }
    if (!goalBarView.isVisible) {
        [goalBarView show];
    }
    [goalBar setPercent:percent animated:YES];
    
}

//取消等待进度条
- (void) dismissGoalBarView
{
    if (goalBarView)
    {
        [goalBarView dismissWithClickedButtonIndex:0 animated:YES];
    }
}
@end
