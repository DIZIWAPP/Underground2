//
//  UGPush.m
//  Sportsbuddyz
//
//  Created by Jon Como on 2/28/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGPush.h"

#import <Parse/Parse.h>
#import "UGAppDelegate.h"

#import "UGSocialViewController.h"

typedef void (^PushAction)(void);

@interface UGPush () <UIAlertViewDelegate>

@end

@implementation UGPush
{
    PushAction pushAction;
}

+(UGPush *)manager
{
    static UGPush *manager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

-(void)sendPushToUser:(PFUser *)user message:(NSString *)message action:(NSString *)action
{
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" equalTo:user];
    
    PFPush *push = [PFPush push];
    [push setQuery:pushQuery];
    
    [push setData:@{@"alert" : message, @"sound" : @"default", UGPushAction : action}];
    
    [push sendPushInBackground];
}

-(void)handlePush:(NSDictionary *)push
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Underground" message:push[@"aps"][@"alert"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [alert show];
    
    if ([push[@"aps"][UGPushAction] isEqualToString:UGPushActionSocial])
    {
//        pushAction = ^{
//            [UGSocialViewController presentSocialViewController];
//        };
    }else{
        //pushAction = ^{};
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        //Hit Ok
        if (pushAction) pushAction();
        [UGSocialViewController presentSocialViewController];
    }
}

@end
