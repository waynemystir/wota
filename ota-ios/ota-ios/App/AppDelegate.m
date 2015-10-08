//
//  AppDelegate.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/24/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "AppDelegate.h"
#import "AppEnvironment.h"
#import "TrotterViewController.h"
#import "SelectRoomViewController.h"
#import "IpAddress.h"
#import "Analytics.h"

static NSString *_externalIP = nil;
static BOOL _ipSearchCompleted = NO;

@interface AppDelegate ()

@property (nonatomic) Class spinnerClass;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[self class] acquireExternalIP];
    
    TrotterViewController *mvc = [TrotterViewController new];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:mvc];
    CGRect sf = [[UIScreen mainScreen] bounds];
    self.window = [[UIWindow alloc] initWithFrame:sf];
    self.window.rootViewController = nc;
    self.window.backgroundColor = [UIColor whiteColor];
//    if (sf.size.height == 480) {
//        self.window.frame = CGRectMake(0, 0, 270.4224f, 480);
//        self.window.transform = CGAffineTransformMakeTranslation(25.0f, 0.0f);
//        self.window.clipsToBounds = YES;
//    }
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSMutableArray *controllers = [((UINavigationController *)self.window.rootViewController).viewControllers mutableCopy];
    int indexOfSRVC = -1;
    for (int j = 0; j < controllers.count; j++)
        if ([controllers[j] isKindOfClass:[SelectRoomViewController class]]) {
            indexOfSRVC = j;
            break;
        }
    
    if (indexOfSRVC > -1) [controllers removeObjectAtIndex:indexOfSRVC];
    
    ((UINavigationController *)self.window.rootViewController).viewControllers = [NSArray arrayWithArray:controllers];
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
    CGRect r = CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 64);
    [self loadDaSpinnerWithFrame:r];
}

- (void)loadDaSpinnerWithFrame:(CGRect)frame {
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
    
    UIView *dWayne = [[UIView alloc] initWithFrame:frame];
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
    if (!_externalIP && !_ipSearchCompleted) {
        [self acquireExternalIP];
    }
    
    return _externalIP ? : @"173.61.103.98";
}

+ (void)acquireExternalIP {
    static BOOL _currentlySearchingForExternalIP = NO;
    if (_currentlySearchingForExternalIP) return;
    _currentlySearchingForExternalIP = YES;
    
//    NSString *us = @"http://ip-api.com/line/?fields=query";
//    NSString *us = @"https://unique-hash-89300.appspot.com/ipservlet";
    
    NSString *us1 = @"https://api.ipify.org";
    
    NSURLSessionConfiguration *urlconfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    urlconfig.timeoutIntervalForRequest = 35;
    urlconfig.timeoutIntervalForResource = 35;
    
    NSURLSession *sess1 = [NSURLSession sessionWithConfiguration:urlconfig];
    
    [[sess1 dataTaskWithURL:[NSURL URLWithString:us1] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSString *ip1 = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (isValidIPv4_alt1(ip1) || isValidIPv4_alt2(ip1) || isValidIPv4_alt3(ip1)) {
            
            _externalIP = ip1;
            _ipSearchCompleted = YES;
            _currentlySearchingForExternalIP = NO;
            
        } else {
            
            NSString *us2 = @"http://v4.ipv6-test.com/api/myip.php";
            NSURLSession *sess2 = [NSURLSession sessionWithConfiguration:urlconfig];
            [[sess2 dataTaskWithURL:[NSURL URLWithString:us2] completionHandler:^(NSData * _Nullable data2, NSURLResponse * _Nullable response2, NSError * _Nullable error2) {
                
                NSString *ip2 = [[[NSString alloc] initWithData:data2 encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                if (isValidIPv4_alt1(ip2) || isValidIPv4_alt2(ip2) || isValidIPv4_alt3(ip2)) {
                    
                    _externalIP = ip2;
                    _ipSearchCompleted = YES;
                    _currentlySearchingForExternalIP = NO;
                    
                } else {
                    
                    NSString *us3 = @"http://ipv4bot.whatismyipaddress.com/";
                    NSURLSession *sess3 = [NSURLSession sessionWithConfiguration:urlconfig];
                    [[sess3 dataTaskWithURL:[NSURL URLWithString:us3] completionHandler:^(NSData * _Nullable data3, NSURLResponse * _Nullable response3, NSError * _Nullable error3) {
                        
                        NSString *ip3 = [[[NSString alloc] initWithData:data3 encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        
                        if (isValidIPv4_alt1(ip3) || isValidIPv4_alt2(ip3) || isValidIPv4_alt3(ip3)) {
                            
                            _externalIP = ip3;
                            
                        } else {
                            
                            NSString *vm3 = [NSString stringWithFormat:@"URL:%@ ip:%@", us3, ip3 ? : @""];
                            [Analytics postTrotterProblemWithCategory:@"TROTTER_IP_3" shortMessage:@"IP address 3 lookup failed" verboseMessage:vm3];
                        }
                        
                        _ipSearchCompleted = YES;
                        _currentlySearchingForExternalIP = NO;
                        
                    }] resume];
                    
                    NSString *vm2 = [NSString stringWithFormat:@"URL:%@ ip:%@", us2, ip2 ? : @""];
                    [Analytics postTrotterProblemWithCategory:@"TROTTER_IP_2" shortMessage:@"IP address 2 lookup failed" verboseMessage:vm2];
                    
                }
            }] resume];
            
            NSString *vm1 = [NSString stringWithFormat:@"URL:%@ ip:%@", us1, ip1 ? : @""];
            [Analytics postTrotterProblemWithCategory:@"TROTTER_IP_1" shortMessage:@"IP address 1 lookup failed" verboseMessage:vm1];
            
        }
    }] resume];
}

@end
