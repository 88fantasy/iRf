//
//  CommonUtil.h
//  iRf
//
//  Created by pro on 12-11-24.
//
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@interface CommonUtil : NSObject
{

}

+ (void) alert:(NSString*)title msg:(NSString*)msg;

+ (NSString*) getSettingPath;

+ (NSDictionary*) getSettings;

+ (NSDictionary*) rebuildSetting;

@end
