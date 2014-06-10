//
//  UGLiveViewController.m
//  Underground
//
//  Created by Jon Como on 5/9/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "UGLiveViewController.h"

#import "UGTabBarController.h"

@interface UGLiveViewController () <UIWebViewDelegate>
{
    __weak IBOutlet UIBarButtonItem *refreshButton;
    __weak IBOutlet UIWebView *liveWebView;
    __weak IBOutlet UIActivityIndicatorView *activityIndicatorForWeb;
}

@end

@implementation UGLiveViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    liveWebView.delegate = self;
    liveWebView.mediaPlaybackAllowsAirPlay = YES;
    
    if (!self.url){
        self.url = [NSURL URLWithString:@"http://www.youtube.com/undergroundnetwork"];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:30];
    [liveWebView loadRequest:request];
    
    [UGTabBarController tabBarController].orientationMask = UIInterfaceOrientationMaskAllButUpsideDown;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [UGTabBarController tabBarController].orientationMask = UIInterfaceOrientationMaskPortrait;
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
}
- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)back:(id)sender
{
    [liveWebView goBack];
}

- (IBAction)forward:(id)sender
{
    [liveWebView goForward];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refresh:(id)sender
{
    [liveWebView reload];
}

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [activityIndicatorForWeb stopAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [activityIndicatorForWeb stopAnimating];
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [activityIndicatorForWeb startAnimating];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

@end
