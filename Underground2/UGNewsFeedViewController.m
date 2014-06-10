//
//  UGNewsFeedViewController.m
//  Sportsbuddyz
//
//  Created by Jon Como on 4/11/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGNewsFeedViewController.h"

#import "UGRSSManager.h"
#import "MWFeedItem.h"

#import "UGNewsReaderViewController.h"

#import "UGRSSManagerViewController.h"

#import "UGArticleCell.h"

@interface UGNewsFeedViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@end

@implementation UGNewsFeedViewController
{
    NSMutableArray *feed;
    
    UIRefreshControl *refresh;
    
    UICollectionView *collectionViewNews;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"News";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Manage" style:UIBarButtonItemStylePlain target:[UGRSSManagerViewController class] action:@selector(presentRSSManagerViewController)];
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    
    collectionViewNews = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 46 - 46) collectionViewLayout:layout];
    
    [collectionViewNews registerNib:[UINib nibWithNibName:@"articleCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"articleCell"];
    
    collectionViewNews.delegate = self;
    collectionViewNews.dataSource = self;
    
    collectionViewNews.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:collectionViewNews];
    
    refresh = [UIRefreshControl new];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [collectionViewNews addSubview:refresh];
    
    [self refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refresh
{
    [refresh beginRefreshing];
    
    if (!feed) feed = [NSMutableArray array];
    [feed removeAllObjects];
    
    //Find RSS Feed items
    [[UGRSSManager sharedManager] findRSSItemsProgress:^(float progress) {
        
    } completion:^(NSArray *items) {
        
        [feed addObjectsFromArray:items];
        
        feed = [[feed sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSDate *dateA = ((MWFeedItem *)obj1).date;
            NSDate *dateB = ((MWFeedItem *)obj2).date;
            
            return [dateB compare:dateA];
        }] mutableCopy];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [collectionViewNews reloadData];
            [refresh endRefreshing];
        });
    }];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UGArticleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"articleCell" forIndexPath:indexPath];
    
    MWFeedItem *item = feed[indexPath.row];
    cell.item = item;
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return feed.count;
}

-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    MWFeedItem *item = feed[indexPath.row];
    
    [UGNewsReaderViewController presentNewsReaderViewControllerWithURL:[NSURL URLWithString:item.link]];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MWFeedItem *item = feed[indexPath.row];
    
    if (item.summary.length > 0)
    {
        return CGSizeMake(320, 160);
    }else{
        return CGSizeMake(320, 50);
    }
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
