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
}

@property (nonatomic, strong) NSMutableArray *dataList;

- (void)reloadTableViewDataSource; 
- (void)doneLoadingTableViewData;

@end
