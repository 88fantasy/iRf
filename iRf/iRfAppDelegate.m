//
//  iRfAppDelegate.m
//  iRf
//
//  Created by pro on 11-7-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "iRfAppDelegate.h"

#import "RootViewController.h"
#import "iRfRgService.h"

@implementation iRfAppDelegate


@synthesize window=_window;

@synthesize managedObjectContext=__managedObjectContext;

@synthesize managedObjectModel=__managedObjectModel;

@synthesize persistentStoreCoordinator=__persistentStoreCoordinator;

@synthesize navigationController=_navigationController;

@synthesize devtoken,currentuser;

+ (BOOL)checkHostReachability {
	Reachability* hostReach = [Reachability reachabilityWithHostName: host] ;
	NetworkStatus netStatus = [hostReach currentReachabilityStatus];
	if (netStatus == NotReachable ) {
		// open an alert with just an OK button
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"连接服务器出现错误" 
                                                        message:@"请检查是否已连上互联网"
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
		return NO;
	}
	else {
		return YES;
	}
    
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
       
    // Finish app initialization...
    
    NSLog(@"Finish app initialization");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults stringForKey:@"username_preference"];
    
    self.currentuser = username;
    
    if (IsInternet) {
        [iRfAppDelegate checkHostReachability];
        
//        UIRemoteNotificationType rntype = [application enabledRemoteNotificationTypes];
//        NSLog(@"%d",rntype);
//        if (rntype == UIRemoteNotificationTypeNone) {
            // Register for push notifications 注册推送服务
            [application registerForRemoteNotificationTypes:
             UIRemoteNotificationTypeBadge |
             UIRemoteNotificationTypeAlert |
             UIRemoteNotificationTypeSound];
            
            // 注销推送服务
//            [application unregisterForRemoteNotifications];
//        }
    }

    
    // Add the navigation controller's view to the window and display.
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
//    当程序不在运行(后台和前台都不在运行) 会运行以下代码
//    看是否有push notification到达，并做相应处理，这个方法和local notification相同，但注意key要对应就行 
//    UILocalNotification *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//    if (remoteNotification) {
//        //弹出一个alertview,显示相应信息
//        UIAlertView * al = [[UIAlertView alloc]initWithTitle:@"receive remote notification!" message:@"hello" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//        [al show];
//        [al release];
        
//        NSLog(@"%@",remoteNotification);
//        [self application:application didReceiveRemoteNotification:remoteNotification.userInfo];
//    }
//    代码end
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    NSLog(@"application inactive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    NSLog(@"application enter background");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    NSLog(@"application enter foreground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    NSLog(@"application active");
    
//    检查切换账号
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults stringForKey:@"username_preference"];
    NSLog(@"currentuser=%@,settinguser=%@",self.currentuser,username);
    if (![username isEqualToString:self.currentuser]) {
        if (IsInternet) {
        
            NSLog(@"update server");
            NSDictionary *obj = [NSDictionary dictionaryWithObjectsAndKeys:
                                 self.devtoken,@"token",
                                 username,@"username",
                                 nil];
            SBJsonWriter *writer = [[SBJsonWriter alloc] init];
            NSString *json = [writer stringWithObject:obj];
            
            iRfRgService* service = [iRfRgService service];
            
            [service setIRfSetting:self action:@selector(setIRfSettingHandler:) username:@"iRfsetting" password:nil jsonObject:json];
            
            
        }
        self.currentuser = username;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)dealloc
{
    [_window release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [_navigationController release];
    [super dealloc];
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iRf" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"iRf.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - 
#pragma mark push notifications handle

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    NSLog(@"Device Token=%@",newDeviceToken);
    NSString *token = [NSString stringWithFormat:@"%@",newDeviceToken];
    self.devtoken = [token substringWithRange:NSMakeRange(1, [token length]-2)];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults stringForKey:@"username_preference"];
    
    NSDictionary *obj = [NSDictionary dictionaryWithObjectsAndKeys:
                         self.devtoken,@"token",
                         username,@"username",
                         nil];
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *json = [writer stringWithObject:obj];
    
    iRfRgService* service = [iRfRgService service];
    
    [service setIRfSetting:self action:@selector(setIRfSettingHandler:) username:@"iRfsetting" password:nil jsonObject:json];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Fail to get Device Token=%@",[error localizedDescription]);
}

//广播频道（broadcast channel）用于同时联系到所有用户，所以很多时候开发者可能需要自己创建一些更精准化的频道。一旦推送通知被接受但是应用不在前台，就会被显示在iOS推送中心。反之如果应用刚好处于活动状态，则交于应用去自行处理。具体我们可以在app delegate中实现[application:didReceiveRemoteNotification]方法。
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Receive a Remote Notification : %@",userInfo);
    //可以根据application状态来判断，程序当前是在前台还是后台
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateInactive) {
        
        // Application was in the background when notification
        // was delivered.
    }
}


- (void)setIRfSettingHandler:(id)value {
    // Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
        NSError* result = (NSError*)value;
        
        [CommonUtil alert:@"连接失败" msg:[result localizedFailureReason]];
    }
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
        SoapFault * result = (SoapFault*)value;
        [CommonUtil alert:@"soap连接失败" msg:[result faultString]];
	}
    NSLog(@"setting success");
}
@end
