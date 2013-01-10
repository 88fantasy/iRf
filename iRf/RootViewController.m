//
//  RootViewController.m
//  iRf
//
//  Created by pro on 11-7-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//
#import "Const.h"
#import "SBJson.h"
#import "DbUtil.h"
#import "iRfRgService.h"
#import "RootViewController.h"
#import "ScanView.h"
#import "RgListView.h"
#import "TrListView.h"
#import "StockAdjustView.h"
#import "MedicineReqListView.h"
#import "RgGroupListView.h"


static NSString *kCellIdentifier = @"MyIdentifier";
static NSString *kTitleKey = @"title";
static NSString *kExplainKey = @"explanation";
static NSString *kViewControllerKey = @"viewController";
static NSString *iconKey = @"iconfile";

static NSString *retFlagKey = @"ret";
static NSString *msgKey = @"msg";

enum {
    UserAlert = 100000,
    SyncAlert = 100001,
    VersionAlert = 100002
};

//@interface RootViewController ()
//- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
//@end

@implementation RootViewController

@synthesize menuList,userfield,pwdfield,activityIndicator,activityView,goalBarView,goalBar;


+ (bool) isSync {
    return syncflag && IsInternet;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    //填写你需要锁定的方向参数
    return UIInterfaceOrientationIsLandscape( interfaceOrientation ) || (interfaceOrientation == UIInterfaceOrientationPortrait);
}

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
        [prompt setTag:UserAlert];
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
    
    // 新版本检查
    NSDictionary *appinfo = [[NSBundle mainBundle] infoDictionary] ;
    
    NSLog(@"%@",appinfo);
    
    NSString *version = [appinfo objectForKey:(NSString *)kCFBundleVersionKey];
    
    NSString *urlString =[NSString stringWithFormat:@"http://%@/phoneapp/ios/iRf.php?newestver=%@",host,version];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    [connection start];
    
    // 版本检查end
    
    if (IsInternet) {
        UIBarButtonItem *syncButton = [[UIBarButtonItem alloc] initWithTitle:@"0" style:UIBarButtonItemStylePlain target:self action:@selector(syncAction:)];
        self.navigationItem.rightBarButtonItem = syncButton;
        [syncButton release];
    }
    
    self.menuList = [NSMutableArray array];
    
    ScanView* scanview = [[ScanView alloc] initWithNibName:@"ScanView" bundle:nil];
    [self.menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                              @"收货管理", kTitleKey,
                              @"扫描或手输条码进行收货", kExplainKey,
                              scanview, kViewControllerKey,
                              @"shgl.png",iconKey,
							  nil]];
    
    RgListView *rglistView = [[RgListView alloc] initWithStyle:UITableViewStylePlain];
    [self.menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                              @"收货明细列表", kTitleKey,
                              @"查询一个月内所有收货的信息", kExplainKey,
                              rglistView, kViewControllerKey,
                              @"kccx.png",iconKey,
							  nil]];
    TrListView *trListView = [[TrListView alloc]initWithNibName:@"TrListView" bundle:nil];

    [self.menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                              @"货品对应关系", kTitleKey,
                              @"查询货品的对应关系情况", kExplainKey,
                              trListView, kViewControllerKey,
                              @"jcsj.png",iconKey,
							  nil]];
    
    RgGroupListView *rgGroupListView = [[RgGroupListView alloc]initWithNibName:@"RgGroupListView" bundle:nil];
    
    [self.menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                              @"品种收货汇总查询", kTitleKey,
                              @"查询一个月内收货信息的汇总情况", kExplainKey,
                              rgGroupListView, kViewControllerKey,
                              @"kccx.png",iconKey,
							  nil]];
    
    [scanview release];
    [rglistView release];
    [trListView release];
    [rgGroupListView release];
    if (!IsInternet) {
        
//        if (!IsPad) {
            StockAdjustView *stockAdjustView = [[StockAdjustView alloc]initWithNibName:@"StockAdjustView" bundle:nil];
            
            [self.menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                      @"库存调整", kTitleKey,
                                      @"可进行移库或退货等操作", kExplainKey,
                                      stockAdjustView, kViewControllerKey,
                                      @"kctz.png",iconKey,
                                      nil]];
            [stockAdjustView release];
//        }
        
        MedicineReqListView *medicineReqListView = [[MedicineReqListView alloc] initWithNibName:@"MedicineReqListView" bundle:nil];
        [self.menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                  @"药房领药", kTitleKey,
                                  @"对低于库存下限的货品进行批量移库", kExplainKey,
                                  medicineReqListView, kViewControllerKey,
                                  @"yfly.png",iconKey,
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
    self.activityIndicator = nil;
    self.activityView = nil;
    self.goalBar = nil;
    self.goalBarView = nil;
}




- (void) dealloc {
    [menuList release];
	[userfield release];
	[pwdfield release];
    [activityIndicator release];
    [activityView release];
    [goalBar release];
    [goalBarView release];
	[super dealloc];
}

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
     
    if ([alertView tag] == UserAlert) {
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
        [self confirmUser];
    }
	else if ([alertView tag] == SyncAlert) {
        switch (buttonIndex) {
            case 1:
                [self getAllRg];
                break;
            case 2:
                syncflag = NO;
                [self.navigationItem.rightBarButtonItem setTitle:@"0"];
                break;
            case 3:
                [self confirmRg];
                break;
            default:
                ;
        }
    }
    else if ([alertView tag] == VersionAlert) {
        if(buttonIndex == 1) {
            NSString *appurl = [NSString stringWithFormat:@"itms-services:///?action=download-manifest&url=http://%@/phoneapp/ios/iRf.php",host];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appurl]]; 
        }
    }
}

//- (void)alertViewCancel:(UIAlertView *)alertView {
//	NSLog(@"cancel");
//}




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

- (void) alert:(NSString*)title msg:(NSString*)msg {
    // open an alert with just an OK button
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];
}

- (IBAction)syncAction:(id)sender {
    NSString *msg;
    
    if ([RootViewController isSync]) {
        msg = [NSString stringWithFormat:@"当前已同步 %@ 条收货数据",
              [self.navigationItem.rightBarButtonItem title] ];
    }
    else {
        msg = @"尚未进行同步";
    }
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"请选择操作"
                          message:msg
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                          otherButtonTitles:@"同步",@"撤销同步",@"回传收货信息",
                          nil];
    [alert setTag:SyncAlert];
    [alert show];
    [alert release];
}

- (void) getAllRg{
    
    [self displayActiveIndicatorView];
    
    iRfRgService* service = [iRfRgService service];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults stringForKey:@"username_preference"];
    NSString *password = [defaults stringForKey:@"password_preference"];
    
    [service getAllRg:self action:@selector(getAllRgHandler:)
             username: username
             password: password
            queryjson:nil
     ];
    
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
                
                if (rows != nil) {
                    
                    FMDatabase *db = [DbUtil rebuildForResource:@"iRf" ofType:@"rdb"];
                    if (db != nil) {
                        
                        [db beginTransaction];
                        
                        [db executeUpdate:@"delete from SCM_RG"];
                        
                        for (int i=0; i<[rows count]; i++) {
                            NSDictionary *row = [rows objectAtIndex:i];
                            [db executeUpdate:@"insert into SCM_RG (spdid, labelno, labeltype, said, orgsoid, socompanyid, socompanyname, lotno, ugoodsid, cusgdsid, goodsname, goodspy, goodstype, factno, goodsunit, goodsqty,  invno, invprice, proddate, prodarea, validto,  locno, tcsoid, packsize, uvenderid, uvender, orgrow, stageid, rgmanid, rgdate, rgqty, rgflag, credate) values ( :spdid, :labelno, :labeltype, :said, :orgsoid, :socompanyid, :socompanyname, :lotno, :ugoodsid, :cusgdsid, :goodsname, :goodspy, :goodstype, :factno, :goodsunit, :goodsqty,  :invno, :invprice, date(:proddate), :prodarea, :validto,  :locno, :tcsoid, :packsize, :uvenderid, :uvender, :orgrow,   :stageid, :rgmanid, :rgdate, :rgqty, :rgflag, datetime(:credate) )" withParameterDictionary:row];
                        
                        }
                        FMResultSet *rs = [db executeQuery:@"select count(*) from SCM_RG"];
                        if ([rs next]) {
                            int count = [rs intForColumnIndex:0];
                            NSLog(@"%d",count);
                            [self.navigationItem.rightBarButtonItem
                                            setTitle:[rs stringForColumnIndex:0]];
                            [CommonUtil alert:@"提示"
                                          msg:[NSString stringWithFormat:@"已成功接受%d条收货信息",count]];
                        }
                        
                        [db commit];
                        
                        [db close];
                    }
                }
                
                syncflag = YES;
            }
            else{
                NSString *msg = (NSString*) [ret objectForKey:msgKey];
                if ([msg isKindOfClass:[NSNull class]]) {
                    msg = @"空指针";
                }
                [self alert:NSLocalizedString(@"Error", @"Error") msg:msg];
            }
            
        }
    }
    [self dismissActiveIndicatorView];
    
}


//显示等待进度条
- (void) displayGoalBarView:(int) percent {
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
    [goalBar setPercent:percent animated:YES];
    [goalBarView show];
}

//取消等待进度条
- (void) dismissGoalBarView
{
    if (goalBarView)
    {
        [goalBarView dismissWithClickedButtonIndex:0 animated:YES];
    }
}

- (void)confirmRg {
    if ([RootViewController isSync]) {
        FMDatabase *db = [DbUtil retConnectionForResource:@"iRf" ofType:@"rdb"];
        if(db!=Nil){
            notDoRgCount = 0;
            doneDoRgCoount = 0;
            FMResultSet *rs = [db executeQuery:@"select count(*) from SCM_RG where rgflag = 1 and rgdate in ('')"];
            if ([rs next]) {
                notDoRgCount = [rs intForColumnIndex:0];
            }
            if (notDoRgCount>0) {
                [self displayGoalBarView:0];
            }
            iRfRgService* service = [iRfRgService service];
            //    service.logging = YES;
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *username = [defaults stringForKey:@"username_preference"];
            NSString *password = [defaults stringForKey:@"password_preference"];
                
            rs = [db executeQuery:@"select spdid,rgqty,locno from SCM_RG where rgflag = 1 and rgdate in ('')"];
            while ([rs next]) {
                NSString *spdid = [rs stringForColumnIndex:0];
                NSString *rgqty = [rs stringForColumnIndex:1];
                NSString *locno = [rs stringForColumnIndex:2];
                
                [service doRg:self
                       action:@selector(doRgHandler:)
                     username: username
                     password: password
                        splid: spdid
                        rgqty: rgqty
                        locno: locno];
//                [self doRgHandler:nil];
            }
            
            [db close];
        }
        
    }
    
    
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
    }
    else {
        [self displayGoalBarView: doneDoRgCoount * 100 / notDoRgCount ];
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
            
            //            if (self.scanViewDelegate!=nil) {
            //                //调用回调函数
            //                [self.scanViewDelegate confirmCallBack:YES values:values];
            //            }
            //            [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark -
#pragma mark 版本检查  NSURLConnectionDataDelegate delegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSMutableString *result = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSLog(@"Version check result string is :%@",result);
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    id retObj = [parser objectWithString:result];
    [parser release];
    if (retObj != nil) {
        NSLog(@"%@",retObj);
        NSDictionary *versionobj = (NSDictionary *)retObj;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"有新版本啦[%@]",[versionobj objectForKey:@"version"]]
                                                        message:[versionobj objectForKey:@"comments"]
													   delegate:self
                                cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel")
                                            otherButtonTitles:@"立即安装", nil];
        [alert setTag:VersionAlert];
		[alert show];
		[alert release];
    }
    
}
@end

