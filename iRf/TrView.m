//
//  TrView.m
//  iRf
//
//  Created by user on 11-8-31.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "TrView.h"
#import "iRfRgService.h"
#import "SBJson.h"

@implementation TrView
@synthesize ugoodsid,goodsname,goodstype,tradename,factno,goodsunit,cusgdsid,multi,companyname,locbtn,locno;
@synthesize scrollView,values;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil values:(NSDictionary*)obj 
{
    if(IsPad){
        self = [super initWithNibName:[nibNameOrNil stringByAppendingString:@"HD"] bundle:nibBundleOrNil];
    }
    else{
        self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    }
    
    if (self) {
        // Custom initialization
        self.title = @"货品对应关系明细";
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemSave target:self action:@selector(confirmTr:)];
        self.navigationItem.rightBarButtonItem = saveButton;
        [saveButton release];
    }
    self.values = obj;
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [ugoodsid release];
    [goodsname release];
    [goodstype release];
    [tradename release];
    [factno release];
    [goodsunit release];
    [cusgdsid release];
    [multi release];
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
    // Do any additional setup after loading the view from its nib.
    
    NSLog(@"%@",values);
    
    self.ugoodsid.text = (NSString*) [values objectForKey:@"ugoodsid"];
    self.goodsname.text = (NSString*) [values objectForKey:@"goodsname"];
    self.goodstype.text = (NSString*) [values objectForKey:@"goodstype"];
    self.tradename.text = (NSString*) [values objectForKey:@"tradename"];
    self.factno.text = (NSString*) [values objectForKey:@"factno"];
    self.goodsunit.text = (NSString*) [values objectForKey:@"goodsunit"];
    self.cusgdsid.text = (NSString*) [values objectForKey:@"cusgdsid"];
    self.multi.text = (NSString*) [values objectForKey:@"multi"];
    self.companyname.text = (NSString*) [values objectForKey:@"companyname"];
    self.locno.text = (NSString*) [values objectForKey:@"locno"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.ugoodsid = nil ;
    self.goodsname = nil ;
    self.goodstype = nil ;
    self.tradename = nil ;
    self.factno = nil ;
    self.goodsunit = nil ;
    self.cusgdsid = nil ;
    self.multi = nil ;
}

#pragma mark 纵向旋转控制
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark ios6+纵向旋转控制需要以下3个 覆盖viewcontroller的方法
- (BOOL)shouldAutorotate
{
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)confirmTr:(id)sender {
    
    if ([[self.cusgdsid.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                        message: @"客户货品码不能为空"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];	
        [alert release];
        return;
    }
    
    iRfRgService* service = [iRfRgService service];
    //    service.logging = YES;
    
    NSDictionary *setting = [CommonUtil getSettings];
    NSString *username = [setting objectForKey:kSettingUserKey];
    NSString *password = [setting objectForKey:kSettingPwdKey];
    
    NSMutableDictionary *trobj = [NSMutableDictionary dictionary];
    NSString *goodsnamestr = [self.goodsname.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *goodstypestr = [self.goodstype.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *tradenamestr = [self.tradename.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *factnostr = [self.factno.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *goodsunitstr = [self.goodsunit.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *cusgdsidstr = [self.cusgdsid.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *multistr = [self.multi.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *locnostr = [self.locno.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (goodsnamestr!=nil && ![@"" isEqualToString:goodsnamestr] ) {
        [trobj setObject:goodsnamestr forKey:@"goodsname"];
        [values setValue:goodsnamestr forKey:@"goodsname"];
    }
    else {
        [values setValue:@"" forKey:@"goodsname"];
    }
    
    if (goodstypestr!=nil && ![@"" isEqualToString:goodstypestr] ) {
        [trobj setObject:goodstypestr forKey:@"goodstype"];
        [values setValue:goodstypestr forKey:@"goodstype"];
    }
    else {
        [values setValue:@"" forKey:@"goodstype"];
    }
    
    if (tradenamestr!=nil && ![@"" isEqualToString:tradenamestr] ) {
        [trobj setObject:tradenamestr forKey:@"tradename"];
        [values setValue:tradenamestr forKey:@"tradename"];
    }
    else {
        [values setValue:@"" forKey:@"tradename"];
    }
    
    if (factnostr!=nil && ![@"" isEqualToString:factnostr] ) {
        [trobj setObject:factnostr forKey:@"factno"];
        [values setValue:factnostr forKey:@"factno"];
    }
    else {
        [values setValue:@"" forKey:@"factno"];
    }
    
    if (goodsunitstr!=nil && ![@"" isEqualToString:goodsunitstr] ) {
        [trobj setObject:goodsunitstr forKey:@"goodsunit"];
        [values setValue:goodsunitstr forKey:@"goodsunit"];
    }
    else {
        [values setValue:@"" forKey:@"goodsunit"];
    }
    
    if (cusgdsidstr!=nil && ![@"" isEqualToString:cusgdsidstr] ) {
        [trobj setObject:cusgdsidstr forKey:@"cusgdsid"];
        [values setValue:cusgdsidstr forKey:@"cusgdsid"];
    }
    else {
        [values setValue:@"" forKey:@"cusgdsid"];
    }
    
    if (multistr!=nil && ![@"" isEqualToString:multistr] ) {
        [trobj setObject:multistr forKey:@"multi"];
        [values setValue:multistr forKey:@"multi"];
    }
    else {
        [values setValue:@"" forKey:@"multi"];
    }
    
    if (locnostr!=nil && ![@"" isEqualToString:locnostr] ) {
        [trobj setObject:locnostr forKey:@"locno"];
        [values setValue:locnostr forKey:@"locno"];
    }
    else {
        [values setValue:@"" forKey:@"locno"];
    }
    
    
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *json = [writer stringWithObject:trobj];
    
    [service doTr:self
           action:@selector(doTrHandler:)
         username: username
         password: password
          pkvalue:[self.ugoodsid.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
       jsonConfig:json
     ];
    
    
}

- (void)doTrHandler:(id)value {
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
	NSLog(@"doRg returned the value: %@", result);
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    id retObj = [parser objectWithString:result];
    NSLog(@"%@",retObj);
    [parser release];
    
    if (retObj != nil) {
        NSDictionary *ret = (NSDictionary*)retObj;
        NSString *retflag = (NSString*) [ret objectForKey:kRetFlagKey];
        
        if ([retflag boolValue]==YES) {
            [values setValue:self.cusgdsid.text forKey:@"cusgdsid"];
//            if (self.scanViewDelegate!=nil) { 
//                //调用回调函数 
//                [self.scanViewDelegate confirmCallBack:YES values:values]; 
//            } 
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            NSString *msg = (NSString*) [ret objectForKey:kMsgKey];
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
#pragma mark UITextFieldDelegate 

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y) animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}
//- (IBAction) scrollToBottom:(id)sender{
//    [self.scrollView setContentOffset:CGPointMake(0, 250) animated:YES];
//}


#pragma mark Scan and Handle

- (IBAction) scanButtonTapped
{
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
	
    
    //    CGRect rect_screen = [[UIScreen mainScreen] bounds];
    //    CGRect rect = reader.readerView.frame;
    //
    //    rect.size.height = rect_screen.size.height;
    //    rect.size.width = rect_screen.size.width;
    //    reader.readerView.frame = rect;
    
    
    
	//reader.showsZBarControls = NO;
	
	
	
    //    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
	
    // EXAMPLE: disable rarely used I2/5 to improve performance
    //    [scanner setSymbology: ZBAR_I25
    //				   config: ZBAR_CFG_ENABLE
    //					   to: 0];
	
    // present and release the controller
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
	
    self.locno.text = symbol.data;
	
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissModalViewControllerAnimated: YES];
    
}

@end
