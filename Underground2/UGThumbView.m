//
//  UGThumbView.m
//  Sportsbuddyz
//
//  Created by Jon Como on 3/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGThumbView.h"

#import <Parse/Parse.h>

#import "UGVideo.h"
#import "UGThumbCell.h"

@interface UGThumbView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@end

@implementation UGThumbView
{
    UICollectionView *collectionThumbs;
    NSMutableArray *data;
    
    UIRefreshControl *refresh;
    
    NSString *className;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        data = [NSMutableArray array];
        
        _layout = [[UICollectionViewFlowLayout alloc] init];
        
        _layout.itemSize = CGSizeMake(66, 66);
        
        collectionThumbs = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout:_layout];
        
        collectionThumbs.delegate = self;
        collectionThumbs.dataSource = self;
        
        collectionThumbs.backgroundColor = [UIColor clearColor];
        
        collectionThumbs.alwaysBounceVertical = YES;
        
        [collectionThumbs registerNib:[UINib nibWithNibName:@"thumbCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"thumbCell"];
        
        [self addSubview:collectionThumbs];
        
        refresh = [[UIRefreshControl alloc] init];
        [collectionThumbs addSubview:refresh];
        
        [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        
        [self refresh];
    }
    
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    collectionThumbs.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

-(void)refresh
{
    if (!self.queryBlock) return;
    
    [refresh beginRefreshing];
    
    PFQuery *query = self.queryBlock();
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [refresh endRefreshing];
        
        if (error || objects.count == 0) return;
        
        [data removeAllObjects];
        
        PFObject *object = objects[0];
        
        className = object.parseClassName;
        
        if ([className isEqualToString:@"_User"])
        {
            //Found users
            data = [objects mutableCopy];
        }else if ([className isEqualToString:@"File"]) {
            //Found video objects
            for (PFObject *object in objects){
                UGVideo *video = [[UGVideo alloc] initWithObject:object];
                [data addObject:video];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [collectionThumbs reloadData];
        });
    }];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UGThumbCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"thumbCell" forIndexPath:indexPath];
    
    if ([className isEqualToString:@"_User"])
    {
        //Found users
        PFUser *user = data[indexPath.row];
        cell.user = user;
    }else if ([className isEqualToString:@"File"]) {
        //Found video objects
        UGVideo *video = data[indexPath.row];
        cell.video = video;
    }
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return data.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id dataSelected;
    
    if ([className isEqualToString:@"_User"])
    {
        //Found users
        dataSelected = data[indexPath.row];
    }else if ([className isEqualToString:@"File"]) {
        //Found video objects
        dataSelected = data[indexPath.row];
    }
    
    if (self.selectedData)
        self.selectedData(dataSelected);
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
