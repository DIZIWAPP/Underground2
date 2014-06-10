//
//  JCParseManager.m
//  Underground
//
//  Created by Jon Como on 5/9/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "JCParseManager.h"
#import "UGUploadViewController.h"
#import "JCAlertViewManager.h"
#import "UGMacros.h"
#import "UGAppDelegate.h"
#import "UGLiveViewController.h"
#import "UGHomeViewController.h"

@interface JCParseManager ()
{
    
}

@end

@implementation JCParseManager

+(JCParseManager *)sharedManager
{
    static JCParseManager *sharedManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

-(id)init
{
    if (self = [super init]) {
        //init
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateStyle:NSDateFormatterFullStyle];
    }
    
    return self;
}

-(void)registerAnonymousUserCompletion:(CompletionBlock)block
{
    if ([PFUser currentUser]){
        if (block) block(YES);
        return;
    }
    
    [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (error){
            if (block) block(NO);
            return;
        }
        
        if (block) block(YES);
    }];
}

/*
-(void)handlePush:(NSDictionary *)push
{
    if (!push) return;
    
    NSString *action = push[UGPushAction];
    
    if ([action isEqualToString:UGPushActionCopyURL] || [action isEqualToString:UGPushActionWatch])
    {
        [[JCAlertViewManager sharedManager] alertViewWithTitle:@"Underground Network" message:push[@"aps"][@"alert"] cancelButton:@"Cancel" buttons:@[@"Watch"] completion:^(NSInteger buttonIndex) {
            if (buttonIndex == 1)
            {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
                
                UGLiveViewController *liveVC = [storyboard instantiateViewControllerWithIdentifier:@"liveVC"];
                
                liveVC.url = [NSURL URLWithString:push[UGPushURL]];
                
                [[self topMostController] presentViewController:liveVC animated:YES completion:nil];
            }
        }];
    }
    else if ([push[UGPushAction] isEqualToString:UGPushActionUpload])
    {
        [[JCAlertViewManager sharedManager] alertViewWithTitle:@"Underground Network" message:push[@"aps"][@"alert"] cancelButton:@"Cancel" buttons:@[@"Record"] completion:^(NSInteger buttonIndex) {
            if (buttonIndex == 1)
            {
                [self dismissAllToHome];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:UGNotificationRecord object:nil];
            }
        }];
    }
    else
    {
        [[JCAlertViewManager sharedManager] alertViewWithTitle:@"Underground Network" message:push[@"aps"][@"alert"] cancelButton:@"Ok" buttons:nil completion:nil];
    }
} */

-(UIViewController*)topMostController
{
    UGAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    UIViewController *topController = delegate.window.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

-(void)dismissAllToHome
{
    UGAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    if (![delegate.window.rootViewController isKindOfClass:[UGHomeViewController class]]){
        [delegate.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
    }
}

-(void)setDeviceOwnerWithToken:(NSData *)token
{
    PFInstallation *installation = [PFInstallation currentInstallation];
    
    [installation setDeviceTokenFromData:token];
    
    if ([PFUser currentUser]){
        [installation setObject:[PFUser currentUser] forKey:@"user"];
    }
    
    [installation saveInBackground];
}

-(NSString *)nameForObject:(PFObject *)object
{
    NSString *title;
    
    NSString *username = @"Anonymous";
    
    NSString *fileUsername = object[@"user"][@"username"];
    
    if (fileUsername && ![self userIsAnonymous:object[@"user"]])
        username = fileUsername;
    
    title = username;
    
    return title;
}

-(BOOL)userIsAnonymous:(PFUser *)user
{
    if (!user) return YES;
    return (user.username.length >= 24);
}

@end