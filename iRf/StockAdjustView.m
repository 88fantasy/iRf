//
//  StockAdjustView.m
//  iRf
//
//  Created by xian weijian on 12-7-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "StockAdjustView.h"
#import "iRfRgService.h"
#import "SBJson.h"

static NSString *kCellIdentifier = @"MyIdentifier";
static NSString *kTitleKey = @"title";
static NSString *kExplainKey = @"explanation";
static NSString *kObjKey = @"obj";
static NSString *retFlagKey = @"ret";
static NSString *msgKey = @"msg";


@implementation StockAdjustView

@synthesize orglocno,tolocno,goodsqty,orgswitch,toswitch,stocktableview;
@synthesize activityView,activityIndicator,scrollView,stockList,baseCodeList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"库存调整";
        txtindex = 0;
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Apply",@"Apply") style:UIBarButtonItemStyleBordered target:self action:@selector(confirmAdjust)];
        self.navigationItem.rightBarButtonItem = addButton;
        [addButton release];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Cancel",@"Cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Apply",@"Apply") style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    self.goodsqty.inputAccessoryView = numberToolbar;
    [numberToolbar release];
    
    self.baseCodeList = [NSArray array];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.orglocno = nil;
    self.orgswitch = nil;
    self.tolocno = nil;
    self.toswitch = nil;
    self.goodsqty = nil;
    self.stocktableview = nil;
    self.activityView = nil;
    self.activityIndicator = nil;
    self.stockList = nil;
    self.baseCodeList = nil;
}

- (IBAction) orgButtonTapped
{
    txtindex = 1;
    if (!self.orgswitch.isOn) {
        [self showScanScreen];
    }
    
}

- (IBAction) toButtonTapped
{
    txtindex = 2;
    if (!self.toswitch.isOn) {
        [self showScanScreen];
    }
    
}

- (void) showScanScreen
{
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    
    [self presentModalViewController: reader
							animated: YES];
    [reader release];
}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results =
	[info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
	
    // EXAMPLE: do something useful with the barcode data
	
    switch (txtindex) {
        case 1:
            orglocno.text = symbol.data;
            break;
            
        default:
            tolocno.text = symbol.data;
            break;
    }    
	
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissModalViewControllerAnimated: YES];
    
    
}



- (IBAction) getStockList
{
    NSString *orgtext = [self.orglocno.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ( [orgtext length]>0) {
        [self displayActiveIndicatorView];
        
        iRfRgService* service = [iRfRgService service];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *username = [defaults stringForKey:@"username_preference"];
        NSString *password = [defaults stringForKey:@"password_preference"];
        
        [service getStockByLoc:self action:@selector(getStockListHandler:) 
                      username: username 
                      password: password
                         locno:orgtext];
    }
    
        
}

// Handle the response from getStockList.

- (void) getStockListHandler: (id) value {
    
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
                    [self alert:@"提示" msg:@"没有库存"];
                }
                else{
                    
                    self.stockList = [NSMutableArray array];
                    
                    for (int i=0; i<[rows count]; i++) {
                        NSDictionary *obj = [rows objectAtIndex:i];
                        NSString *text = [obj objectForKey:@"goodsname"];
                        
                        text = [text stringByAppendingString:@"  "];
                        text = [text stringByAppendingString:[obj objectForKey:@"goodsqty"]];
                        text = [text stringByAppendingString:[obj objectForKey:@"goodsunit"]];
                        
                        NSString *detailText = [obj objectForKey:@"goodstype"];
                        NSString *lotno = [obj objectForKey:@"lotno"];
                        NSString *goodsstatus = [obj objectForKey:@"goodsstatus"];
                        NSString *proddate = [obj objectForKey:@"proddate"];
                        if (lotno != nil) {
                            if ([lotno length]>0) {
                                detailText = [detailText stringByAppendingString:@"     "];
                                detailText = [detailText stringByAppendingString:lotno];
                            }
                        }
                        if (proddate != nil) {
                            if ([proddate length]>0) {
                                detailText = [detailText stringByAppendingString:@"     "];
                                detailText = [detailText stringByAppendingString:proddate];
                            }
                        }
                        if (goodsstatus != nil) {
                            if ([goodsstatus length]>0) {
                                detailText = [detailText stringByAppendingString:@"     "];
                                detailText = [detailText stringByAppendingString:goodsstatus];
                            }
                        }
                        
                        
                        [self.stockList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                  text, kTitleKey,
                                                  detailText, kExplainKey,
                                                  obj,kObjKey,
                                                  nil]];
                    }
                    
                    
                    [self.stocktableview reloadData];
                    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
                    [self.stocktableview selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionTop];
                    [self tableView:self.stocktableview didSelectRowAtIndexPath:indexPath];
                }
                
            }
            else{
                NSString *msg = (NSString*) [ret objectForKey:msgKey];
                [self alert:@"错误" msg:msg];
            }
            
        }
        else{
            
        }
    }
    [self dismissActiveIndicatorView];
    
}

- (void) confirmAdjust
{
    NSIndexPath *indexPath = [self.stocktableview indexPathForSelectedRow];
    if (indexPath!=nil
        &&self.orglocno.text.length>0
        &&self.tolocno.text.length>0
        &&self.goodsqty.text.length>0)
    {
        NSDictionary *obj = [[self.stockList objectAtIndex:indexPath.row] objectForKey:kObjKey] ;
        NSString *basecode = [obj objectForKey:@"basecode"];
        if (![@"" isEqualToString:basecode]
            &&[[self.tolocno.text substringToIndex:1] isEqualToString:@"C"]
            &&[self.baseCodeList count]!=[self.goodsqty.text intValue]) {
            BaseCodeTableView *basetable = [[BaseCodeTableView alloc]initWithNibName:@"BaseCodeTableView" bundle:nil];
            basetable.codenum = [self.goodsqty.text intValue];
            basetable.baseCodeTableViewDelegate = self;
            [[self navigationController] pushViewController:basetable animated:YES];      
        }
        else {
            [self displayActiveIndicatorView];
            
            NSDictionary *stock = [obj copy];
            basecode = @"";
            for (int i=0; i<[self.baseCodeList count]; i++) {
                if (i==0) {
                    basecode = [basecode stringByAppendingString:[self.baseCodeList objectAtIndex:i]];
                }
                else {
                    basecode = [basecode stringByAppendingString:[@"," stringByAppendingString: [self.baseCodeList objectAtIndex:i]]];
                }
            }
            NSDictionary *jsonobj =[NSDictionary dictionaryWithObjectsAndKeys:
                                    self.orglocno.text,@"orglocno",
                                    self.tolocno.text,@"tolocno",
                                    self.goodsqty.text,@"goodsqty",
                                    basecode,@"basecode",
                                    stock,@"stockobj",
                                    nil];
            SBJsonWriter *writer = [[SBJsonWriter alloc] init];
            NSString *json =[writer stringWithObject:jsonobj];
            [writer release];
            
            NSLog(@"%@",json);
            
            iRfRgService* service = [iRfRgService service];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *username = [defaults stringForKey:@"username_preference"];
            NSString *password = [defaults stringForKey:@"password_preference"];
            
            [service mvConfirm:self action:@selector(confirmHandler:) 
                      username: username 
                      password: password
                    jsonObject:json];
        }
    }
    
}

-(void)DidCodeInput:(NSArray *)codes
{
    self.baseCodeList = codes;
    [self confirmAdjust];
}

- (void) confirmHandler:(id)value
{
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
    
    NSString* result = (NSString*)value;
    NSLog(@"%@", result);
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    id retObj = [parser objectWithString:result];
    
    [parser release];
    
    [self dismissActiveIndicatorView];
    
    if (retObj != nil) {
        NSDictionary *ret = (NSDictionary*)retObj;
        NSString *retflag = (NSString*) [ret objectForKey:retFlagKey];
        
        if ([retflag boolValue]==YES) {
            if (self.orgswitch.isOn) {
                [self getStockList];
            }
            else {
                self.stockList = [NSMutableArray array];
                self.orglocno.text = @"";
                [self.stocktableview reloadData];
                
            }
            if (!self.toswitch.isOn) {
                self.tolocno.text = @"";
            }
            self.goodsqty.text = @"";
            self.baseCodeList = [NSArray array];
            
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
        else{
            NSString *msg = (NSString*) [ret objectForKey:msgKey];
            [self alert:NSLocalizedString(@"Error",@"Error") msg:msg];
        }
        
    }
    
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.stockList count]; 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *row = nil;
    row = [self.stockList objectAtIndex:indexPath.row];
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[row objectForKey:kCellIdentifier]];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[row objectForKey:kCellIdentifier]] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	cell.textLabel.text = [row objectForKey:kTitleKey];
    [cell.textLabel setFont: [UIFont fontWithName:@"Heiti SC" size:18]];
    cell.detailTextLabel.text = [row objectForKey:kExplainKey];
    cell.detailTextLabel.textAlignment = UITextAlignmentRight;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *row = nil;
    row = [self.stockList objectAtIndex:indexPath.row];
    // Navigation logic may go here. Create and push another view controller.
    
    NSDictionary *obj = [row objectForKey:kObjKey];
    self.goodsqty.text =  [obj objectForKey:@"goodsqty"];
    
}




- (IBAction) scrollToBottom:(id)sender{
    [self.scrollView setContentOffset:CGPointMake(0, 280) animated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    textField.text = [textField.text uppercaseString];
    return YES;
}

-(void)cancelNumberPad{
    [self.goodsqty resignFirstResponder];
    self.goodsqty.text = @"";
}

-(void)doneWithNumberPad{
    [self.goodsqty resignFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
                                                  message: NSLocalizedString(@"Loading...",@"Loading")
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	[textField resignFirstResponder];
	return YES;
}

@end