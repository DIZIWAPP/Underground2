//
//  UGAppDelegate.m
//  Underground
//
//  Created by Jon Como on 5/8/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "UGAppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "UGGraphics.h"
#import "JCParseManager.h"
#import "UGMacros.h"
#import "Macros.h"

#import "UGTabBarController.h"

#import "UGLiveViewController.h"

#import "UGPush.h"

#import "UGVideoCell.h"
#import "UGVideo.h"
#import "UGVideoViewController.h"

#import <FacebookSDK/FacebookSDK.h>

#import "UGRSSManager.h"

@implementation UGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    //Loading to SB database
    [Parse setApplicationId:@"axDKqy2zc81hTwzJoy9SN7PJ5wckhgywG3AxCqZ3" clientKey:@"7cfH9K3eEfs5kw3yzHLJsZt4b8mcP8eqwroieQ59"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    //[PFFacebookUtils initializeFacebook];
    //[PFTwitterUtils initializeWithConsumerKey:@"Def8uyIEmcWBmxVxc3CA35i12" consumerSecret:@"spFwRJmrQ2dTXjkBW8rglV1tUibk3QoJfv0vguPusIUJdj1csJ"];
    
    //[[JCParseManager sharedManager] registerAnonymousUserCompletion:nil];
    
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey])
        [[UGPush manager] handlePush:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
    
    [UGGraphics initGraphics];
    
    return YES;
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[UGPush manager] handlePush:userInfo];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current Installation and save it to Parse.
    [[JCParseManager sharedManager] setDeviceOwnerWithToken:deviceToken];
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
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    UIViewController *vc = window.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
        if ([vc isKindOfClass:[UGLiveViewController class]]){
            return UIInterfaceOrientationMaskAllButUpsideDown;
        }
    }
    
    return UIInterfaceOrientationMaskPortrait;
}

//Facebook

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

@end
