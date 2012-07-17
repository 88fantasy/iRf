//
//  StockAdjustView.h
//  iRf
//
//  Created by xian weijian on 12-7-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseCodeTableView.h"

@interface StockAdjustView : UIViewController
// ADD: delegate protocol
< ZBarReaderDelegate,UITextFieldDelegate,NSXMLParserDelegate,UITableViewDelegate,UITableViewDataSource,BaseCodeTableViewDelegate >
{
    UITextField *orglocno;
    UITextField *tolocno;
    UITextField *goodsqty;
	UISwitch *orgswitch;
    UISwitch *toswitch;
    UITableView *stocktableview;
    UIAlertView *activityView;
    UIActivityIndicatorView *activityIndicator;
    uint txtindex;
    UIScrollView *scrollView;
    NSMutableArray *stockList;
    NSArray *baseCodeList;
}

@property (nonatomic, retain) IBOutlet UITextField *orglocno;
@property (nonatomic, retain) IBOutlet UITextField *tolocno;
@property (nonatomic, retain) IBOutlet UITextField *goodsqty;
@property (nonatomic, retain) IBOutlet UISwitch *orgswitch;
@property (nonatomic, retain) IBOutlet UISwitch *toswitch;
@property (nonatomic, retain) IBOutlet UITableView *stocktableview;
@property (nonatomic, retain) UIAlertView *activityView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) NSMutableArray *stockList;
@property (nonatomic, retain) NSArray *baseCodeList;

- (IBAction) orgButtonTapped;
- (IBAction) toButtonTapped;
- (IBAction) scrollToBottom:(id)sender;
- (IBAction) getStockList;
-(void)DidCodeInput:(NSDictionary *)codes;
@end
