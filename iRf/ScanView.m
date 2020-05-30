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
#import "DbUtil.h"
#import "RgView.h"
#import "RgListView.h"
#import "RootViewController.h"
#import "MBProgressHUD.h"


@implementation ScanView

@synthesize resultImage, resultText,vswitch;
@synthesize session;

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
        
//        //增加滑动手势操作
        
//        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
//        [panGesture setMaximumNumberOfTouches:2];
//        
//        [self.view addGestureRecognizer:panGesture];
//        
//        [panGesture release];
        
    }
    return self;
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



- (void) viewDidAppear:(BOOL)animated
{
    [resultText becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	[textField resignFirstResponder];
    [self searchButtonTapped];
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
	return YES;
}

- (IBAction) cancelKeyboard:(id)sender{
    [sender resignFirstResponder];
}

#pragma mark scan and handles

- (IBAction) scanButtonTapped
{
    //请求访问相机
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadScanView];
            });
        } else {
            NSLog(@"无权限访问相机");
        }
    }];
}

- (IBAction) searchButtonTapped {
	
    if ([resultText.text length] < 1) {
        [CommonUtil alert:NSLocalizedString(@"Error",@"Error") msg:@"条码为空,无法查询"];
        return;
    }
    
    [resultText selectAll:self];
    NSString *text = resultText.text;
    
    if([vswitch isOn]){
		if ([text length]>0) {
			NSUInteger index = [text length] - 1;
			text = [text substringToIndex:index ];
		}
	}
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // Set determinate mode
	hud.mode = MBProgressHUDModeIndeterminate;
	hud.labelText = @"Loading";
    hud.removeFromSuperViewOnHide = YES;
    
    
    if ([RootViewController isSync] ) {
        FMDatabase *db = [DbUtil retConnectionForResource:@"iRf" ofType:@"rdb"];
        if (db != nil) {
            FMResultSet *rs = [db executeQuery:@"select * from scm_rg where labelno = ?",text];
            NSMutableArray *rows =  [NSMutableArray array];
            while ([rs next]) {
                
                NSMutableDictionary *row =  [NSMutableDictionary dictionary];
                
                for (int i=0; i < [rs columnCount]; i++) {
                    NSString *key = [rs columnNameForIndex:i];
                    NSString *value = [rs stringForColumnIndex:i];
                    
                    if (value == nil) {
                        [row setObject:@"" forKey:key];
                    }
                    else {
                        [row setObject:value forKey:key];
                    }
                    
                }
                
                [rows addObject: row];
            }
            
            [db close];
            
            [self showRg:rows];
        }
        
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    }
    else {
        iRfRgService* service = [iRfRgService service];
        //    service.logging = YES;
        NSLog(@"getrg开始");
        
        NSDictionary *setting = [CommonUtil getSettings];
        NSString *username = [setting objectForKey:kSettingUserKey];
        NSString *password = [setting objectForKey:kSettingPwdKey];
        
        [service getRg:self action:@selector(getRgHandler:) 
              username: username 
              password: password
               labelno: text];//text];1200010586734,1100009542948,0200009541779
        

    }
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
	}
    
	// Handle faults
	else if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
        SoapFault * result = (SoapFault*)value;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"soap连接失败" 
                                                        message: [result faultString]
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
	}				
    
    else{
        // Do something with the NSString* result
        NSString* result = (NSString*)value;
        //	resultText.text = [@"getRg returned the value: " stringByAppendingString:result] ;
        NSLog(@"%@", result);
        
        
        
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"%@",json);
        
        
        if (json != nil) {
            NSDictionary *ret = (NSDictionary*)json;
            NSString *retflag = (NSString*) [ret objectForKey:kRetFlagKey];
            
            if ([retflag boolValue]) {
                NSArray *rows = (NSArray*) [ret objectForKey:kMsgKey];
                
                [self showRg:rows];
            }
            else{
                NSString *msg = (NSString*) [ret objectForKey:kMsgKey];
                if ([msg isKindOfClass:[NSNull class]]) {
                    msg = @"空指针";
                }
                [CommonUtil alert:NSLocalizedString(@"Error",@"Error") msg:msg];
            }
            
        }
        else{
            
        }
    }
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

-(void) showRg:(NSArray*)rows{
    NSUInteger count = [rows count];
    if (count <1) {
        [CommonUtil alert:@"提示" msg:@"找不到此收货号"];
    }
    else{
        if (count == 1) {
            NSDictionary *obj = (NSDictionary*)[rows objectAtIndex:0];
            RgView *rgView = [[RgView alloc] initWithNibName:@"RgView" bundle:nil values:obj ];

            [self.navigationController pushViewController:rgView animated:YES];
            
        }
        else{
            
            RgListView *rgListView =[[RgListView alloc] initWithStyle:UITableViewStylePlain
                                                                 objs:rows ];
            [self.navigationController pushViewController:rgListView animated:YES];
            
            
        }
        
    }
}

- (void)loadScanView {
    //获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ( device != nil ) {
    
        //创建输入流
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        //创建输出流
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
        //设置代理 在主线程里刷新
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        //初始化链接对象
        self.session = [[AVCaptureSession alloc]init];
        //高质量采集率
        [self.session setSessionPreset:AVCaptureSessionPresetHigh];
        
        [self.session addInput:input];
        [self.session addOutput:output];
        
        //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
        output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,//二维码
                                     //以下为条形码，如果项目只需要扫描二维码，下面都不要写
                                     AVMetadataObjectTypeEAN13Code,
                                     AVMetadataObjectTypeEAN8Code,
                                     AVMetadataObjectTypeUPCECode,
                                     AVMetadataObjectTypeCode39Code,
                                     AVMetadataObjectTypeCode39Mod43Code,
                                     AVMetadataObjectTypeCode93Code,
                                     AVMetadataObjectTypeCode128Code,
                                     AVMetadataObjectTypePDF417Code];
        
        AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        layer.frame = self.view.layer.bounds;
        [self.view.layer insertSublayer:layer atIndex:0];
        //开始捕获
        [self.session startRunning];
    }
    else {
        [CommonUtil alert:@"提示" msg:@"摄像头设备不可用"];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {
        [self.session stopRunning];
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects[0];
        
        NSLog(@"%@",metadataObject.stringValue);
        
        resultText.text = metadataObject.stringValue;
        
        [self searchButtonTapped];
    }
}

@end
