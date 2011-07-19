//
//  RootViewController.h
//  iRf
//
//  Created by pro on 11-7-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface RootViewController : UITableViewController {
    NSMutableArray *menuList;
}

@property (nonatomic, retain) NSMutableArray *menuList;
@end
