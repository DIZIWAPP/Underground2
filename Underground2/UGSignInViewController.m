//
//  UGSignInViewController.m
//  UndergroundNetwork
//
//  Created by Jon Como on 5/16/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "UGSignInViewController.h"
#import "JCAlertViewManager.h"
#import "UGGraphics.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>

@interface UGSignInViewController ()
{
    __weak IBOutlet UITextField *textFieldUsername;
    __weak IBOutlet UITextField *textFieldPassword;
    
    __weak IBOutlet UIBarButtonItem *buttonSignIn;
    
    __weak IBOutlet UIView *viewSignInFields;
    
    NSArray *textFields;
}

@end

@implementation UGSignInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)]];
    [self style];
    
    [textFieldUsername becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)viewTapped:(UITapGestureRecognizer *)tap
{
    for (UITextField *textField in textFields){
        [textField resignFirstResponder];
    }
}

-(void)style
{
    [UGGraphics barButtonDone:buttonSignIn];
    
    textFields = @[textFieldPassword, textFieldUsername];
    
    viewSignInFields.layer.cornerRadius = 8;
    
    for (UITextField *textfield in textFields){
        UIView *leftPadding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 5)];
        [leftPadding setUserInteractionEnabled:NO];
        textfield.leftView = leftPadding;
        textfield.leftViewMode = UITextFieldViewModeAlways;
    }
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)signIn:(id)sender {
    buttonSignIn.enabled = NO;
    
    [PFUser logInWithUsernameInBackground:textFieldUsername.text password:textFieldPassword.text block:^(PFUser *user, NSError *error) {
        buttonSignIn.enabled = YES;
        
        if (error){
            if (error.code == 101){
                [[JCAlertViewManager sharedManager] alertViewWithTitle:@"Invalid Credentials" message:@"Please check that your username or password were entered correctly." cancelButton:@"Ok" buttons:nil completion:nil];
            }else{
                [[JCAlertViewManager sharedManager] alertViewWithTitle:@"Couldn't Sign In" message:@"There was an error signing you in, please try again later." cancelButton:@"Ok" buttons:nil completion:nil];
            }
            
            return;
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}


@end
