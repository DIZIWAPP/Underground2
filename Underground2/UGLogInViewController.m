//
//  UGLogInViewController.m
//  UndergroundNetwork
//
//  Created by Jon Como on 5/22/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "UGLogInViewController.h"
#import "UGGraphics.h"
#import <QuartzCore/QuartzCore.h>

@interface UGLogInViewController ()

@end

@implementation UGLogInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.logInView setBackgroundColor:[UIColor whiteColor]];
    [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logoSlim"]]];
    
    [self.logInView.usernameField setBackgroundColor:[UIColor whiteColor]];
    [self.logInView.passwordField setBackgroundColor:[UIColor whiteColor]];
    
    [self.logInView.usernameField setTextColor:[UIColor redColor]];
    [self.logInView.passwordField setTextColor:[UIColor redColor]];
    
    [self.logInView.usernameField setValue:[UIColor blackColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.logInView.passwordField setValue:[UIColor blackColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    [UGGraphics buttonDone:self.logInView.signUpButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end