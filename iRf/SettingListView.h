//
//  SettingListView.h
//  iRf
//
//  Created by pro on 13-1-11.
//
//

#import <UIKit/UIKit.h>

@interface SettingListView : UITableViewController
<UITextFieldDelegate>
{
    NSMutableDictionary *settingData;
    UITextField *username;
    UITextField *password;
    UIButton *testBtn;
    UISwitch *internet;
    UITextField *server;
}

@property (nonatomic,retain) NSMutableDictionary *settingData;
@property (nonatomic,retain) UITextField *username;
@property (nonatomic,retain) UITextField *password;
@property (nonatomic,retain) UIButton *testBtn;
@property (nonatomic,retain) UISwitch *internet;
@property (nonatomic,retain) UITextField *server;

@end
