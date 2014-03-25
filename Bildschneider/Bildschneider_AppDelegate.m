//
//  Bildschneider_AppDelegate.m
//  Bildschneider
//
//  Created by Ting Wu on 13-7-5.
//  Copyright (c) 2013年 Jia Daizi. All rights reserved.
//

#import "Bildschneider_AppDelegate.h"
#import <Dropbox/Dropbox.h>
#import <DBChooser/DBChooser.h>

@implementation Bildschneider_AppDelegate

#define kAppKey @"lg6qmy5u6ydekdn"
#define kAppSecret @"7ddavanzixrhdy9"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    DBAccountManager *accountManager = [[DBAccountManager alloc] initWithAppKey:kAppKey secret:kAppSecret];
    [DBAccountManager setSharedManager:accountManager];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    /*
    DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
    if (account) {
        NSLog(@"app link successfully!");
        return YES;
    }
    */
    if ([[DBChooser defaultChooser] handleOpenURL:url]) {
        //this was a chooser response and handleOpenURL automatically ran the completion
    }
    return NO;
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
