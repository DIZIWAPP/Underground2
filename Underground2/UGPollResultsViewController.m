//
//  UGPollResultsViewController.m
//  Underground2
//
//  Created by Jon Como on 7/3/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGPollResultsViewController.h"

#import <MapKit/MapKit.h>

#import "UGVideosView.h"

#import "MWFeedItem.h"

#import "TTTTimeIntervalFormatter.h"

#import "UGRecordViewController.h"
#import "UGVideo.h"

#import "UGMapView.h"

@interface UGPollResultsViewController ()
{
    UGMapView *mapResults;
    UGVideosView *videos;
    __weak IBOutlet UILabel *labelTitle;
    __weak IBOutlet UILabel *labelTime;
}

@end

@implementation UGPollResultsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    labelTitle.text = self.item.title;
    labelTime.text =  [[TTTTimeIntervalFormatter shared] stringForTimeIntervalFromDate:[NSDate date] toDate:self.item.date];
    
    mapResults = [[UGMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    [self.view addSubview:mapResults];
    
    videos = [[UGVideosView alloc] initWithFrame:CGRectMake(0, mapResults.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - mapResults.frame.size.height)];
    
    __weak UGPollResultsViewController *weakSelf = self;
    videos.query = ^PFQuery *{
        PFRelation *discussions = [weakSelf.item.petitionObject relationforKey:@"discussions"];
        
        PFQuery *query = [discussions query];
        [query includeKey:@"user"];
        [query orderByAscending:@"createdAt"];
        
        return query;
    };
    [self.view addSubview:videos];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"record"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(respond)];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [videos refreshCompletion:^(NSArray *videos) {
        [mapResults showAnnotationsForVideos:videos];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)respond {
    __weak UGPollResultsViewController *weakSelf = self;
    
    [UGRecordViewController recordVideoCompletion:^(UGVideo *video) {
        PFRelation *discussions = [weakSelf.item.petitionObject relationforKey:@"discussions"];
        [discussions addObject:video.object];
        [weakSelf.item.petitionObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
        }];
    }];
}

@end