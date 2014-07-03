//
//  UGExploreViewController.m
//  Sportsbuddyz
//
//  Created by Jon Como on 3/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGExploreViewController.h"

#import "JCSegmentView.h"

#import <Parse/Parse.h>

#import "UGVideo.h"

#import "UGMapView.h"
#import "UGThumbView.h"

#import "UGAccountViewController.h"
#import "UGTabBarController.h"

@interface UGExploreViewController ()
{
    JCSegmentView *segmentView;
}

@end

@implementation UGExploreViewController

+(void)presentExplore
{
    UGExploreViewController *explore = [[UGExploreViewController alloc] init];
    [[UGTabBarController tabBarController] pushViewController:explore];
}

-(id)init
{
    if (self = [super init]) {
        //init
        self.view.backgroundColor = [UIColor whiteColor];
        self.title = @"Explore";
        
        UGMapView *mapView = [[UGMapView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        
        UGThumbView *popularView = [[UGThumbView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        
        popularView.queryBlock = ^{
            PFQuery *query = [PFUser query];
            
            [query includeKey:@"user"];
            [query whereKeyExists:@"profileImage"];
            [query orderByDescending:@"username"];
            
            return query;
        };
        
        UGThumbView *recentView = [[UGThumbView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        
        recentView.queryBlock = ^{
            PFQuery *query = [PFQuery queryWithClassName:@"File"];
            
            [query includeKey:@"user"];
            [query orderByDescending:@"createdAt"];
            [query setLimit:30];
            
            return query;
        };
        
        SelectedData selectedHandler = ^(id data){
            if ([data isKindOfClass:[UGVideo class]])
            {
                UGVideo *video = (UGVideo *)data;
                [video playInVideoViewController];
            }else if ([data isKindOfClass:[PFObject class]])
            {
                PFUser *user = (PFUser *)data;
                [UGAccountViewController presentAccountViewControllerForUser:user];
            }
        };
        
        popularView.selectedData = selectedHandler;
        recentView.selectedData = selectedHandler;
        
        segmentView = [[JCSegmentView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 94) items:@[@"Map", @"Popular", @"Recent"] views:@[mapView, popularView, recentView] padding:10];
        [self.view addSubview:segmentView];
        
        [segmentView setIndexChanged:^(NSUInteger index){
            
            switch (index) {
                case 0:
                    [mapView refresh];
                    break;
                case 1:
                    [popularView refresh];
                    break;
                case 2:
                    [recentView refresh];
                    break;
                    
                default:
                    break;
            }
            
        }];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end