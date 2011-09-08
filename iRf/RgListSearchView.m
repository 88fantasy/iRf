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
@synthesize pickerView,doneButton,finButton,tmp;
@synthesize rgListSearchViewDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        searchFields = [[NSDictionary alloc] initWithObjectsAndKeys: nil];
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
    self.pickerView = nil;
    self.doneButton = nil;
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
    [pickerView release];
    [doneButton release];
    [finButton release];
    [tmp release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//- (BOOL)textFieldShouldClear:(UITextField *)textField
//{
//    [self closeDatePicker:nil];
//    [textField resignFirstResponder];
//	return YES;
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	[textField resignFirstResponder];
	return YES;
}


- (IBAction) showDatePicker:(id)sender{
    [self.scrollView setContentOffset:CGPointMake(0, 100) animated:YES];
    self.tmp = (UITextField*)sender;
    [sender resignFirstResponder];
    // check if our date picker is already on screen
	if (self.pickerView.superview == nil)
	{
		[self.view.window addSubview: self.pickerView];
		
		// size up the picker view to our screen and compute the start/end frame origin for our slide up animation
		//
		// compute the start frame
		CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
		CGSize pickerSize = [self.pickerView sizeThatFits:CGSizeZero];
		CGRect startRect = CGRectMake(0.0,
									  screenRect.origin.y + screenRect.size.height,
									  pickerSize.width, pickerSize.height);
		self.pickerView.frame = startRect;
		
		// compute the end frame
		CGRect pickerRect = CGRectMake(0.0,
									   screenRect.origin.y + screenRect.size.height - pickerSize.height,
									   pickerSize.width,
									   pickerSize.height);
		// start the slide up animation
		[UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
		
        // we need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
		
        self.pickerView.frame = pickerRect;
		
        // shrink the table vertical size to make room for the date picker
        CGRect newFrame = self.view.frame;
        newFrame.size.height -= self.pickerView.frame.size.height;
        self.view.frame = newFrame;
		[UIView commitAnimations];
		
		// add the "Done" button to the nav bar
		self.navigationItem.rightBarButtonItem = self.doneButton;
	}
}

- (void)slideDownDidStop
{
	// the date picker has finished sliding downwards, so remove it
	[self.pickerView removeFromSuperview];
}

- (IBAction) closeDatePicker:(id)sender
{
    if (self.pickerView.superview != nil)
	{
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        CGRect endFrame = self.pickerView.frame;
        endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
        
        // start the slide down animation
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        // we need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
        
        self.pickerView.frame = endFrame;
        [UIView commitAnimations];
        
        // grow the table back again in vertical size to make room for the date picker
        CGRect newFrame = self.view.frame;
        newFrame.size.height += self.pickerView.frame.size.height;
        self.view.frame = newFrame;
        
        // remove the "Done" button in the nav bar
        self.navigationItem.rightBarButtonItem = self.finButton;
    //    [self dateAction:sender];
        self.tmp = nil;
    }
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
                            nil];
    [self.navigationController popViewControllerAnimated:YES];
    if (self.rgListSearchViewDelegate!=nil) { 
        //调用回调函数 
        [self.rgListSearchViewDelegate searchCallBack:fields]; 
    } 
}

- (IBAction)dateAction:(id)sender
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    self.tmp.text = [formatter stringFromDate:self.pickerView.date];
}
@end
