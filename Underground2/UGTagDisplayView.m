//
//  UGTagDisplayView.m
//  Sportsbuddyz
//
//  Created by Jon Como on 2/20/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGTagDisplayView.h"

#import "UGVideo.h"
#import <Parse/Parse.h>

#import "UGFilterViewController.h"

@interface UGTagDisplayView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *videoTags;
}

@end

@implementation UGTagDisplayView
{
    UICollectionView *collectionViewTags;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)setVideo:(UGVideo *)video
{
    _video = video;
    
    [videoTags removeAllObjects];
    [collectionViewTags reloadData];
    self.alpha = 0;
    
    //find tags and setup collection view
    
    if (!collectionViewTags)
    {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        collectionViewTags = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) collectionViewLayout:layout];
        [self addSubview:collectionViewTags];
        collectionViewTags.backgroundColor = [UIColor clearColor];
        collectionViewTags.alwaysBounceHorizontal = YES;
        collectionViewTags.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        
        [collectionViewTags registerNib:[UINib nibWithNibName:@"tagCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"tagCell"];
        
        collectionViewTags.delegate = self;
        collectionViewTags.dataSource = self;
    }
    
    [video getTags:^(NSMutableArray *tags) {
        self.alpha = 1;
        videoTags = [tags mutableCopy];
        [collectionViewTags reloadData];
    }];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionViewTags dequeueReusableCellWithReuseIdentifier:@"tagCell" forIndexPath:indexPath];
    
    PFObject *tag = videoTags[indexPath.row];
    UILabel *tagLabel = (UILabel *)[cell viewWithTag:100];
    tagLabel.text = tag[@"name"];
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return videoTags.count;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *tag = videoTags[indexPath.row];
    NSString *name = tag[@"name"];
    
    CGSize size = [name sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica Neue" size:12]}];
    
    return CGSizeMake(MAX(40, size.width+20), 24);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *tag = videoTags[indexPath.row];
    
    UGFilterViewController *filterVC = [UGFilterViewController findItemsWithQueryBlock:^PFQuery *{
        PFQuery *tagQuery = [PFQuery queryWithClassName:@"File"];
        [tagQuery includeKey:@"user"];
        return tagQuery;
    } searchText:tag[@"name"]];
    
    filterVC.title = tag[@"name"];
}

@end