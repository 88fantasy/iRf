//
//  RgView.h
//  iRf
//
//  Created by pro on 11-7-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RgView : UIViewController
<UITextFieldDelegate>
{
    UIScrollView *scrollView;
    UITextField *invno;
    UITextField *goodsname;
    UITextField *goodstype;
    UITextField *factoryname;
    UITextField *goodsprice;
    UITextField *goodsunit;
    UITextField *lotno;
    UITextField *packsize;
    UITextField *validto;
    UITextField *orgrow;
    UITextField *goodsqty;
    UITextField *rgqty;
    UITextField *locno;
    NSString *spdid;
    NSDictionary *values;
    BOOL readOnlyFlag;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UITextField *invno;
@property (nonatomic, retain) IBOutlet UITextField *goodsname;
@property (nonatomic, retain) IBOutlet UITextField *goodstype;
@property (nonatomic, retain) IBOutlet UITextField *factoryname;
@property (nonatomic, retain) IBOutlet UITextField *goodsprice;
@property (nonatomic, retain) IBOutlet UITextField *goodsunit;
@property (nonatomic, retain) IBOutlet UITextField *lotno;
@property (nonatomic, retain) IBOutlet UITextField *packsize;
@property (nonatomic, retain) IBOutlet UITextField *validto;
@property (nonatomic, retain) IBOutlet UITextField *orgrow;
@property (nonatomic, retain) IBOutlet UITextField *goodsqty;
@property (nonatomic, retain) IBOutlet UITextField *rgqty;
@property (nonatomic, retain) IBOutlet UITextField *locno;
@property (nonatomic, retain) IBOutlet NSString *spdid;
@property (nonatomic, retain) IBOutlet NSDictionary *values;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil values:(NSDictionary*)obj readOnlyFlag:(BOOL) readOnlyFlag;
@end
