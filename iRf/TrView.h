//
//  TrView.h
//  iRf
//
//  Created by user on 11-8-31.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrView : UIViewController
<UITextFieldDelegate>
{
    UIScrollView *scrollView;
    UITextField *ugoodsid;
    UITextField *goodsname;
    UITextField *goodstype;
    UITextField *tradename;
    UITextField *factno;
    UITextField *goodsunit;
    UITextField *cusgdsid;
    UITextField *multi;
    NSDictionary *values;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UITextField *ugoodsid;
@property (nonatomic, retain) IBOutlet UITextField *goodsname;
@property (nonatomic, retain) IBOutlet UITextField *goodstype;
@property (nonatomic, retain) IBOutlet UITextField *tradename;
@property (nonatomic, retain) IBOutlet UITextField *factno;
@property (nonatomic, retain) IBOutlet UITextField *goodsunit;
@property (nonatomic, retain) IBOutlet UITextField *cusgdsid;
@property (nonatomic, retain) IBOutlet UITextField *multi;
@property (nonatomic, retain) IBOutlet NSDictionary *values;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil values:(NSDictionary*)obj ;

@end
