//
//  AppDelegate.h
//  XDWM
//
//  Created by Lin on 14-2-4.
//  Copyright (c) 2014年 WeAround. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperationManager.h"
#import "MKNetworkEngine.h"
#import <CoreData/CoreData.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, UIViewControllerAnimatedTransitioning>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MKNetworkEngine *engine;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;

// Core Data
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinate;

- (void)saveContext;
- (NSURL *)applicationDocumentDirectory;
@end
