//
//  FWTAppDelegate.m
//  FWTSwipeCell-Example
//
//  Created by Carlos Vidal Pallín on 04/11/2013.
//  Copyright (c) 2013 Future Workshops Ltd. All rights reserved.
//

#import "FWTAppDelegate.h"
#import "FWTExampleTableViewController.h"

@interface FWTAppDelegate()

@property (nonatomic, strong) UINavigationController *rootNavigationController;

@end

@implementation FWTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self _configureBarButtonItemsAppearance];
    
    FWTExampleTableViewController *exampleTableViewController = [[FWTExampleTableViewController alloc] init];
    self.rootNavigationController = [[UINavigationController alloc] initWithRootViewController:exampleTableViewController];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window setRootViewController:self.rootNavigationController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)_configureBarButtonItemsAppearance
{
    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:183.f/255 green:16.f/255 blue:21.f/155 alpha:1.f]];
}

@end
