//
//  RgGroupListView.h
//  iRf
//
//  Created by pro on 12-11-30.
//
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "RgListSearchView.h"

@interface RgGroupListView : UITableViewController
<UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate,RgListSearchViewDelegate>
{
    NSMutableArray *menuList;
    NSArray *objs;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
    UIAlertView *activityView;
    UIActivityIndicatorView *activityIndicator;
    
    NSDictionary *searchObj;
    
}

@property (nonatomic, retain) NSMutableArray *menuList;
@property (nonatomic, retain) NSArray *objs;
@property (nonatomic, retain) UIAlertView *activityView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) NSDictionary *searchObj;


- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;
- (void)searchCallBack:(NSDictionary *)_fields;
@end
