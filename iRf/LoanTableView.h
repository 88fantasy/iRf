//
//  LoanTableView.h
//  iRf
//
//  Created by pro on 13-3-13.
//
//

#import <UIKit/UIKit.h>
#import "BAMethod.h"
#import "DataSetRequest.h"


@interface LoanTableView : UITableViewController
<DataSetRequestDelegate>
{
    BAMethod *_ba;
    DataSetRequest *dsr;
}
@end
