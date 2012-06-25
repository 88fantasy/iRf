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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil values:(NSDictionary*)obj 
//         readOnlyFlag:(BOOL) _readOnlyFlag
{
    if(IsPad){
        self = [super initWithNibName:[nibNameOrNil stringByAppendingString:@"HD"] bundle:nibBundleOrNil];
    }
    else{
        self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    }
    
    if (self) {
        // Custom initialization
        
        NSString *rfflag = (NSString*) [obj objectForKey:@"rgflag"];
        if ([rfflag intValue]==1) {
            self.title = @"收货明细(已收货)";
            readOnlyFlag = YES;
        }
        else{
            self.title = @"收货明细";
            readOnlyFlag = NO;
        }
        
        self.values = obj;
//        readOnlyFlag = _readOnlyFlag;
        
        if (readOnlyFlag != YES) {
            UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"确认收货" style:UIBarButtonItemStyleBordered target:self action:@selector(confirmRg:)];
            self.navigationItem.rightBarButtonItem = addButton;
            [addButton release];
        }
        
        
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
    self.factoryname.text = (NSString*) [values objectForKey:@"factno"];
    self.goodsprice.text = (NSString*) [values objectForKey:@"invprice"];
    self.goodsunit.text = (NSString*) [values objectForKey:@"goodsunit"];
    self.lotno.text = (NSString*) [values objectForKey:@"lotno"];
    self.packsize.text = (NSString*) [values objectForKey:@"packsize"];
    self.validto.text = (NSString*) [values objectForKey:@"validto"];
    self.orgrow.text = (NSString*) [values objectForKey:@"orgrow"];
    self.goodsqty.text = (NSString*) [values objectForKey:@"goodsqty"];
    
    
    self.rgqty.text = (NSString*) [values objectForKey:@"goodsqty"];
    self.locno.text = (NSString*) [values objectForKey:@"locno"];
    
    self.spdid = (NSString*) [values objectForKey:@"spdid"];
    
    if (!readOnlyFlag) {
        [self.rgqty setEnabled:YES];
        [self.locno setEnabled:YES];
    }
    
//    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width,self.view.frame.size.height+200 )];
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
//    service.logging = YES;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults stringForKey:@"username_preference"];
    NSString *password = [defaults stringForKey:@"password_preference"];
    
    NSLog(@"dorg开始");
    [service doRg:self 
           action:@selector(doRgHandler:) 
         username: username 
         password: password 
            splid: self.spdid 
            rgqty: self.rgqty.text 
            locno: self.locno.text];
    
    
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
    id retObj = [parser objectWithString:result];
    NSLog(@"%@",retObj);
    [parser release];
    
    if (retObj != nil) {
        NSDictionary *ret = (NSDictionary*)retObj;
        NSString *retflag = (NSString*) [ret objectForKey:retFlagKey];
        
        if ([retflag boolValue]==YES) {
            [values setValue:@"1" forKey:@"rgflag"];
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

- (IBAction) scrollToBottom:(id)sender{
    [self.scrollView setContentOffset:CGPointMake(0, 250) animated:YES];
}

- (IBAction) scanButtonTapped
{
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
	
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
    locno.text = symbol.data;
    
	
    // EXAMPLE: do something useful with the barcode image
//    resultImage.image =
//	[info objectForKey: UIImagePickerControllerOriginalImage];
	
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissModalViewControllerAnimated: YES];
    
    
    
    
}
@end
