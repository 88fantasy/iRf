//
//  ScanView.m
//  rf
//
//  Created by pro on 11-7-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ScanView.h"
#import "iRfRgService.h"
#import "SBJson.h"
#import "RgView.h"
#import "RgListView.h"


static NSString *retFlagKey = @"ret";
static NSString *msgKey = @"msg";



@implementation ScanView

@synthesize resultImage, resultText,vswitch,activityView,activityIndicator;

- (void) alert:(NSString*)title msg:(NSString*)msg {
    // open an alert with just an OK button
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];	
    [alert release];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if(IsPad){
        self = [super initWithNibName:[nibNameOrNil stringByAppendingString:@"HD"] bundle:nibBundleOrNil];
    }
    else{
        self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    }
    if (self) {
        // Custom initialization
//        resultText.delegate = self;
    }
    return self;
}

- (void) dealloc {
    [resultImage release];
    [resultText release];
	[vswitch release];
    [activityView release];
    [activityIndicator release];
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
    // Do any additional setup after loading the view from its nib.
    self.title = @"扫描收货号"; 
    
    if (IsPad) {
        CGRect rect = self.resultText.frame;
        
        rect.size.height = 60;
        self.resultText.frame = rect;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.resultImage = nil;
    self.resultText = nil;
	self.vswitch = nil;
    self.activityView = nil;
    self.activityIndicator = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	[textField resignFirstResponder];
	return YES;
}

- (IBAction) cancelKeyboard:(id)sender{
    [sender resignFirstResponder];
}


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
	
    resultText.text = symbol.data;
    
	if([vswitch isOn]){
		if ([resultText.text length]>0) {
			NSUInteger index = [resultText.text length] - 1;
			resultText.text = [resultText.text substringToIndex:index ];
		}
	}
	
    // EXAMPLE: do something useful with the barcode image
    resultImage.image =
	[info objectForKey: UIImagePickerControllerOriginalImage];
	
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissModalViewControllerAnimated: YES];
    
    
    [self searchButtonTapped];
    
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

- (IBAction) searchButtonTapped {
	
    [self displayActiveIndicatorView];
    
    iRfRgService* service = [iRfRgService service];
    //    service.logging = YES;
    NSLog(@"getrg开始");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults stringForKey:@"username_preference"];
    NSString *password = [defaults stringForKey:@"password_preference"];
    
    [service getRg:self action:@selector(getRgHandler:) 
          username: username 
          password: password
           labelno: resultText.text];//resultText.text];1200010586734,1100009542948,0200009541779
    
    //    [defaults release];
    //    [username release];
    //    [password release];
}

// Handle the response from getRg.

- (void) getRgHandler: (id) value {
    
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
    
    else{
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
                    [self alert:@"提示" msg:@"找不到此收货号"];
                }
                else{
                    if (count == 1) {
                        NSDictionary *obj = (NSDictionary*)[rows objectAtIndex:0];
                        RgView *rgView = [[RgView alloc] initWithNibName:@"RgView" bundle:nil values:obj ];
    //                    rgView.scanViewDelegate = self;
                        [self.navigationController pushViewController:rgView animated:YES];
                        [rgView release];
                    }
                    else{
                        
                        RgListView *rgListView =[[RgListView alloc] initWithStyle:UITableViewStylePlain
                                                                             objs:rows ];
                        [self.navigationController pushViewController:rgListView animated:YES];
                        
                        [rgListView release];
                        
                    }
                    
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

-(void)confirmCallBack:(BOOL )_confirm values:(NSDictionary *)_obj{
    
}



@end
