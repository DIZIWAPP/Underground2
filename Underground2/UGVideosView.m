//
//  UGVideosView.m
//  Underground2
//
//  Created by Jon Como on 7/3/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGVideosView.h"

#import "UGVideo.h"

#import "UGExploreViewController.h"

#import "UGVideoCell.h"

@interface UGVideosView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@end

@implementation UGVideosView
{
    UIRefreshControl *refresh;
    CGRect startRect;
    UIButton *manageFeedButton;
    
    NSMutableArray *videos;
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

-(void)refresh
{
    [self refreshCompletion:nil];
}

-(void)refreshCompletion:(void (^)(NSArray *))block
{
    [self.query() findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            return;
        }
        
        if (!videos) videos = [NSMutableArray array];
        [videos removeAllObjects];
        
        for (PFObject *object in objects){
            [videos addObject:[[UGVideo alloc] initWithObject:object]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionViewFiles reloadData];
            [refresh endRefreshing];
            if (block) block(videos);
        });
    }];
}

-(void)followUsers
{
    [UGExploreViewController presentExplore];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UGVideo *video = videos[indexPath.row];
    
    UGVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"videoCell" forIndexPath:indexPath];
    
    cell.video = video;
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return videos.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UGVideo *video = videos[indexPath.row];
    
    [video playInVideoViewController];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UGVideo *video = videos[indexPath.row];
    
    return [video sizeForCollection];
    
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
