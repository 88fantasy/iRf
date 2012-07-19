//
//  MedicineReqListView.h
//  iRf
//
//  Created by xian weijian on 12-7-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface MedicineReqListView : UITableViewController
<EGORefreshTableHeaderDelegate,UIAlertViewDelegate>
{
    NSMutableArray *dataList;
    
    EGORefreshTableHeaderView *_refreshHeaderView; 
    BOOL _reloading;
    BOOL _firstloaded;
    UIAlertView *activityView;
    UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, retain) NSMutableArray *dataList;
@property (nonatomic, retain) UIAlertView *activityView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

- (void)reloadTableViewDataSource; 
- (void)doneLoadingTableViewData;

@end
