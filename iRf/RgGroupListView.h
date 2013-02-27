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
    
    
    NSDictionary *searchObj;
    
    int titleFontSize;
    int detailFontSize;
}

@property (nonatomic, strong) NSMutableArray *menuList;
@property (nonatomic, strong) NSArray *objs;
@property (nonatomic, strong) NSDictionary *searchObj;


- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;
- (void)searchCallBack:(NSDictionary *)_fields;
@end
