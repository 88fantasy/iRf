//
//  NtrListView.h
//  iRf
//
//  Created by user on 11-8-30.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface TrListView : UIViewController
<UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate
,UISearchDisplayDelegate, UISearchBarDelegate>
{
    NSMutableArray *menuList;
    
    EGORefreshTableHeaderView *_refreshHeaderView; 
    BOOL _reloading;
    BOOL _firstloaded;
    UIBarButtonItem *refreshButtonItem;
    UIAlertView *activityView;
    UIActivityIndicatorView *activityIndicator;
    
    
    NSString		*savedSearchTerm;
    NSInteger		savedScopeButtonIndex;
    BOOL			searchWasActive;
    NSMutableArray	*filteredListContent;	// The content filtered as a result of a search.
    UISearchDisplayController *seachDispalyController;
    UITableView *tablelistView;
}

@property (nonatomic, retain) NSMutableArray *menuList;
@property (nonatomic, retain) UIBarButtonItem *refreshButtonItem;
@property (nonatomic, retain) UIAlertView *activityView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) UITableView *tablelistView;

@property (nonatomic, retain) NSMutableArray *filteredListContent;

@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

- (IBAction) scrollToRefresh:(id)sender;
- (void)reloadTableViewDataSource; 
- (void)doneLoadingTableViewData;

@end
