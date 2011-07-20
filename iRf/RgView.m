//
//  RgView.m
//  iRf
//
//  Created by pro on 11-7-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "RgView.h"
#import "iRfRgService.h"
#import "SBJson.h"

static NSString *retFlagKey = @"ret";
static NSString *msgKey = @"msg";

@implementation RgView

@synthesize scrollView,invno,goodsname,goodstype,factoryname,goodsprice,goodsunit,lotno
,packsize,validto,orgrow,goodsqty,rgqty,locno;

@synthesize spdid,values;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil values:(NSDictionary*)obj readOnlyFlag:(BOOL) _readOnlyFlag
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"收货明细";
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(confirmRg:)];
        addButton.title = @"确认收货";
        self.navigationItem.rightBarButtonItem = addButton;
        [addButton release];
        
        self.values = obj;
        readOnlyFlag = _readOnlyFlag;
        
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [invno release];
    [goodsname release];
    [goodstype release];
    [factoryname release];
    [goodsprice release];
    [goodsunit release];
    [lotno release];
    [packsize release];
    [validto release];
    [orgrow release];
    [goodsqty release];
    [rgqty release];
    [locno release];
    [spdid release];
    [values release];
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
    
    self.invno.text = (NSString*) [values objectForKey:@"invno"];
    self.goodsname.text = (NSString*) [values objectForKey:@"goodsname"];
    self.goodstype.text = (NSString*) [values objectForKey:@"goodstype"];
    self.factoryname.text = (NSString*) [values objectForKey:@"factoryno"];
    self.goodsprice.text = (NSString*) [values objectForKey:@"invprice"];
    self.goodsunit.text = (NSString*) [values objectForKey:@"goodsunit"];
    self.lotno.text = (NSString*) [values objectForKey:@"lotno"];
    self.packsize.text = (NSString*) [values objectForKey:@"packsize"];
    self.validto.text = (NSString*) [values objectForKey:@"validto"];
    self.orgrow.text = (NSString*) [values objectForKey:@"orgrow"];
    self.goodsqty.text = (NSString*) [values objectForKey:@"goodsqty"];
    
    
    self.rgqty.text = (NSString*) [values objectForKey:@"goodsqty"];
    self.locno.text = (NSString*) [values objectForKey:@"locno"];
    
    if (readOnlyFlag) {
        [self.rgqty setEnabled:YES];
        [self.locno setEnabled:YES];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.invno = nil ;
    self.goodsname = nil ;
    self.goodstype = nil ;
    self.factoryname = nil ;
    self.goodsprice = nil ;
    self.goodsunit = nil ;
    self.lotno = nil ;
    self.packsize = nil ;
    self.validto = nil ;
    self.orgrow = nil ;
    self.goodsqty = nil ;
    self.rgqty = nil ;
    self.locno = nil ;
    self.spdid = nil;
    self.values = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)confirmRg:(id)sender {
    iRfRgService* service = [iRfRgService service];
    service.logging = YES;
    NSLog(@"dorg开始");
    [service doRg:self 
           action:@selector(doRgHandler:) 
         username: @"" 
         password: @"" 
            splid: @"" 
            rgqty: @"" 
            locno: @""];
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
    id json = [parser objectWithString:result];
    
    [parser release];
    
    if (json != nil) {
        NSDictionary *ret = (NSDictionary*)json;
        NSString *retflag = (NSString*) [ret objectForKey:retFlagKey];
        
        if ([retflag boolValue]) {
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


@end
