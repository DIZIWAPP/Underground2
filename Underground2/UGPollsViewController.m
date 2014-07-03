//
//  UGPollsViewController.m
//  Underground2
//
//  Created by Jon Como on 6/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGPollsViewController.h"

#import "UGTabBarController.h"
#import "UGPollCell.h"

#import "UGRSSManager.h"

@interface UGPollsViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@end

@implementation UGPollsViewController
{
    UICollectionView *pollsCollection;
    UIRefreshControl *refresh;
    
    NSArray *data;
}

+(UGPollsViewController *)showPolls
{
    UGPollsViewController *pollsVC = [UGPollsViewController new];
    [[UGTabBarController tabBarController] pushViewController:pollsVC];
    
    return pollsVC;
}

-(id)init
{
    if (self = [super init]) {
        //init
        
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:[UIImage imageNamed:@"vote"] selectedImage:[UIImage imageNamed:@"vote"]];
        
        self.title = @"Votes";
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        
        layout.itemSize = CGSizeMake(320, 414);
        
        pollsCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 46*2) collectionViewLayout:layout];
        [self.view addSubview:pollsCollection];
        
        pollsCollection.dataSource = self;
        pollsCollection.delegate = self;
        
        pollsCollection.alwaysBounceHorizontal = NO;
        pollsCollection.alwaysBounceVertical = YES;
        
        pollsCollection.backgroundColor = [UIColor whiteColor];
        
        [pollsCollection registerNib:[UINib nibWithNibName:@"pollCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"pollCell"];
        
        refresh = [UIRefreshControl new];
        refresh.tintColor = [UIColor blackColor];
        [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        [pollsCollection addSubview:refresh];
    }
    
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self refresh];
}

-(void)refresh
{
    [[UGRSSManager sharedManager] parseURLs:@[[NSURL URLWithString:@"http://feeds.feedburner.com/undergroundnetwork"]] completion:^(NSArray *items) {
        dispatch_async(dispatch_get_main_queue(), ^{
            data = [items copy];
            [refresh endRefreshing];
            [pollsCollection reloadData];
        });
    }];
    
    /*
    PFQuery *polls = [PFQuery queryWithClassName:@"Petition"];
    
    [polls orderByDescending:@"createdAt"];
    
    [polls findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            return;
        }
        
        if (!data) data = [NSMutableArray array];
        data = [objects mutableCopy];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [pollsCollection reloadData];
        });
    }]; */
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MWFeedItem *item = data[indexPath.row];
    
    UGPollCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"pollCell" forIndexPath:indexPath];
    //cell.object = poll;
    cell.item = item;
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return data.count;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MWFeedItem *item = data[indexPath.row];
    return item.cellSize;
}

@end
