//
//  AppDelegate.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/24/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "AppDelegate.h"
#import "AppEnvironment.h"
#import "JNKeychain.h"
#import "TrotterViewController.h"

static NSString *_externalIP = nil;

@interface AppDelegate ()

@property (nonatomic) Class spinnerClass;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[self class] acquireExternalIP];
    
    TrotterViewController *mvc = [TrotterViewController new];
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
        [JNKeychain deleteValueForKey:kKeyGuestInfo];
        
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

#pragma mark Spinner stuff

- (void)loadDaSpinner {
    // We're not going to fire off multiple spinners
    if (nil != _spinnerClass) {
        return;
    }
    
    // Curtesy of http://stackoverflow.com/questions/1451342/objective-c-find-caller-of-method
    NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
    [array removeObject:@""];
    
    TrotterLog(@"%@.%@:Class caller = %@, class = %@", self.class, NSStringFromSelector(_cmd), [array objectAtIndex:3], [[array objectAtIndex:3] class]);
    _spinnerClass = NSClassFromString([array objectAtIndex:3]);
    
    UIView *dWayne = [[UIView alloc] initWithFrame:CGRectMake(0, 64, 320, 504)];
    dWayne.tag = 91919191;
    dWayne.backgroundColor = [UIColor blackColor];
    dWayne.alpha = 0.0f;
    dWayne.userInteractionEnabled = YES;
    [_window addSubview:dWayne];
    [_window bringSubviewToFront:dWayne];
    
    UIActivityIndicatorView *theSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                                           UIActivityIndicatorViewStyleWhiteLarge];
    theSpinner.tag = 71717171;
    theSpinner.center = _window.center;
    theSpinner.alpha = 0.0f;
    
    [_window addSubview:theSpinner];
    [_window bringSubviewToFront:theSpinner];
    [theSpinner startAnimating];
    
    __weak UIActivityIndicatorView *sp = theSpinner;
    __weak UIView *ol = dWayne;
    
    [UIView animateWithDuration:0.3 animations:^{
        sp.alpha = 1.0f;
        ol.alpha = 0.8f;
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)dropDaSpinnerAlreadyWithForce:(BOOL)force {
    //    if (nil == _spinnerClass) {
    //        return;
    //    }
    
    NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
    [array removeObject:@""];
    
    TrotterLog(@"%@.%@:Class caller = %@, class = %@", self.class, NSStringFromSelector(_cmd), [array objectAtIndex:3], [[array objectAtIndex:3] class]);
    
    Class callingClass = NSClassFromString([array objectAtIndex:3]);
    
    UINavigationController *nc = (UINavigationController *) _window.rootViewController;
    Class tvcClass = [[nc topViewController] class];
    
    // We're not going to kill a spinner for a different view controller
    if (!force && callingClass != _spinnerClass && callingClass != tvcClass) {
        return;
    }
    _spinnerClass = nil;
    
    __weak UIActivityIndicatorView *sp = (UIActivityIndicatorView *) [_window viewWithTag:71717171];
    __weak UIView *dw = [_window viewWithTag:91919191];
    dw.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.6 animations:^{
        sp.alpha = 0.0f;
        dw.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [sp stopAnimating];
        [sp removeFromSuperview];
        [dw removeFromSuperview];
    }];
}

#pragma mark IP stuff

+ (NSString *)externalIP {
    if (!_externalIP) {
        [self acquireExternalIP];
    }
    
    return _externalIP ? : @"0.0.0.0";
}

+ (void)acquireExternalIP {
    NSURL *url = [NSURL URLWithString:@"http://ip-api.com/line/?fields=query"];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               NSString *wes = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               _externalIP = [wes stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                           }];
}

@end
