//
//  JCAlertViewManager.m
//  UndergroundNetwork
//
//  Created by Jon Como on 5/16/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "JCAlertViewManager.h"

@interface JCAlertViewManager () <UIAlertViewDelegate>
{
    AlertCompletion alertCompletion;
}

@end

@implementation JCAlertViewManager

+(JCAlertViewManager *)sharedManager
{
    static JCAlertViewManager *sharedManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

-(void)alertViewWithTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)cancel buttons:(NSArray *)buttons completion:(AlertCompletion)block
{
    alertCompletion = block;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancel otherButtonTitles:nil];
    
    for (NSString *buttonText in buttons)
    {
        [alert addButtonWithTitle:buttonText];
    }
    
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertCompletion) alertCompletion(buttonIndex);
}

@end
