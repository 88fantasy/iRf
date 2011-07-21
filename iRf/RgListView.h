//
//  RgListView.h
//  iRf
//
//  Created by pro on 11-7-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RgListView : UITableViewController
{
    NSMutableArray *menuList;
    NSArray *objs;
}

@property (nonatomic, retain) NSMutableArray *menuList;
@property (nonatomic, retain) NSArray *objs;

- (id)initWithStyle:(UITableViewStyle)style objs:(NSArray*)_arrays;

@end
