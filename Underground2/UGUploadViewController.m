//
//  UGUploadViewController.m
//  Underground
//
//  Created by Jon Como on 5/8/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <Parse/Parse.h>
#import "UGUploadViewController.h"
#import "JCActionSheetManager.h"
#import "UGTermsManager.h"
#import "UGBlacklistManager.h"
#import "UGTermsViewController.h"
#import "UGTermsManager.h"
#import "UGMacros.h"
#import "UGGraphics.h"
#import "JCAlertViewManager.h"
#import "UGCaptionViewController.h"
#import "MBProgressHUD+SimpleHUD.h"
#import "UGLogInViewController.h"
#import "UGSignUpViewController.h"
#import "UGFile.h"

@interface UGUploadViewController () <UGTermsViewControllerDelegate, PFSignUpViewControllerDelegate, PFLogInViewControllerDelegate>
{
    __weak IBOutlet UILabel *termsLabel;
    __weak IBOutlet UIButton *pickFileButton;
    __weak IBOutlet UIBarButtonItem *accountButton;
}

@end

@implementation UGUploadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [termsLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTermsDontChoose)]];
    
    [UGGraphics buttonDone:pickFileButton];
    [UGGraphics barButtonDone:accountButton];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [accountButton setTarget:self];
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]] || ![PFUser currentUser]) {
        [accountButton setAction:@selector(registerOrLogIn)];
    }else{
        [accountButton setAction:@selector(viewAccount)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewTermsDontChoose
{
    [self viewTermsAndChoose:NO];
}

-(void)viewTermsAndChoose:(BOOL)choose
{
    UGTermsViewController *terms = [self.storyboard instantiateViewControllerWithIdentifier:@"termsVC"];
    terms.delegate = self;
    terms.shouldChooseImageOnComplete = choose;
    [self presentViewController:terms animated:YES completion:nil];
}

-(void)userCanUploadCompletion:(void(^)(BOOL canUpload))block
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:UGTermsAgreed]){
        
        [self viewTermsAndChoose:YES];
        
        if (block) block(NO);
        return;
    }
    
    [[UGTermsManager sharedManager] termsUpdated:^(BOOL success, BOOL termsUpdated) {
        
        if (!success){
            if (block) block(NO);
            return;
        }
        
        if (termsUpdated)
        {
            [[JCAlertViewManager sharedManager] alertViewWithTitle:@"Attention" message:@"We've modified our terms of service, please agree to the updated terms of service before uploading." cancelButton:@"Cancel" buttons:@[@"View Terms"] completion:^(NSInteger buttonIndex) {
                if (buttonIndex == 1){
                    [self viewTermsAndChoose:NO];
                }
            }];
            
            return;
        }
        
        [[UGBlacklistManager sharedManager] isBlacklisted:^(BOOL success, BOOL blacklisted) {
            if (!success || blacklisted){
                if (block) block(NO);
                return;
            }
            
            if (block) block(YES);
        }];
    }];
}

-(void)termsViewController:(UGTermsViewController *)viewController dismissedWithAction:(kTermsAction)action
{
    if (action == kTermsActionAgreed)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:UGTermsAgreed];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:UGTermsDateAgreed];
    }
    
    if (action == kTermsActionDisagreed){
        [MBProgressHUD showMessageWithText:@"Terms Agreement" detailText:@"You must agree to our terms of service before uploading." length:4 inView:self.view];
    }
}

-(void)registerOrLogIn
{
    // Create the log in view controller
    UGLogInViewController *logInViewController = [[UGLogInViewController alloc] init];
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
    
    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if ([[object valueForKey:@"isAdmin"] boolValue])
        {
            [[PFInstallation currentInstallation] setChannels:@[@"fileUpload"]];
            [[PFInstallation currentInstallation] saveInBackground];
        }
    }];
}

-(void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    UIViewController *presenting = signUpController.presentingViewController;
    
    [signUpController dismissViewControllerAnimated:YES completion:^{
        [presenting dismissViewControllerAnimated:YES completion:nil];
    }];
}

@end
