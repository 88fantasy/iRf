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
#import "RootViewController.h"
#import "POAPinyin.h"

@implementation RgView

@synthesize scrollView,invno,goodsname,goodstype,factoryname,goodsprice,goodsunit,lotno
,packsize,validto,orgrow,goodsqty,rgqty,locno,socompanyname,vendername;

@synthesize spdid,values;
@synthesize goalBarView,goalBar;
@synthesize delegate;
@synthesize session;

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
            if ([ RootViewController isSync]) {
                UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSeet)];
                self.navigationItem.rightBarButtonItem = addButton;

            }
            else {
                UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"确认收货" style:UIBarButtonItemStyleBordered target:self action:@selector(confirmRg)];
                self.navigationItem.rightBarButtonItem = addButton;

            }
            
        }
        
        
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
    self.socompanyname.text = (NSString*) [values objectForKey:@"socompanyname"];
    self.vendername.text = (NSString*) [values objectForKey:@"uvender"];
    
    self.spdid = (NSString*) [values objectForKey:@"spdid"];
    
    if (!readOnlyFlag) {
        [self.rgqty setEnabled:YES];
        [self.locno setEnabled:YES];
    }

    NSString *pinyin = [POAPinyin quickConvert:self.goodsname.text byConvertMode:POAPinyinConvertModeFirstWord] ;

    NSLog(@"%@",pinyin);
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
    self.socompanyname = nil;
    self.vendername = nil;
    self.values = nil;
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

//- (void)viewWillAppear:(BOOL)animated
//{
//    [self reDrawTextField];
//}
//
//- (void) reDrawTextField
//{
//    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
//    if (UIInterfaceOrientationIsLandscape(orientation)) {
//        CGRect appFrame = [UIScreen mainScreen].applicationFrame;
//        NSLog(@"%f",[[UIScreen mainScreen] bounds].size.width);
//        CGRect frame = self.invno.frame;
//        frame.size = CGSizeMake(300, frame.size.height);
//        self.invno.frame = frame;
//        
//    }
//}

- (void)confirmRg {
    iRfRgService* service = [iRfRgService service];
    //    service.logging = YES;
    NSDictionary *setting = [CommonUtil getSettings];
    NSString *username = [setting objectForKey:kSettingUserKey];
    NSString *password = [setting objectForKey:kSettingPwdKey];
    
    NSLog(@"dorg开始");
    [service doRg:self
           action:@selector(doRgHandler:)
         username: username
         password: password
            splid: self.spdid
            rgqty: self.rgqty.text
            locno: self.locno.text];
    
    if ([RootViewController isSync]) {
        FMDatabase *db = [DbUtil retConnectionForResource:@"iRf" ofType:@"rdb"];
        if(db != nil) {
            [db executeUpdate:@"update scm_rg set rgqty = ?,locno = ?,rgflag = 1 where spdid = ?",
             self.rgqty.text, self.locno.text, self.spdid];
            [db close];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
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
    
    else {
        // Do something with the NSString* result
        NSString* result = (NSString*)value;
        NSLog(@"doRg returned the value: %@", result);
        
        NSError *error = nil;
        id retObj = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        NSLog(@"%@",retObj);
        
        if (retObj != nil) {
            NSDictionary *ret = (NSDictionary*)retObj;
            NSString *retflag = (NSString*) [ret objectForKey:kRetFlagKey];
            
            if ([retflag boolValue]==YES) {
                if (delegate && [delegate respondsToSelector:@selector(rgViewDidConfirm:)]) {
                    [delegate performSelector:@selector(rgViewDidConfirm:) withObject:self  withObject:error];
                }
//                [values setValue:@"1" forKey:@"rgflag"];
                //            NSDictionary *msg = (NSDictionary*) [ret objectForKey:kMsgKey];
                //            NSString *sid = (NSString*) [msg objectForKey:@"spdid"];
                
                if ([RootViewController isSync]) {
                    FMDatabase *db = [DbUtil retConnectionForResource:@"iRf" ofType:@"rdb"];
                    if(db != nil) {
                        [db executeUpdate:@"update scm_rg set rgdate = datetime('now') where spdid = ?",self.spdid];
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
                NSString *msg = (NSString*) [ret objectForKey:kMsgKey];
                if ([msg isKindOfClass:[NSNull class]]) {
                    msg = @"空指针";
                }
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                                message: msg
                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            
        }
        else{
            
        }
    }
}

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

- (IBAction) scrollToBottom:(id)sender{
    [self.scrollView setContentOffset:CGPointMake(0, 320) animated:YES];
}

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
        
        locno.text = metadataObject.stringValue;
        
    }
}

-(void) showActionSeet
{
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"请选择操作"
                                                    delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                      destructiveButtonTitle:@"确认收货"
                                           otherButtonTitles:@"全部收货", nil];
    [as showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (buttonIndex == 0) { //单条收货
            [self confirmRg];
        }
        else if (buttonIndex == 1 && [ RootViewController isSync] ){ //全部收货
            //只有缓存模式才能通过数据库查询同批号,同销售单的货品
            FMDatabase *db = [DbUtil retConnectionForResource:@"iRf" ofType:@"rdb"];
            if (db != nil) {
                
                notDoRgCount = 0;
                doneDoRgCoount = 0;
                
                NSString *ugoodsid = [values objectForKey:@"ugoodsid"];
                NSString *orgsoid = [values objectForKey:@"orgsoid"];
                
                FMResultSet *rs = [db executeQuery:@"select count(*) from scm_rg where ugoodsid = ? and lotno = ? and orgsoid = ? and rgflag <> 1 ",ugoodsid,self.lotno.text,orgsoid];
                if ([rs next]) {
                    notDoRgCount = [rs intForColumnIndex:0];
                }
                [db close];
                if (notDoRgCount == 1) {
                    
                    [self confirmRg];
                    return;
                }
                else if (notDoRgCount > 1) {
                    [self displayGoalBarView:0];
                    iRfRgService* service = [iRfRgService service];
                    //    service.logging = YES;
                    
                    NSDictionary *setting = [CommonUtil getSettings];
                    NSString *username = [setting objectForKey:kSettingUserKey];
                    NSString *password = [setting objectForKey:kSettingPwdKey];
                    
                    FMDatabase *db = [DbUtil retConnectionForResource:@"iRf" ofType:@"rdb"];
                    
                    if (db != nil) {
                        FMResultSet *rs = [db executeQuery:@"select spdid,goodsqty,locno from scm_rg where ugoodsid = ? and lotno = ? and orgsoid = ? and rgflag <> 1 ",ugoodsid,self.lotno.text,orgsoid];
                        while  ([rs next]) {
                            
                            NSString *idv = [rs stringForColumn:@"spdid"];
                            NSString *qty = [rs stringForColumn:@"goodsqty"];
                            NSString *lno = [rs stringForColumn:@"locno"];
                            
                            [service doRg:self
                                   action:@selector(doRgBatchHandler:)
                                 username: username
                                 password: password
                                    splid: idv
                                    rgqty: qty
                                    locno: lno];
                            
                            [db executeUpdate:@"update scm_rg set rgqty = ?,rgflag = 1 where spdid = ?", qty,  idv];
                            
                            
                            [goalBar setPercent:doneDoRgCoount/notDoRgCount * 100 animated:YES];
                        }
                        [db close];
                    }
                }
                
            }
        }
    }
    
}


- (void)doRgBatchHandler:(id)value {
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
    
    else {
        // Do something with the NSString* result
        NSString* result = (NSString*)value;
        NSLog(@"doRg returned the value: %@", result);
        
        NSError *error = nil;
        id retObj = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        NSLog(@"%@",retObj);
        
        doneDoRgCoount ++;
        if (doneDoRgCoount >= notDoRgCount) {
            [self dismissGoalBarView];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            int percent = doneDoRgCoount * 100 / notDoRgCount ;
            [self displayGoalBarView:percent];
        }
        
        if (retObj != nil) {
            NSDictionary *ret = (NSDictionary*)retObj;
            NSString *retflag = (NSString*) [ret objectForKey:kRetFlagKey];
            
            if ([retflag boolValue]==YES) {
                NSDictionary *msg = (NSDictionary*) [ret objectForKey:kMsgKey];
                NSString *idv = (NSString*) [msg objectForKey:@"spdid"];
                if ([RootViewController isSync]) {
                    FMDatabase *db = [DbUtil retConnectionForResource:@"iRf" ofType:@"rdb"];
                    if(db != nil) {
                        [db executeUpdate:@"update scm_rg set rgdate = datetime('now') where spdid = ?",idv];
                        [db close];
                    }
                }
                
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
            }
            
        }
        else{
            
        }
    }
}

//显示等待进度条
- (void) displayGoalBarView:(int)percent {
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
    if (!goalBarView.isVisible) {
        [goalBarView show];
    }
    [goalBar setPercent:percent animated:YES];
    
}

//取消等待进度条
- (void) dismissGoalBarView
{
    if (goalBarView)
    {
        [goalBarView dismissWithClickedButtonIndex:0 animated:YES];
    }
}
@end
