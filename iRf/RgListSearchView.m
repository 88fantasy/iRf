//
//  RgListSearchView.m
//  iRf
//
//  Created by user on 11-9-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "RgListSearchView.h"


@implementation RgListSearchView

@synthesize scrollView,goodsname,prodarea,lotno,invno,startdate,enddate;
@synthesize finButton,tmp;
@synthesize rgListSearchViewDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"查询条件";
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil value:(NSMutableDictionary*)obj
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        searchFields = obj;
        
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
    
    self.navigationItem.rightBarButtonItem = self.finButton;
//    self.goodsname.text = [searchFields objectForKey:@"goodsname"];
//    self.prodarea.text = [searchFields objectForKey:@"prodarea"];
//    self.lotno.text = [searchFields objectForKey:@"lotno"];
//    self.invno.text = [searchFields objectForKey:@"invno"];
//    self.startdate.text = [searchFields objectForKey:@"startdate"];
//    self.enddate.text = [searchFields objectForKey:@"enddate"];
    
   
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.scrollView = nil;
    self.goodsname = nil;
    self.prodarea = nil;
    self.lotno = nil;
    self.invno = nil;
    self.startdate = nil;
    self.enddate = nil;
    self.finButton = nil;
    self.tmp = nil;
}

- (void) dealloc{

    [scrollView release];
    [goodsname release];
    [prodarea release];
    [lotno release];
    [invno release];
    [startdate release];
    [enddate release];
    [finButton release];
    [tmp release];
    [super dealloc];
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.startdate || textField == self.enddate) {
        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
        
        self.tmp = textField;
        
        NSDate *date = [NSDate date];
        
        if (!([textField.text isEqualToString:@""] || textField.text == nil )) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            date = [formatter dateFromString:textField.text];
        }
        
        [datePicker setDate:date animated:YES];
        
        datePicker.datePickerMode = UIDatePickerModeDate;
        
        [datePicker addTarget:self action:@selector(dateAction:) forControlEvents:UIControlEventValueChanged];
        //UITextField的inputView属性代替标准的系统键盘
        
        textField.inputView = datePicker;//inputView相当于给弹出datePicker控件的动画的功能;定制键盘来使用datePicker,弹出datePicker与弹出键盘方式一样
        // Configure the view for the selected state
        if (textField.inputAccessoryView == nil) {
            UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
            numberToolbar.barStyle = UIBarStyleBlackTranslucent;
            numberToolbar.items = [NSArray arrayWithObjects:
                                   [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Cancel",@"Cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(canceldate)],
                                   [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                   [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Apply",@"Apply") style:UIBarButtonItemStyleDone target:self action:@selector(applydate )],
                                   nil];
            [numberToolbar sizeToFit];
            textField.inputAccessoryView = numberToolbar;
            [numberToolbar release];
        }
        
        [datePicker release];
    }
    
	return YES;
}

- (void) canceldate
{
    self.tmp.text = @"";
    [self applydate];
}

- (void) applydate
{
    [self.tmp resignFirstResponder];
}



- (IBAction) finSearch:(id)sender{
//    if (self.goodsname.text != nil) {
//        [searchFields setObject:self.goodsname.text forKey:@"goodsname"];
//    }
//    else{
//        [searchFields removeObjectForKey:@"goodsname"];
//    }
//    
//    if (self.prodarea.text != nil) {
//       [searchFields setObject:self.prodarea.text forKey:@"prodarea"];
//    }
//    else{
//        [searchFields removeObjectForKey:@"prodarea"];
//    }
//    
//    if (self.lotno.text != nil) {
//        [searchFields setObject:self.lotno.text forKey:@"lotno"];
//    }
//    else{
//        [searchFields removeObjectForKey:@"lotno"];
//    }
//    
//    if (self.invno.text != nil) {
//        [searchFields setObject:self.invno.text forKey:@"invno"];
//    }
//    else{
//        [searchFields removeObjectForKey:@"invno"];
//    }
//    
//    if (self.startdate.text != nil) {
//        [searchFields setObject:self.startdate.text forKey:@"startdate"];
//    }
//    else{
//        [searchFields removeObjectForKey:@"startdate"];
//    }
//    
//    if (self.enddate.text != nil) {
//        [searchFields setObject:self.enddate.text forKey:@"enddate"];
//    }
//    else{
//        [searchFields removeObjectForKey:@"enddate"];
//    }
    
    NSDictionary *fields = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.goodsname.text==nil?@"":self.goodsname.text,@"goodsname",
                            self.prodarea.text==nil?@"":self.prodarea.text,@"prodarea",
                            self.lotno.text==nil?@"":self.lotno.text,@"lotno",
                            self.invno.text==nil?@"":self.invno.text,@"invno",
                            self.startdate.text==nil?@"":self.startdate.text,@"startdate",
                            self.enddate.text==nil?@"":self.enddate.text,@"enddate",
                            @"0",@"rgflag",
                            nil];
    [self.navigationController popViewControllerAnimated:YES];
    if (self.rgListSearchViewDelegate!=nil) { 
        //调用回调函数 
        [self.rgListSearchViewDelegate searchCallBack:fields]; 
    } 
}

- (void)dateAction:(UIDatePicker *)sender
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    self.tmp.text = [formatter stringFromDate:sender.date];
}
@end
