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
@synthesize ugoodsid,goodsname,goodstype,tradename,factno,goodsunit,cusgdsid,multi,companyname;
@synthesize scrollView,values;

NSString const *retFlagKey = @"ret";
NSString const *msgKey = @"msg";

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
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemSave
                                            target:self action:@selector(confirmTr:)];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误"
                                                        message: @"客户货品码不能为空"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];	
        [alert release];
        return;
    }
    
    iRfRgService* service = [iRfRgService service];
    //    service.logging = YES;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults stringForKey:@"username_preference"];
    NSString *password = [defaults stringForKey:@"password_preference"];
    
    [service doTr:self 
            action:@selector(doTrHandler:) 
     username: username 
     password: password 
     ugoodsid: [self.ugoodsid.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
    goodsname: [self.goodsname.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] 
    goodstype: [self.goodstype.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] 
    tradename: [self.tradename.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] 
       factno: [self.factno.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] 
    goodsunit: [self.goodsunit.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] 
     cusgdsid: [self.cusgdsid.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] 
        multi: [self.multi.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
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
        NSString *retflag = (NSString*) [ret objectForKey:retFlagKey];
        
        if ([retflag boolValue]==YES) {
            [values setValue:self.cusgdsid.text forKey:@"cusgdsid"];
            //            if (self.scanViewDelegate!=nil) { 
            //                //调用回调函数 
            //                [self.scanViewDelegate confirmCallBack:YES values:values]; 
            //            } 
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            NSString *msg = (NSString*) [ret objectForKey:msgKey];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误"
                                                            message: msg
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];	
            [alert release];
        }
        
    }
    else{
        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	[textField resignFirstResponder];
	return YES;
}

//- (IBAction) scrollToBottom:(id)sender{
//    [self.scrollView setContentOffset:CGPointMake(0, 250) animated:YES];
//}

@end
