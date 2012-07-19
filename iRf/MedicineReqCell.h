//
//  MedicineReqCell.h
//  iRf
//
//  Created by xian weijian on 12-7-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MedicineReqCell : UITableViewCell
<UITextFieldDelegate>
{
    UILabel *goodsname;
    UILabel *goodstype;
    UILabel *locno;
    UILabel *lotno;
    UILabel *goodsqty;
    UILabel *houserealqty;
    UITextField *opqty;
    NSMutableDictionary *data;
}

@property (nonatomic,retain) IBOutlet UILabel *goodsname;
@property (nonatomic,retain) IBOutlet UILabel *goodstype;
@property (nonatomic,retain) IBOutlet UILabel *locno;
@property (nonatomic,retain) IBOutlet UILabel *lotno;
@property (nonatomic,retain) IBOutlet UILabel *goodsqty;
@property (nonatomic,retain) IBOutlet UILabel *houserealqty;
@property (nonatomic,retain) IBOutlet UITextField *opqty;
@property (nonatomic,retain) NSMutableDictionary *data;

@end
