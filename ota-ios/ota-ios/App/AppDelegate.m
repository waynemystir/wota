//
//  AppDelegate.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/24/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "AppDelegate.h"
#import "AppEnvironment.h"
#import "JNKeychain.h"
#import "MainViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GMSServices provideAPIKey:GOOGLE_API_KEY];
    MainViewController *mvc = [MainViewController new];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:mvc];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = nc;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // Curtesy of http://stackoverflow.com/questions/4747404/delete-keychain-items-when-an-app-is-uninstalled
    // TODO: Consider using another approach, like checking if there is a file in cache
    // for Selection Criteria. I say this because there might be an issue with using User
    // Defaults for this purpose: http://stackoverflow.com/questions/20269116/nsuserdefaults-loosing-its-keys-values-when-phone-is-rebooted-but-not-unlocked
    //Clear keychain on first run in case of reinstallation
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"daFirstRun"]) {
        
        // Delete values from keychain here
        [JNKeychain deleteValueForKey:kKeyDaNumber];
        [JNKeychain deleteValueForKey:kKeyExpMonth];
        [JNKeychain deleteValueForKey:kKeyExpYear];
        [JNKeychain deleteValueForKey:kKeyPostalCode];
        
        [[NSUserDefaults standardUserDefaults] setValue:@"da1stRun" forKey:@"daFirstRun"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
