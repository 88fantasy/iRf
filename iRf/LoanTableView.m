//
//  LoanTableView.m
//  iRf
//
//  Created by pro on 13-3-13.
//
//

#import "LoanTableView.h"

@interface LoanTableView ()

@end

@implementation LoanTableView

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, self.tableView.frame.size.height - 44, self.tableView.frame.size.width, 44)];
////    [toolbar sizeToFit];
//    toolbar.contentMode  = UIViewContentModeBottom;
//    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(AddBtnHandle:)];
//
//    [toolbar setItems:@[item]];
//    toolbar.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self setToolbarItems:@[item]];
//    [self.tableView addSubview:toolbar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    //填写你需要锁定的方向参数
    return UIInterfaceOrientationIsLandscape( interfaceOrientation ) || (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.toolbarHidden = NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.toolbarHidden = YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LoanTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"LoanTableViewCell:%d",indexPath.row];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark -
#pragma mark Button Impl

- (IBAction)AddBtnHandle:(id)sender
{
//    _ba = [BAMethod baWithClassName:@"com.ebig.ba.PubService" moduleId:@"all" methodName:@"query" ];
//    [_ba invokeByAsync:@[@"select 1 from dual"] target:self action:@selector(testBA:) ] ;
    
    dsr = [[DataSetRequest alloc]initWithGridcode:@"func-inoutquery-grid" querytype:@"query" datasource:@"hscm_stock_group_sum" querymoduleid:@"all" sumfieldnames:nil];
    dsr.delegate = self;
    [dsr requestDataWithPage:1 pageNum:15 needpagecount:NO];
}

-(void) testBA:(id)value
{
    NSLog(@"%@",value);
}

-(void)didQueryData:(NSDictionary *)result
{
    NSLog(@"result : %@",result);
}

-(void)dataDidRead:(NSArray *)rows
{
    NSLog(@"rows : %@",rows);
}
@end
