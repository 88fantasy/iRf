//
//  NtrListView.h
//  iRf
//
//  Created by user on 11-8-30.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface TrListView : UITableViewController
<UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate>
{
    NSMutableArray *menuList;
    
    EGORefreshTableHeaderView *_refreshHeaderView; 
    BOOL _reloading;
    
    UIBarButtonItem *refreshButtonItem;
    UIAlertView *activityView;
    UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, retain) NSMutableArray *menuList;
@property (nonatomic, retain) UIBarButtonItem *refreshButtonItem;
@property (nonatomic, retain) UIAlertView *activityView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;


- (IBAction) scrollToRefresh:(id)sender;
- (void)reloadTableViewDataSource; 
- (void)doneLoadingTableViewData;

@end
