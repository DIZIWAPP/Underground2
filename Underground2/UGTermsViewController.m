//
//  UGTermsViewController.m
//  Underground
//
//  Created by Jon Como on 5/8/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "UGTermsViewController.h"
#import "JCConnection.h"
#import "UGGraphics.h"
#import "UGTermsManager.h"
#import "UGMacros.h"

@interface UGTermsViewController () <UIWebViewDelegate>
{
    __weak IBOutlet UIWebView *termsWebView;
    __weak IBOutlet UIActivityIndicatorView *activityIndicator;
    __weak IBOutlet UIBarButtonItem *agreeButton;
    NSData *termsData;
}

@end

@implementation UGTermsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    agreeButton.enabled = NO;
    termsWebView.scalesPageToFit = YES;
    
    [UGGraphics barButtonDone:agreeButton];
    
    JCConnection *connection;
    connection = [[JCConnection alloc] initWithhRequest:[[UGTermsManager sharedManager] termsRequest] completion:^(BOOL success, NSData *data) {
        [activityIndicator stopAnimating];
        
        termsData = data;
        [termsWebView loadData:data MIMEType:nil textEncodingName:@"utf-8" baseURL:nil];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(termsViewController:dismissedWithAction:)])
        [self.delegate termsViewController:self dismissedWithAction:kTermsActionDisagreed];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)agree:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(termsViewController:dismissedWithAction:)])
        [self.delegate termsViewController:self dismissedWithAction:kTermsActionAgreed];
    
    NSString *dateAgreed = [UGTermsManager dateStringFromTermsData:termsData];
    
    [[NSUserDefaults standardUserDefaults] setObject:[[NSString alloc] initWithData:termsData encoding:NSUTF8StringEncoding] forKey:UGTermsData];
    [[NSUserDefaults standardUserDefaults] setObject:dateAgreed forKey:UGTermsDateAgreed];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    agreeButton.enabled = YES;
}

@end
