//
//  AppDelegate.m
//  FallingBall
//
//  Created by Georges Kanaan on 6/10/14.
//  Copyright (c) 2014 Georges Kanaan. All rights reserved.
//

#import "AppDelegate.h"

#import <StoreKit/StoreKit.h>

@interface AppDelegate ()

void exceptionHandler(NSException * exception);

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.
  // Set default values
  if (![[NSUserDefaults standardUserDefaults] boolForKey:@"notFirstLaunch"]) {// If first launch
    
    //highscore
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"highscore"];
    
    // Enable music
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"music"];
    
    // Enable vibration
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"vibration"];
    
    // Not the first launch
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"notFirstLaunch"];
 
  } else {
    // Asking for reviews
	[SKStoreReviewController requestReview];
  }
  // Disable the idleTimer
  [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
  
  // Disable game center until authenticated
  [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"GameCenter"];
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  SKView *skView = (SKView *)self.window.rootViewController.view;
  if ([skView.scene isKindOfClass:[GameScene class]]) {
    GameScene *gameScene = (GameScene *)skView.scene;
    [gameScene pauseGame];
  }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  SKView *skView = (SKView *)self.window.rootViewController.view;
  if ([skView.scene isKindOfClass:[GameScene class]]) {
    GameScene *gameScene = (GameScene *)skView.scene;
    [gameScene resumeGame];
  }
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
  return UIInterfaceOrientationMaskLandscape;
}

@end
