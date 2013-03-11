//
//  BasecodeStockList.h
//  iRf
//
//  Created by pro on 13-1-24.
//
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface BasecodeStockList : UITableViewController
<EGORefreshTableHeaderDelegate,ZBarReaderDelegate>

{
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
    NSString *currentCode;
    NSArray *dataList;

@private
    NSArray *colors;

}

@property (nonatomic,strong) NSArray *dataList;
@property (nonatomic,copy) NSString *currentCode;
@property (nonatomic,strong) NSArray *colors;

- (IBAction) scrollToRefresh:(id)sender;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
