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
#import "LINRootViewController.h"
#import "ADDRMACRO.h"
#include "LINUserModel.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
//    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:__HOSTNAME__];
//    MKNetworkOperation *op = [engine operationWithPath:[NSString stringWithFormat:@"%@%@",__PHPDIR__,@"fetch_ancmt.php"] params:@{@"key1":@"10", @"key2":@"0"} httpMethod:@"POST"];
//    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
//        NSLog(@"%@", [completedOperation responseString]);
//    } errorHandler:nil];
//    [engine enqueueOperation:op];

    LINRootViewController *tbc = (LINRootViewController *)self.window.rootViewController;
    tbc.delegate = self;
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

- (id<UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController animationControllerForTransitionFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.4;
}

//- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
//    UIViewController *vc1 = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    UIViewController *vc2 = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//    
//    UIView *con = [transitionContext containerView];
//    CGRect r1start = [transitionContext initialFrameForViewController:vc1];
//    CGRect r2end = [transitionContext finalFrameForViewController:vc2];
//    UIView *v1 = vc1.view;
//    UIView *v2 = vc2.view;
//    
//    UITabBarController *tbc = (UITabBarController *)self.window.rootViewController;
//    int index1 = [tbc.viewControllers indexOfObject:vc1];
//    int index2 = [tbc.viewControllers indexOfObject:vc2];
//    int dir = index1 < index2 ? 1 : -1;
//    CGRect r = r1start;
//    r.origin.x -= r.size.width * (dir / 4.0);
//    CGRect r1end = r;
//    r = r2end;
//    r.origin.x += r.size.width *dir;
//    CGRect r2start = r;
//    
//    v2.frame = r2start;
//    
//    UIView *shalldow = [[UIView alloc] initWithFrame:r2end];
//    shalldow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
//    shalldow.alpha = 0;
//    [con addSubview:shalldow];
//    [con addSubview:v2];
//
//    [UIView animateWithDuration:0.4 animations:^{
//        shalldow.alpha = 1;
//        v1.frame = r1end;
//        v2.frame = r2end;
//    }completion:^(BOOL finished) {
//        [transitionContext completeTransition:YES];
//    }];
//}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{

    UINavigationController *vc2 = (UINavigationController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *con = [transitionContext containerView];
    CGRect r2end = [transitionContext finalFrameForViewController:vc2];

    UIView *v2 = vc2.view;
    

    
    v2.frame = r2end;

    UIView *shalldow = [[UIView alloc] initWithFrame:r2end];
    shalldow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    shalldow.alpha = 0;
    [con addSubview:shalldow];
    [con addSubview:v2];
    
        v2.transform = CGAffineTransformMakeScale(0.7, 0.7);
    [UIView animateWithDuration:0.4 animations:^{
        shalldow.alpha = 1;
        //        v1.frame = r1end;
        //        v2.frame = r2end;
        v2.transform = CGAffineTransformMakeScale(1, 1);
    }completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
    //    [tbc setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - getter
- (MKNetworkEngine *)engine{
    if (!_engine) {
        _engine = [[MKNetworkEngine alloc] initWithHostName:__HOSTNAME__];
    }
    return _engine;
}

- (AFHTTPRequestOperationManager *)manager{
    if (!_manager) {
        _manager = [AFHTTPRequestOperationManager manager];
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    }
    return _manager;
}
@end


































