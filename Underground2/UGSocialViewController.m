//
//  UGSocialViewController.m
//  Sportsbuddyz
//
//  Created by Jon Como on 2/28/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGSocialViewController.h"
#import "UGTabBarController.h"

#import "UGSocialInteraction.h"
#import "UGInteractionCell.h"

#import "UGExploreViewController.h"

@interface UGSocialViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    __weak IBOutlet UICollectionView *collectionInteractions;
    UIRefreshControl *refresh;
    
    NSArray *interactions;
}

@end

@implementation UGSocialViewController

+(UGSocialViewController *)presentSocialViewController
{
    [[UGTabBarController tabBarController] setSelectedIndex:4];
    
    UINavigationController *nav = (UINavigationController *)[UGTabBarController tabBarController].selectedViewController;
    UGSocialViewController *socialVC = nav.viewControllers[0];
    
    return socialVC;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Explore" style:UIBarButtonItemStylePlain target:self action:@selector(presentExplore)];
    
    [collectionInteractions registerNib:[UINib nibWithNibName:@"interactionCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"interactionCell"];
    
    refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    [collectionInteractions addSubview:refresh];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self refresh];
}

-(void)refresh
{
    [collectionInteractions setUserInteractionEnabled:NO];
    
    [refresh beginRefreshing];
    
    [UGSocialInteraction findInteractionsCompletion:^(NSArray *objects) {
        [collectionInteractions setUserInteractionEnabled:YES];
        
        interactions = [objects mutableCopy];
        
        [refresh endRefreshing];
        [collectionInteractions reloadData];
    }];
}

-(void)presentExplore
{
    UGExploreViewController *exploreVC = [[UGExploreViewController alloc] init];
    
    [[UGTabBarController tabBarController] pushViewController:exploreVC];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UGInteractionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"interactionCell" forIndexPath:indexPath];
    
    PFObject *interaction = interactions[indexPath.row];
    cell.interaction = interaction;
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return interactions.count;
}

@end