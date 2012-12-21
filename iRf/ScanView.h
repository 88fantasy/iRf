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
< ZBarReaderDelegate,UITextFieldDelegate,NSXMLParserDelegate,UIGestureRecognizerDelegate >
{
    UIImageView *resultImage;
    UITextField *resultText;
	UISwitch *vswitch;
    UIAlertView *activityView;
    UIActivityIndicatorView *activityIndicator;
    
    ZBarReaderViewController *_reader;
}
@property (nonatomic, retain) IBOutlet UIImageView *resultImage;
@property (nonatomic, retain) IBOutlet UITextField *resultText;
@property (nonatomic, retain) IBOutlet UISwitch *vswitch;
@property (nonatomic, retain) UIAlertView *activityView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, retain) ZBarReaderViewController *_reader;

- (IBAction) scanButtonTapped;
- (IBAction) searchButtonTapped;
- (IBAction) cancelKeyboard:(id)sender;


@end


