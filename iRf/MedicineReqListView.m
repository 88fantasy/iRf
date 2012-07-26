//
//  MedicineReqListView.m
//  iRf
//
//  Created by xian weijian on 12-7-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MedicineReqListView.h"
#import "iRfRgService.h"
#import "SBJson.h"
#import "MedicineReqCell.h"

static NSString *kCellIdentifier = @"MedicineReqCellIdentifier";
static NSString *kTitleKey = @"title";
static NSString *kExplainKey = @"explanation";
static NSString *kObjKey = @"obj";
static NSString *retFlagKey = @"ret";
static NSString *msgKey = @"msg";


@implementation MedicineReqListView

@synthesize dataList,activityView,activityIndicator;

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"领药列表";
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Apply",@"Apply") style:UIBarButtonItemStyleBordered target:self action:@selector(reqConfirm)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
    
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.view.bounds.size.height, self.view.frame.size.width, self.view.bounds.size.height)];
        view.delegate = self;
        [self.view addSubview:view];
        _refreshHeaderView = view;
        [view release];
        
    }
    
    //  update the last update date
    [_refreshHeaderView refreshLastUpdatedDate];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.dataList = nil;
    self.activityView = nil;
    self.activityIndicator = nil;
    
}


- (void) getReqList
{
    [self displayActiveIndicatorView];
    
    iRfRgService* service = [iRfRgService service];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults stringForKey:@"username_preference"];
    NSString *password = [defaults stringForKey:@"password_preference"];
    
    [service getReqInfo:self action:@selector(getReqListHandler:) 
             username: username 
             password: password];

}

- (void) getReqListHandler: (id) value {
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
        NSError* result = (NSError*)value;
        [self alert:@"连接失败" msg:[result localizedFailureReason]];
	}
    
	// Handle faults
	else if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
        SoapFault * result = (SoapFault*)value;
        [self alert:@"soap连接失败" msg:[result faultString]];
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
                NSUInteger count = [rows count];
                if (count <1) {
                    [self alert:@"提示" msg:@"无需领药"];
                }
                else{
                    
                    self.dataList = [NSMutableArray array];
                    
                    for (int i=0; i<[rows count]; i++) {
                        NSMutableDictionary *obj = [rows objectAtIndex:i];
                        
                        [self.dataList addObject:obj];
                    }
                    
                    [self.tableView reloadData];
                    [self doneLoadingTableViewData];
                    
                    
                }
                
            }
            else{
                NSString *msg = (NSString*) [ret objectForKey:msgKey];
                [self alert:NSLocalizedString(@"Error", @"Error") msg:msg];
            }
            
        }
        else{
            
        }
    }
    [self dismissActiveIndicatorView];
    
}

- (void) reqConfirm
{
    if ([self.dataList count]>0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
                                                        message:@"确定以当前列表领药??"
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")  
                                              otherButtonTitles: NSLocalizedString(@"Apply", @"Apply")
                              ,nil];
        [alert show];	
        [alert release];
    }
    
    
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self displayActiveIndicatorView];
        
        iRfRgService* service = [iRfRgService service];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *username = [defaults stringForKey:@"username_preference"];
        NSString *password = [defaults stringForKey:@"password_preference"];
        
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        NSString *jsonArray =[writer stringWithObject:[self.dataList copy]];
        [writer release];
        
        NSLog(@"%@",jsonArray);
        
        [service doReqComfirm:self 
                       action:@selector(reqConfirmHandler:) 
                     username:username 
                     password:password 
                    jsonArray:jsonArray];
    }
    
}

- (void) reqConfirmHandler:(id)value
{
    // Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
        NSError* result = (NSError*)value;
        [self alert:@"连接失败" msg:[result localizedFailureReason]];
	}
    
	// Handle faults
	else if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
        SoapFault * result = (SoapFault*)value;
        [self alert:@"soap连接失败" msg:[result faultString]];
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
                [self alert:NSLocalizedString(@"Info", @"Info") msg:@"操作成功"];
                _firstloaded = NO;
                self.dataList = [NSArray array];
                [self.tableView reloadData];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else{
                NSString *msg = (NSString*) [ret objectForKey:msgKey];
                [self alert:NSLocalizedString(@"Error", @"Error") msg:msg];
            }
            
        }
        else{
            
        }
    }
    [self dismissActiveIndicatorView];
}

#pragma mark -
#pragma mark UIViewController delegate

- (void)viewWillAppear:(BOOL)animated
{
    if (!_firstloaded) {
        [self getReqList];
        _firstloaded = YES;
    }
    
	// this UIViewController is about to re-appear, make sure we remove the current selection in our table view
	NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:tableSelection animated:YES];
    
    [self.tableView reloadData];
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    self.title = [NSString stringWithFormat:@"领药列表(共%d条)",[self.dataList count]];
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *row = [self.dataList objectAtIndex:indexPath.row];
    
    
    static BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:IsPad? @"MedicineReqCellHD" :@"MedicineReqCell" 
                                    bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:kCellIdentifier];
        nibsRegistered = YES;
    }
    
    MedicineReqCell *cell = (MedicineReqCell *)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
	cell.goodsname.text = [row objectForKey:@"goodsname"];
    cell.goodstype.text = [row objectForKey:@"goodstype"];
    cell.locno.text = [row objectForKey:@"locno"];
    cell.lotno.text = [row objectForKey:@"lotno"];
    cell.goodsqty.text = [row objectForKey:@"goodsqty"];
    cell.houserealqty.text = [row objectForKey:@"houserealqty"];
    cell.opqty.text = [row objectForKey:@"opqty"];
    cell.data = row;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IsPad) {
        return 100.0;
    }
    else {
        return 152.0;
    }
    
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.dataList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    //  put here just for demo
    _reloading = YES;
    
    [self getReqList];
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

@end
