//
//  RgListView.h
//  iRf
//
//  Created by pro on 11-7-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface RgListView : UITableViewController
<UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate>
{
    NSMutableArray *menuList;
    NSArray *objs;
    
    BOOL canReload;
    EGORefreshTableHeaderView *_refreshHeaderView; 
    BOOL _reloading;
    
    UIBarButtonItem *refreshButtonItem;
    UIAlertView *activityView;
    UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, retain) NSMutableArray *menuList;
@property (nonatomic, retain) NSArray *objs;
@property (nonatomic, retain) UIBarButtonItem *refreshButtonItem;
@property (nonatomic, retain) UIAlertView *activityView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

- (id)initWithStyle:(UITableViewStyle)style objs:(NSArray*)_arrays;
- (IBAction) scrollToRefresh:(id)sender;
- (void)reloadTableViewDataSource; 
- (void)doneLoadingTableViewData;
@end
