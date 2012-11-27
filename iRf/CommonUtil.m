//
//  CommonUtil.m
//  iRf
//
//  Created by pro on 12-11-24.
//
//

#import "CommonUtil.h"

@implementation CommonUtil


+ (void) alert:(NSString*)title msg:(NSString*)msg {
    // open an alert with just an OK button
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];
}

@end
