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
< ZBarReaderDelegate,UITextFieldDelegate,NSXMLParserDelegate >
{
    UIImageView *resultImage;
    UITextField *resultText;
    UIView *loadingView;
}
@property (nonatomic, retain) IBOutlet UIImageView *resultImage;
@property (nonatomic, retain) IBOutlet UITextField *resultText;
@property (nonatomic, retain) IBOutlet UIView *loadingView;

- (IBAction) scanButtonTapped;
- (IBAction) searchButtonTapped;
- (IBAction) cancelKeyboard:(id)sender;
@end


