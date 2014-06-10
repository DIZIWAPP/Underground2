//
//  UGTabBarController.m
//  Sportsbuddyz
//
//  Created by Jon Como on 3/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGTabBarController.h"

#import "UGAccountViewController.h"
#import "UGHomeViewController.h"

#import "UGLogInViewController.h"
#import "UGSignUpViewController.h"
#import "UGRecordViewController.h"
#import "UGFilterViewController.h"

#import "UGAppDelegate.h"

#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>

@interface UGTabBarController () <UITabBarControllerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UIAlertViewDelegate>
{
    UIAlertView *usernameAlert;
}

@end

@implementation UGTabBarController

+(UGTabBarController *)tabBarController
{
    UGAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    UGTabBarController *tabBarController = (UGTabBarController *)delegate.window.rootViewController;
    
    return tabBarController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.orientationMask = UIInterfaceOrientationMaskPortrait;
    self.tabBar.tintColor = [UIColor redColor];
    
    self.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![PFUser currentUser])
        [self showLoginSignUp];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSUInteger)supportedInterfaceOrientations
{
    return self.orientationMask;
}

-(void)pushViewController:(UIViewController *)viewController
{
    UGTabBarController *tabBar = [UGTabBarController tabBarController];
    
    //Make sure its a nav
    UINavigationController *nav = (UINavigationController *)tabBar.selectedViewController;
    
    if ([nav isKindOfClass:[UINavigationController class]]){
        [nav pushViewController:viewController animated:YES];
    }
}

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (![PFUser currentUser])
        [self showLoginSignUp];
}

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    UIViewController *target = viewController.childViewControllers[0];
    if ([target isKindOfClass:[UGAccountViewController class]])
    {
        if (![PFUser currentUser] || [PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
            //Show login or sign up vc
            [self showLoginSignUp];
            return NO;
        }else{
            UINavigationController *userNav = (UINavigationController *)viewController;
            UGAccountViewController *accountVC = (UGAccountViewController *)userNav.viewControllers[0];
            
            accountVC.user = [PFUser currentUser];
            accountVC.isMainAccount = YES;
            
            return YES;
        }
    }else if([target isKindOfClass:[UGHomeViewController class]])
    {
        
    }else if ([target isKindOfClass:[UGRecordViewController class]])
    {
        __weak UGTabBarController *weakSelf = self;
        [UGRecordViewController recordVideoCompletion:^(UGVideo *video) {
            [weakSelf setSelectedIndex:0];
        }];
        
        return NO;
    }else if ([target isKindOfClass:[UGFilterViewController class]])
    {
        UGFilterViewController *filterVC = (UGFilterViewController *)target;
        filterVC.queryBlock = ^{
            PFQuery *query = [PFQuery queryWithClassName:@"File"];
            
            [query includeKey:@"user"];
            [query orderByDescending:@"createdAt"];
            [query setLimit:30];
            
            return query;
        };
        
        filterVC.mode = UGModeTypeFollow;
        
        filterVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Videos" style:UIBarButtonItemStylePlain target:filterVC action:@selector(toggleVideosUsers)];
    }
    
    return YES;
}

-(void)showLoginSignUp
{
    // Create the log in view controller
    UGLogInViewController *logInViewController = [[UGLogInViewController alloc] init];
    [logInViewController setFacebookPermissions:@[@"friends_about_me"]];
    [logInViewController setFields:PFLogInFieldsUsernameAndPassword /*| PFLogInFieldsFacebook | PFLogInFieldsTwitter */ | PFLogInFieldsDismissButton | PFLogInFieldsSignUpButton];
    [logInViewController setDelegate:self]; // Set ourselves as the delegate
    
    // Create the sign up view controller
    UGSignUpViewController *signUpViewController = [[UGSignUpViewController alloc] init];
    [signUpViewController setDelegate:self]; // Set ourselves as the delegate
    
    // Assign our sign up controller to be displayed from the login controller
    [logInViewController setSignUpController:signUpViewController];
    
    // Present the log in view controller
    [self presentViewController:logInViewController animated:YES completion:nil];
}

-(void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    [logInController dismissViewControllerAnimated:YES completion:nil];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == usernameAlert)
    {
        [PFUser currentUser].username = [alertView textFieldAtIndex:0].text;
        [[PFUser currentUser] saveInBackground];
    }
}

-(void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    __weak UIViewController *presenting = signUpController.presentingViewController;
    
    [signUpController dismissViewControllerAnimated:YES completion:^{
        [presenting dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [PFCloud callFunctionInBackground:@"autoSub" withParameters:@{} block:^(id object, NSError *error) {
        
    }];
    
    usernameAlert = [[UIAlertView alloc] initWithTitle:@"Enter a username" message:nil delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
    usernameAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [usernameAlert show];
    
    [[UGTabBarController tabBarController] setSelectedIndex:2];
}

-(void)autoFollowPeople
{
    
}

@end