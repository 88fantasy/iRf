//
//  RootViewController.m
//  iRf
//
//  Created by pro on 11-7-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//
#import "Const.h"
#import "RootViewController.h"
#import "ScanView.h"
#import "RgListView.h"
#import "TrListView.h"
#import "StockAdjustView.h"
#import "MedicineReqListView.h"

static NSString *kCellIdentifier = @"MyIdentifier";
static NSString *kTitleKey = @"title";
static NSString *kExplainKey = @"explanation";
static NSString *kViewControllerKey = @"viewController";
static NSString *iconKey = @"iconfile";



@interface RootViewController ()
//- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation RootViewController

@synthesize menuList,userfield,pwdfield;


- (void)confirmUser{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults stringForKey:@"username_preference"];
    NSString *password = [defaults stringForKey:@"password_preference"];
	NSLog(@"%@",username);
	NSLog(@"%@",password);
	if (username == nil || [@"" isEqualToString:username] || password == nil || [@"" isEqualToString:password]) {
		
		
		UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"尚未设置用户名密码" 
														 message:@"\n\n\n" // IMPORTANT
														delegate:self 
											   cancelButtonTitle:@"取消" 
											   otherButtonTitles:@"确定", nil];
		
		if (username == nil || [@"" isEqualToString:username]) {
			userfield = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 55.0, 260.0, 25.0)]; 
			[userfield setBackgroundColor:[UIColor whiteColor]];
			[userfield setPlaceholder:@"用户名"];
			[prompt addSubview:userfield];
			
		}
		
		if(password == nil|| [@"" isEqualToString:password]){
			pwdfield = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 90.0, 260.0, 25.0)]; 
			[pwdfield setBackgroundColor:[UIColor whiteColor]];
			[pwdfield setPlaceholder:@"密码"];
			[pwdfield setSecureTextEntry:YES];
			[prompt addSubview:pwdfield];
			
		}
		// set place
		[prompt setCenter:self.view.center];		
		[prompt show];
		[prompt release];
		
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Set up the edit and add buttons.
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;
//
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject)];
//    self.navigationItem.rightBarButtonItem = addButton;
//    [addButton release];
    
    self.menuList = [NSMutableArray array];
    
    ScanView* scanview = [[ScanView alloc] initWithNibName:@"ScanView" bundle:nil];
    [self.menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                              @"收货管理", kTitleKey,
                              @"扫描或手输条码进行收货", kExplainKey,
                              scanview, kViewControllerKey,
                              @"收货管理.png",iconKey,
							  nil]];
    
    RgListView *rglistView = [[RgListView alloc] initWithStyle:UITableViewStylePlain];
    [self.menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                              @"未收货列表", kTitleKey,
                              @"查询一个月内所有未收货的信息", kExplainKey,
                              rglistView, kViewControllerKey,
                              @"库存查询.png",iconKey,
							  nil]];
    TrListView *trListView = [[TrListView alloc]initWithNibName:@"TrListView" bundle:nil];

    [self.menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                              @"货品对应关系", kTitleKey,
                              @"查询货品的对应关系情况", kExplainKey,
                              trListView, kViewControllerKey,
                              @"基础数据.png",iconKey,
							  nil]];
    
    
    [scanview release];
    [rglistView release];
    [trListView release];
    
    if (!IsInternet) {
        
        if (!IsPad) {
            StockAdjustView *stockAdjustView = [[StockAdjustView alloc]initWithNibName:@"StockAdjustView" bundle:nil];
            
            [self.menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                      @"库存调整", kTitleKey,
                                      @"可进行移库或退货等操作", kExplainKey,
                                      stockAdjustView, kViewControllerKey,
                                      @"库存调整.png",iconKey,
                                      nil]];
            [stockAdjustView release];
        }
        
        MedicineReqListView *medicineReqListView = [[MedicineReqListView alloc] initWithNibName:@"MedicineReqListView" bundle:nil];
        [self.menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                  @"药房领药", kTitleKey,
                                  @"对低于库存下限的货品进行批量移库", kExplainKey,
                                  medicineReqListView, kViewControllerKey,
                                  @"药房领药.png",iconKey,
                                  nil]];
        [medicineReqListView release];
    }
    
    
	
    
	[self confirmUser];
}

#pragma mark -
#pragma mark UIViewController delegate

- (void)viewWillAppear:(BOOL)animated
{
	// this UIViewController is about to re-appear, make sure we remove the current selection in our table view
	NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
}


#pragma mark -
#pragma mark UITableViewDelegate

// the table's selection has changed, switch to that item's UIViewController
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIViewController *targetViewController = [[self.menuList objectAtIndex: indexPath.row] objectForKey:kViewControllerKey];
	[[self navigationController] pushViewController:targetViewController animated:YES];
}


#pragma mark -
#pragma mark UITableViewDataSource

// tell our table how many rows it will have, in our case the size of our menuList
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.menuList count];
}

// tell our table what kind of cell to use and its title for the given row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
    
	cell.textLabel.text = [[self.menuList objectAtIndex:indexPath.row] objectForKey:kTitleKey];
    [cell.textLabel setFont: [UIFont fontWithName:@"Heiti SC" size:20]];
    cell.detailTextLabel.text = [[self.menuList objectAtIndex:indexPath.row] objectForKey:kExplainKey];
    
    UIImage *cellIcon = [UIImage imageNamed:[[self.menuList objectAtIndex:indexPath.row] objectForKey:iconKey]];
	[[cell imageView] setImage:cellIcon];
    
	return cell;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    [super viewDidUnload];
	
	self.menuList = nil;
	self.userfield = nil;
	self.pwdfield = nil;
}




- (void) dealloc {
    [menuList release];
	[userfield release];
	[pwdfield release];
	[super dealloc];
}

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if (userfield.text !=nil && ![@"" isEqualToString:userfield.text]) {
			[defaults setValue: userfield.text forKey:@"username_preference"];
		}
		if (pwdfield.text !=nil && ![@"" isEqualToString:pwdfield.text]) {
			[defaults setValue: pwdfield.text forKey:@"password_preference"];
		}
        [defaults setBool: YES forKey:@"enabled_preference"];
	}
	else {
		[self confirmUser];
	}

}

- (void)alertViewCancel:(UIAlertView *)alertView {
	NSLog(@"cancel");
}


@end

