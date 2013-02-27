//
//  RgListView.h
//  iRf
//
//  Created by pro on 11-7-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "RgListSearchView.h"
#import "KDGoalBar.h"

@interface RgListView : UITableViewController
<UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate,RgListSearchViewDelegate,
UIActionSheetDelegate>
{
    NSMutableArray *menuList;
    NSArray *objs;
    
    BOOL canReload;
    EGORefreshTableHeaderView *_refreshHeaderView; 
    BOOL _reloading;
    
    UIBarButtonItem *refreshButtonItem;
    
    NSDictionary *searchObj;
    
    UIAlertView *goalBarView;
    KDGoalBar *goalBar;
    
    int notDoRgCount;
    int doneDoRgCoount;
    
    int titleFontSize;
    int detailFontSize;
    
}

@property (nonatomic, strong) NSMutableArray *menuList;
@property (nonatomic, strong) NSArray *objs;
@property (nonatomic, strong) UIBarButtonItem *refreshButtonItem;

@property (nonatomic, strong) NSDictionary *searchObj;

@property (nonatomic, strong) UIAlertView *goalBarView;
@property (nonatomic, strong) KDGoalBar *goalBar;


- (id)initWithStyle:(UITableViewStyle)style objs:(NSArray*)_arrays;
- (IBAction) setSearchJson:(id)sender;
- (void)reloadTableViewDataSource; 
- (void)doneLoadingTableViewData;
- (void)searchCallBack:(NSDictionary *)_fields;
@end
