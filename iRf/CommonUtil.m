//
//  CommonUtil.m
//  iRf
//
//  Created by pro on 12-11-24.
//
//

#import "CommonUtil.h"

@implementation CommonUtil

static NSString *settingPath;
static NSDictionary *settingData;


+ (void) alert:(NSString*)title msg:(NSString*)msg
{
    // open an alert with just an OK button
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];
}

+ (NSString*) getSettingPath
{
    
    if (!settingPath) {
        //获取应用程序沙盒的Documents目录
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        settingPath =  [documentDirectory stringByAppendingPathComponent:@"setting.plist"];
        
        NSLog(@"setting path = %@",settingPath);
    }
    return [settingPath copy];
}

+ (NSDictionary *) getSettings
{
    if (!settingData) {
        [CommonUtil rebuildSetting];
    }
    return [settingData copy];
}

+ (NSDictionary *) rebuildSetting
{
    NSString *settingPath = [self getSettingPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:settingPath]) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"true",kSettingInternetKey,
                              nil];
        NSString *error;
        
        NSData *xmlData = [NSPropertyListSerialization dataFromPropertyList:dict
                                                                     format:NSPropertyListXMLFormat_v1_0
                                                           errorDescription:&error];
        if(xmlData) {
            [xmlData writeToFile:settingPath atomically:YES];
        }
        else {
            NSLog(@"error = %@",error);
            [error release];
        }
    }
    
    settingData = [[NSDictionary alloc] initWithContentsOfFile:settingPath];
    NSLog(@"setting data = %@", settingData);
    return [settingData copy];
}
@end
