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

static NSString *kCellIdentifier = @"MyIdentifier";
static NSString *kTitleKey = @"title";
static NSString *kExplainKey = @"explanation";
//static NSString *kViewControllerKey = @"viewController";
static NSString *kObjKey = @"obj";
static NSString *retFlagKey = @"ret";
static NSString *msgKey = @"msg";

@implementation RgListView

@synthesize menuList,objs,refreshButtonItem,activityView,activityIndicator;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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
     _refreshHeaderView=nil; 
    [refreshButtonItem release];
    [activityView release];
    [activityIndicator release];
    [menuList release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

         
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    if (canReload) {
        if (self.refreshButtonItem == nil) {
            self.refreshButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh                                                                          target:self action:@selector(scrollToRefresh:)];
            
//            self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20,20)];
//            self.activityButtonItem = [[UIBarButtonItem alloc]initWithCustomView:activityIndicator] ;
//            self.activityButtonItem.style = UIBarButtonItemStyleBordered;
        }
       
        self.navigationItem.rightBarButtonItem = self.refreshButtonItem;
    }
    
    self.menuList = [NSMutableArray array];
    
    for (int i=0; i<[objs count]; i++) {
        NSDictionary *obj = [objs objectAtIndex:i];
        NSString *text = [obj objectForKey:@"goodsname"];
        NSString *labeltype = [obj objectForKey:@"labeltype"];
        
        
        NSString *detailText = @"";
        if ([labeltype isEqualToString:@"1"]) {
            detailText = [detailText stringByAppendingString:@"原件"];
        }
        else{
            detailText = [detailText stringByAppendingString:@"散件"];
        }
        
        detailText = [detailText stringByAppendingString:@"     "];
        detailText = [detailText stringByAppendingString:[obj objectForKey:@"goodstype"]];
        detailText = [detailText stringByAppendingString:@"     "];
        detailText = [detailText stringByAppendingString:[obj objectForKey:@"goodsqty"]];
        detailText = [detailText stringByAppendingString:@"     "];
        detailText = [detailText stringByAppendingString:[obj objectForKey:@"prodarea"]];
        
//        NSLog(@"%@",text);
//        NSLog(@"%@",detailText);
        
//        RgView* rgview = [[RgView alloc] initWithNibName:@"RgView" bundle:nil values:obj];
        
        [self.menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                  text, kTitleKey,
                                  detailText, kExplainKey,
//                                  rgview, kViewControllerKey,
                                  obj,kObjKey,
                                  nil]];
//        [obj release];
        
//        [rgview release];
    }
    
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    return [self.menuList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	cell.textLabel.text = [[self.menuList objectAtIndex:indexPath.row] objectForKey:kTitleKey];
    cell.detailTextLabel.text = [[self.menuList objectAtIndex:indexPath.row] objectForKey:kExplainKey];
    cell.detailTextLabel.textAlignment = UITextAlignmentRight;
    
    NSDictionary *obj = [[self.menuList objectAtIndex:indexPath.row] objectForKey:kObjKey];
    
    NSString *rfflag = (NSString*) [obj objectForKey:@"rgflag"];
    if ([rfflag intValue]==1) {
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        UIView *backgrdView = [[UIView alloc] initWithFrame:cell.frame];
        backgrdView.backgroundColor = [UIColor greenColor];
        cell.backgroundView = backgrdView;
        [backgrdView release];
    }
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
    
//    UIViewController *targetViewController = [[self.menuList objectAtIndex: indexPath.row] objectForKey:kViewControllerKey];
    NSDictionary *obj = [[self.menuList objectAtIndex: indexPath.row] objectForKey:kObjKey];
    RgView* targetViewController = [[RgView alloc] initWithNibName:@"RgView" bundle:nil values:obj];
//    targetViewController.scanViewDelegate = self;
	[[self navigationController] pushViewController:targetViewController animated:YES];
     
}

#pragma mark -
#pragma mark UIViewController delegate

- (void)viewWillAppear:(BOOL)animated
{
	// this UIViewController is about to re-appear, make sure we remove the current selection in our table view
	NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:tableSelection animated:YES];
    
    [self.tableView reloadData];
    
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
                                                  message: NSLocalizedString(@"Loading...","Loading...")
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
    
    
    
//    self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleBordered;
//    
//    [self.activityIndicator startAnimating];
    
    iRfRgService* service = [iRfRgService service];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults stringForKey:@"username_preference"];
    NSString *password = [defaults stringForKey:@"password_preference"];
    
    [service getAllRg:self action:@selector(getAllRgHandler:) 
             username: username 
             password: password];
    [self displayActiveIndicatorView];
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
		return;
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
		return;
	}				
    
    
	// Do something with the NSString* result
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
            NSUInteger count = [rows count];
            if (count <1) {
                [self alert:@"提示" msg:@"已完成所有收货"];
            }
            else if (count == 1) {
                NSDictionary *obj = (NSDictionary*)[rows objectAtIndex:0];
                RgView *rgView = [[RgView alloc] initWithNibName:@"RgView" bundle:nil values:obj ];
                //                    rgView.scanViewDelegate = self;
                [self.navigationController pushViewController:rgView animated:YES];
                [rgView release];
            }
            else{
                self.objs = rows;
                [self viewDidLoad];
                [self.tableView reloadData];
                [self doneLoadingTableViewData];
            }
                
        }
        else{
            NSString *msg = (NSString*) [ret objectForKey:msgKey];
            [self alert:@"错误" msg:msg];
        }
        
    }
    else{
        
    }
    
    if (canReload) {
//        [self.activityIndicator stopAnimating];
//        self.navigationItem.rightBarButtonItem = self.refreshButtonItem;
        [self dismissActiveIndicatorView];
    }
    
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
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:4.0];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

- (IBAction) scrollToRefresh:(id)sender{
    
    [self getAllRg];
}
@end
