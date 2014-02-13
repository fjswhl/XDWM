//
//  AppDelegate.m
//  XDWM
//
//  Created by Lin on 14-2-4.
//  Copyright (c) 2014年 WeAround. All rights reserved.
//

#import "AppDelegate.h"
#import "MKNetworkEngine.h"
#import "MKNetworkOperation.h"

#import "ADDRMACRO.h"
#include "LINUserModel.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:@"192.168.1.100:80"];
  //  NSString *username = @"飞哥";
  //  const char *sss = [username cStringUsingEncoding:NSUTF8StringEncoding];
  //  NSString *uss  = [NSString stringWithCString:[username cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSUTF8StringEncoding];
    NSDictionary *dic = @{@"key1":@"10",
                          @"key2":@"0"};
    MKNetworkOperation *op = [engine operationWithPath:[NSString stringWithFormat:@"%@%@",__PHPDIR__,@"messageboard.php"] params:dic httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSString *st = [completedOperation responseString];
        NSArray *arr = [NSJSONSerialization JSONObjectWithData:[st dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];

    } errorHandler:nil];
    [engine enqueueOperation:op];
//    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
//        NSLog(@"%@", [completedOperation responseString]);
//
//        NSData *data = [completedOperation responseData];
//        NSString *st = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        //NSLog(@"%@", st);
//
//        NSData *data2 = [[completedOperation responseString] dataUsingEncoding:NSUTF8StringEncoding];
//        //[NSString alloc] initWithCString:[comp] encoding:<#(NSStringEncoding)#>
//    } errorHandler:nil];

    
//    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
//        NSLog(@"%@", [completedOperation responseString]);
//    } errorHandler:nil];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
