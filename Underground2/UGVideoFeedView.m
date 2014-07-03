//
//  UGVideoFeedView.m
//  Sportsbuddyz
//
//  Created by Jon Como on 4/24/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGVideoFeedView.h"

#import "UGCurrentUser.h"

#import "UGVideoCell.h"

#import "UGVideo.h"

#import <Parse/Parse.h>

#import "UGExploreViewController.h"

@interface UGVideoFeedView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *feed;
}

@end

@implementation UGVideoFeedView
{
    UIRefreshControl *refresh;
    
    CGRect startRect;
    
    UIButton * manageFeedButton;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        
        layout.minimumLineSpacing = 20;
        
        self.collectionViewFiles = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout:layout];
        [self addSubview:self.collectionViewFiles];
        
        self.collectionViewFiles.backgroundColor = [UIColor whiteColor];
        self.collectionViewFiles.contentInset = UIEdgeInsetsMake(20, 0, 20, 0);
        self.collectionViewFiles.alwaysBounceVertical = YES;
        
        self.collectionViewFiles.dataSource = self;
        self.collectionViewFiles.delegate = self;
        
        [self.collectionViewFiles registerNib:[UINib nibWithNibName:@"videoCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"videoCell"];
        
        self.collectionViewFiles.backgroundColor = [UIColor clearColor];
        
        refresh = [[UIRefreshControl alloc] init];
        refresh.tintColor = [UIColor whiteColor];
        [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        
        
        [self.collectionViewFiles addSubview:refresh];
    }
    
    return self;
}

-(void)removeRefresh
{
    [refresh removeFromSuperview];
}

-(void)refresh
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.collectionViewFiles.userInteractionEnabled = NO;
        [[UGCurrentUser user] refreshCompletion:^{
            feed = [[UGCurrentUser user].feed mutableCopy];
            [self updateUI];
        }];
    });
}

-(void)refreshWithQuery:(PFQuery *(^)(void))block
{
    PFQuery *query = block();
    
    if (!feed) feed = [NSMutableArray array];
    [feed removeAllObjects];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            [self updateUI];
            return;
        }
        
        for (PFObject *object in objects){
            UGVideo *video = [[UGVideo alloc] initWithObject:object];
            [feed addObject:video];
        }
        
        [self updateUI];
    }];
}

-(void)updateUI
{
    self.collectionViewFiles.userInteractionEnabled = YES;
    [refresh endRefreshing];
    [self.collectionViewFiles reloadData];
    
    if (feed.count == 0)
    {
        if (!manageFeedButton)
        {
            manageFeedButton = [UIButton buttonWithType:UIButtonTypeSystem];
            manageFeedButton.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            [manageFeedButton setTitle:self.message ? self.message : @"Tap to Follow Users" forState:UIControlStateNormal];
            [manageFeedButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [manageFeedButton.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Heavy" size:18]];
            manageFeedButton.titleLabel.numberOfLines = 2;
            [manageFeedButton addTarget:self action:@selector(followUsers) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [self addSubview:manageFeedButton];
    }else{
        [manageFeedButton removeFromSuperview];
        manageFeedButton = nil;
    }
}

-(void)followUsers
{
    [UGExploreViewController presentExplore];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id data = feed[indexPath.row];
    
    if ([data isKindOfClass:[UGVideo class]])
    {
        UGVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"videoCell" forIndexPath:indexPath];
        
        UGVideo *video = feed[indexPath.row];
        cell.video = video;
        
        return cell;
    }
    
    return nil;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return feed.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id data = feed[indexPath.row];
    
    if ([data isKindOfClass:[UGVideo class]])
    {
        UGVideo *video = feed[indexPath.row];
        
        [video playInVideoViewController];
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id data = feed[indexPath.row];
    
    if ([data isKindOfClass:[UGVideo class]])
    {
        UGVideo *video = feed[indexPath.row];
        
        return [video sizeForCollection];
    }
    
    return CGSizeMake(300, 100);
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
