//
//  UGNewsReaderViewController.m
//  Sportsbuddyz
//
//  Created by Jon Como on 4/7/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGNewsReaderViewController.h"

#import "UGTabBarController.h"

#import "UGVideoViewController.h"

#import "MWFeedItem.h"

@interface UGNewsReaderViewController () <UIWebViewDelegate>
{
    UIWebView *webViewReader;
}

@end

@implementation UGNewsReaderViewController

+(UGNewsReaderViewController *)presentNewsReaderViewControllerWithURL:(NSURL *)url
{
    UGNewsReaderViewController *newsReader = [[UGNewsReaderViewController alloc] init];
    
    newsReader.webURL = url;
    
    [[UGTabBarController tabBarController] pushViewController:newsReader];
    
    return newsReader;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        self.hidesBottomBarWhenPushed = YES;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Loading...";
    
    webViewReader = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height -44)];
    webViewReader.delegate = self;
    [self.view addSubview:webViewReader];
    
    [webViewReader loadRequest:[NSURLRequest requestWithURL:self.webURL]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewReplies
{
    UGVideoViewController *videoVC = [[UGVideoViewController alloc] init];
    
    videoVC.newsURL = [self.webURL absoluteString];
    videoVC.title = self.title;
    
    [[UGTabBarController tabBarController] pushViewController:videoVC];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Replies" style:UIBarButtonItemStylePlain target:self action:@selector(viewReplies)];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
