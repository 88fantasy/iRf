//
//  RgListSearchView.h
//  iRf
//
//  Created by user on 11-9-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol RgListSearchViewDelegate 
//回调函数 
-(void)searchCallBack:(NSDictionary *)_fields; 
@end

@interface RgListSearchView : UIViewController
<UITextFieldDelegate>
{
    UIScrollView *scrollView;
    UITextField *goodsname;
    UITextField *prodarea;
    UITextField *lotno;
    UITextField *invno;
    UITextField *startdate;
    UITextField *enddate;
    
    UIDatePicker *pickerView;
	UIBarButtonItem *doneButton;
    UIBarButtonItem *finButton;
    UITextField *tmp;
    NSMutableDictionary *searchFields;
    id<RgListSearchViewDelegate> rgListSearchViewDelegate;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UITextField *goodsname;
@property (nonatomic, retain) IBOutlet UITextField *prodarea;
@property (nonatomic, retain) IBOutlet UITextField *lotno;
@property (nonatomic, retain) IBOutlet UITextField *invno;
@property (nonatomic, retain) IBOutlet UITextField *startdate;
@property (nonatomic, retain) IBOutlet UITextField *enddate;

@property (nonatomic, retain) IBOutlet UIDatePicker *pickerView; 
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *finButton;
@property (nonatomic, retain) IBOutlet UITextField *tmp;
@property (nonatomic,retain) id<RgListSearchViewDelegate>  rgListSearchViewDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil value:(NSMutableDictionary*)obj;
- (IBAction) showDatePicker:(id)sender;
- (IBAction) closeDatePicker:(id)sender;
- (IBAction) finSearch:(id)sender;
- (IBAction)dateAction:(id)sender;
@end
