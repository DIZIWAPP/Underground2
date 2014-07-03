//
//  UGHomeViewController.m
//  Underground
//
//  Created by Jon Como on 5/8/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "UGHomeViewController.h"

#import <Parse/Parse.h>

#import "UGCurrentUser.h"

#import "UGRecordViewController.h"

#import "UGVideoCell.h"
#import "UGVideo.h"

#import "UGRSSManager.h"
#import "UGArticleCell.h"

#import "UGNewsReaderViewController.h"
#import "UGRSSManagerViewController.h"

#import "UGVideoFeedView.h"
#import "UGArticleFeedView.h"

#import "UGLiveViewController.h"

#import "UGTabBarController.h"

#import "UGFilterViewController.h"
#import "UGPollsViewController.h"

#import "JCSegmentView.h"

#define DOCUMENTS [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0]

@interface UGHomeViewController () <UGContainedViewDelegate>
{
    UGArticleFeedView *articleFeedView;
    UGVideoFeedView *videoFeedView;
    
    JCSegmentView *segmentView;
    
    UIView *resultsView;
    UIView *reportView;
}

@end

@implementation UGHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [PFImageView class]; //interface builder problem fix
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    articleFeedView = [[UGArticleFeedView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height/2)];
    [self.view addSubview:articleFeedView];
    articleFeedView.delegate = self;
    
    resultsView = [[UINib nibWithNibName:@"pollResults" bundle:[NSBundle mainBundle]] instantiateWithOwner:self options:nil][0];
    reportView = [[UINib nibWithNibName:@"reportView" bundle:[NSBundle mainBundle]] instantiateWithOwner:self options:nil][0];
    
    segmentView = [[JCSegmentView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 44*2) items:@[@"Vote", @"Report", @"Press"] views:@[resultsView, reportView, articleFeedView] padding:0];
    [self.view addSubview:segmentView];
    
    
    //setup report
    UIWebView *web = (UIWebView *)[reportView viewWithTag:100];
    [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.youtube.com/user/undergroundnetwork"] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:20]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search"] style:UIBarButtonItemStylePlain target:self action:@selector(showSearch)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"  TV " style:UIBarButtonItemStylePlain target:self action:@selector(viewTV)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"underground"]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = imageView;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Clear documents
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:DOCUMENTS error:nil];
    for (NSString *fileName in files){
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", DOCUMENTS, fileName] error:nil];
    }
    
    if ([UGCurrentUser user].feed.count == 0){
        [videoFeedView refresh];
    }
    
    if (articleFeedView.feed.count == 0)
    {
        [articleFeedView refresh];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showMenu
{
    [UGPollsViewController showPolls];
}

-(void)showSearch
{
    UGFilterViewController *filter = [UGFilterViewController findItemsWithQueryBlock:^PFQuery *{
        PFQuery *query = [PFQuery queryWithClassName:@"File"];
        [query orderByDescending:@"createdAt"];
        [query includeKey:@"user"];
        return query;
    } searchText:@""];
    filter.title = @"Search";
}

-(void)viewTV
{
    UGLiveViewController *liveVC = [self.storyboard instantiateViewControllerWithIdentifier:@"liveVC"];
    liveVC.url = [NSURL URLWithString:@"http://www.youtube.com/undergroundnetwork"];
    [self presentViewController:liveVC animated:YES completion:nil];
}

-(void)containedViewInteracted:(UGContainedView *)containedView
{
    float height = self.view.frame.size.height;
    float minHeight = 46;
    
    [UIView animateWithDuration:0.3 animations:^{
        if (containedView == articleFeedView)
        {
            articleFeedView.frame = CGRectMake(0, 0, 320, height - minHeight);
            videoFeedView.frame = CGRectMake(0, articleFeedView.frame.size.height, 320, minHeight);
            
            [videoFeedView showTitle:@"+ Videos"];
        }else{
            articleFeedView.frame = CGRectMake(0, 0, 320, minHeight);
            videoFeedView.frame = CGRectMake(0, articleFeedView.frame.size.height, 320, height - minHeight);
            
            [articleFeedView showTitle:@"+ News"];
        }
        
        [self.view layoutSubviews];
    }];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

-(BOOL)shouldAutorotate
{
    return NO;
}

@end
