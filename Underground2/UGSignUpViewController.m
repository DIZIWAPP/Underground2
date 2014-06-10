//
//  UGSignUpViewController.m
//  UndergroundNetwork
//
//  Created by Jon Como on 5/22/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "UGSignUpViewController.h"
#import "UGGraphics.h"

@interface UGSignUpViewController ()

@end

@implementation UGSignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    
    [self.signUpView setBackgroundColor:[UIColor whiteColor]];
    [self.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logoSlim"]]];
    
    [self.signUpView.usernameField setBackgroundColor:[UIColor whiteColor]];
    [self.signUpView.passwordField setBackgroundColor:[UIColor whiteColor]];
    [self.signUpView.emailField setBackgroundColor:[UIColor whiteColor]];
    
    [self.signUpView.usernameField setTextColor:[UIColor redColor]];
    [self.signUpView.passwordField setTextColor:[UIColor redColor]];
    [self.signUpView.emailField setTextColor:[UIColor redColor]];
    
    [self.signUpView.usernameField setValue:[UIColor blackColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.signUpView.passwordField setValue:[UIColor blackColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.signUpView.emailField setValue:[UIColor blackColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    [UGGraphics buttonDone:self.signUpView.signUpButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end