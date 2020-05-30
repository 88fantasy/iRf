//
//  ScanView.h
//  rf
//
//  Created by pro on 11-7-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RgView.h"

@interface ScanView : UIViewController     
// ADD: delegate protocol
< AVCaptureMetadataOutputObjectsDelegate,UITextFieldDelegate,NSXMLParserDelegate,UIGestureRecognizerDelegate >
{
    UIImageView *resultImage;
    UITextField *resultText;
	UISwitch *vswitch;
    
    AVCaptureSession *session;
}
@property (nonatomic, strong) IBOutlet UIImageView *resultImage;
@property (nonatomic, strong) IBOutlet UITextField *resultText;
@property (nonatomic, strong) IBOutlet UISwitch *vswitch;

@property (nonatomic, strong) AVCaptureSession *session;

- (IBAction) scanButtonTapped;
- (IBAction) searchButtonTapped;
- (IBAction) cancelKeyboard:(id)sender;


@end


