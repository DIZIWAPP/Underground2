//
//  UGArticleFeedView.m
//  Sportsbuddyz
//
//  Created by Jon Como on 4/24/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGArticleFeedView.h"

#import "UGCurrentUser.h"

#import "UGArticleCell.h"

#import "MWFeedItem.h"

#import "UGRSSManager.h"

#import "UGNewsReaderViewController.h"

#import "UGRSSManagerViewController.h"

@interface UGArticleFeedView () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
{
    UIButton *manageFeedButton;
    UIProgressView *progressView;
    
    UILabel *loadLabel;
}

@end

@implementation UGArticleFeedView
{
    UIRefreshControl *refresh;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        
        self.collectionViewFiles = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout:layout];
        [self addSubview:self.collectionViewFiles];
        
        self.collectionViewFiles.dataSource = self;
        self.collectionViewFiles.delegate = self;
        
        self.collectionViewFiles.backgroundColor = [UIColor clearColor];
        
        [self.collectionViewFiles registerNib:[UINib nibWithNibName:@"articleCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"articleCell"];
        
        refresh = [[UIRefreshControl alloc] init];
        refresh.tintColor = [UIColor whiteColor];
        [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        
        [self.collectionViewFiles addSubview:refresh];
    }
    
    return self;
}

-(void)refreshWithItems:(NSArray *)items
{
    if (!self.feed) self.feed = [NSMutableArray array];
    [self.feed removeAllObjects];
    
    [self.feed addObjectsFromArray:items];
    
    [loadLabel removeFromSuperview];
    loadLabel = nil;
    
    if (items.count == 0){
        //show manage news button
        
        if (!manageFeedButton){
            manageFeedButton = [UIButton buttonWithType:UIButtonTypeSystem];
        }
        
        manageFeedButton.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [manageFeedButton setTitle:@"Tap to Add Subscriptions" forState:UIControlStateNormal];
        [manageFeedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [manageFeedButton.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Heavy" size:18]];
        manageFeedButton.titleLabel.numberOfLines = 2;
        [self addSubview:manageFeedButton];
        [manageFeedButton addTarget:self action:@selector(manageFeed) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [manageFeedButton removeFromSuperview];
        manageFeedButton = nil;
    }
    
    self.feed = [[self.feed sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate *dateA = ((MWFeedItem *)obj1).date;
        NSDate *dateB = ((MWFeedItem *)obj2).date;
        
        return [dateB compare:dateA];
    }] mutableCopy];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionViewFiles reloadData];
        [refresh endRefreshing];
    });
}

-(void)refresh
{
    if (![PFUser currentUser]) return;
    
    [self beginRefresh];
    
    [progressView removeFromSuperview];
    progressView = nil;
    
    progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(44, self.frame.size.height/2 + 44, 320 - 88, 44)];
    [self addSubview:progressView];
    
    //Find RSS Feed items
    [[UGRSSManager sharedManager] findRSSItemsProgress:^(float progress) {
        progressView.progress = progress;
        
    } completion:^(NSArray *items) {
        [self refreshWithItems:items];
        [progressView removeFromSuperview];
    }];
}

-(void)beginRefresh
{
    [refresh beginRefreshing];
    
    if (!self.feed) self.feed = [NSMutableArray array];
    [self.feed removeAllObjects];
    
    [self.collectionViewFiles reloadData];
    
    [manageFeedButton removeFromSuperview];
    manageFeedButton = nil;
    
    [loadLabel removeFromSuperview];
    loadLabel = nil;
    
    loadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    loadLabel.textColor = [UIColor whiteColor];
    loadLabel.font =[UIFont fontWithName:@"AvenirNext-Heavy" size:18];
    loadLabel.textAlignment = NSTextAlignmentCenter;
    loadLabel.text = @"Loading News feeds...";
    [self addSubview:loadLabel];
}

-(void)manageFeed
{
    __weak UGArticleFeedView *weakSelf = self;
    [UGRSSManagerViewController presentRSSManagerViewControllerCompletion:^{
        [weakSelf refresh];
    }];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id data = self.feed[indexPath.row];
    
    if([data isKindOfClass:[MWFeedItem class]])
    {
        UGArticleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"articleCell" forIndexPath:indexPath];
        
        MWFeedItem *item = self.feed[indexPath.row];
        cell.item = item;
        
        return cell;
    }
    
    return nil;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.feed.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id data = self.feed[indexPath.row];
    
    if([data isKindOfClass:[MWFeedItem class]])
    {
        MWFeedItem *item = self.feed[indexPath.row];
        
        [UGNewsReaderViewController presentNewsReaderViewControllerWithURL:[NSURL URLWithString:item.link]];
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id data = self.feed[indexPath.row];
    
    if([data isKindOfClass:[MWFeedItem class]])
    {
        
    }
    
    return CGSizeMake(320, 180);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
