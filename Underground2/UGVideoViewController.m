//
//  UGVideoViewController.m
//  undergroundNetwork
//
//  Created by Jon Como on 8/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "UGVideoViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UGVideo.h"
#import <Parse/Parse.h>
#import "UGGraphics.h"
#import "JCParseManager.h"

#import "UGSocialInteraction.h"

#import "TTTTimeIntervalFormatter.h"

#import "UGThumbView.h"

#import "UGRecordViewController.h"
#import "UGAccountViewController.h"

#import "UGSocialBar.h"

@interface UGVideoViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    MPMoviePlayerController *videoPlayer;
    UGSocialBar *socialBar;
    
    UICollectionView *collectionViewVideos;
    
    NSMutableArray *videoReplies;
    
    UGVideo *currentVideo;
    NSString *selectedObjectId;
    
    UIRefreshControl *refresh;
    
    TTTTimeIntervalFormatter *formatter;
    
    NSMutableArray *threadsToLoad;
}

@end

@implementation UGVideoViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        //init
        self.view.backgroundColor = [UIColor blackColor];
        self.hidesBottomBarWhenPushed = YES;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    collectionViewVideos = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 44) collectionViewLayout:layout];
    
    [self.view addSubview:collectionViewVideos];
    
    collectionViewVideos.dataSource = self;
    collectionViewVideos.delegate = self;
    
    collectionViewVideos.alwaysBounceVertical = YES;
    
    [collectionViewVideos registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"videoCell"];
    
    formatter = [TTTTimeIntervalFormatter new];
    formatter.pastDeicticExpression = @"ago";
    formatter.usesAbbreviatedCalendarUnits = YES;
    
    refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [collectionViewVideos addSubview:refresh];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reply" style:UIBarButtonItemStylePlain target:self action:@selector(reply)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refresh];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [videoPlayer pause];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [videoPlayer pause];
}

-(void)refresh
{
    currentVideo = self.video;
    
    //Load all replies
    [refresh beginRefreshing];
    
    collectionViewVideos.userInteractionEnabled = NO;
    
    if (!videoReplies) videoReplies = [NSMutableArray array];
    [videoReplies removeAllObjects];
    
    [collectionViewVideos reloadData];
    
    if (self.video)
    {
        [videoReplies addObject:self.video];
        
        [self.video getReplies:^(NSMutableArray *replies) {
            
            [self addRepliesFromVideo:self.video];
            
            [refresh endRefreshing];
            [collectionViewVideos reloadData];
            collectionViewVideos.userInteractionEnabled = YES;
            
        }];
    }else if(self.newsURL)
    {
        [self loadRepliesForNewsURL:self.newsURL];
    }
}

-(void)addRepliesFromVideo:(UGVideo *)video
{
    for (UGVideo *reply in video.replies){
        [videoReplies addObject:reply];
        [self addRepliesFromVideo:reply];
    }
}

-(void)loadRepliesForNewsURL:(NSString *)url
{
    [refresh beginRefreshing];
    
    PFQuery *query = [PFQuery queryWithClassName:@"File"];
    
    [query includeKey:@"user"];
    [query orderByAscending:@"createdAt"];
    
    [query whereKey:@"newsURL" equalTo:url];
    
    threadsToLoad = [NSMutableArray array];
    [threadsToLoad removeAllObjects];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [refresh endRefreshing];
        
        if (error) {
            return;
        }
        
        for (PFObject *reply in objects)
        {
            UGVideo *threadStarter = [[UGVideo alloc] initWithObject:reply];
            [threadsToLoad addObject:threadStarter];
        }
        
        currentVideo = [threadsToLoad lastObject];
        selectedObjectId = currentVideo.object.objectId;
        
        [self loadNextThreadStarter];
    }];

}

-(void)loadNextThreadStarter
{
    if (threadsToLoad.count == 0)
    {
        //done loading threads
        [collectionViewVideos reloadData];
        collectionViewVideos.userInteractionEnabled = YES;
        
        [refresh endRefreshing];
        
        return;
    }
    
    UGVideo *threadStarter = [threadsToLoad lastObject];
    
    [threadStarter getReplies:^(NSMutableArray *replies) {
        
        [threadsToLoad removeObject:threadStarter];
        
        //Add thread starter
        [videoReplies addObject:threadStarter];
        //... and its replies
        for (UGVideo *reply in replies){
            [videoReplies addObject:reply];
        }
        
        //then load all replies for those
        for (UGVideo *reply in replies){
            [self addRepliesFromVideo:reply];
        }
        
        [self loadNextThreadStarter];
    }];
}

-(void)setVideo:(UGVideo *)video
{
    _video = video;
    
    currentVideo = video;
    selectedObjectId = video.object.objectId;
    
    if (!self.user){
        self.user = self.video.object[@"user"];
    }
}

-(void)setUser:(PFUser *)user
{
    _user = user;
    
    self.title = @"Loading";
    
    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![[JCParseManager sharedManager] userIsAnonymous:user]){
                UILabel *userLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
                userLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:20];
                userLabel.textColor = [UIColor redColor];
                userLabel.textAlignment = NSTextAlignmentCenter;
                
                [userLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewProfile)]];
                
                self.navigationItem.titleView = userLabel;
                userLabel.userInteractionEnabled = YES;
                self.navigationItem.titleView.userInteractionEnabled = YES;
                
                [self.user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    if (!error) userLabel.text = self.user.username;
                }];
            }else{
                self.title = @"Anonymous";
            }
        });
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reply
{
    __weak UGVideoViewController *weakSelf = self;
    [UGRecordViewController recordVideoCompletion:^(UGVideo *video) {
        //Save this video in relation as a reply
        
        if (weakSelf.video)
        {
            [video saveAsReplyToVideo:currentVideo.object completion:^(BOOL success) {
                //Video is the reply
                //self.video is the parent
                selectedObjectId = video.object.objectId;
                
                [UGSocialInteraction saveInteractionUsers:currentVideo.object[@"user"] video:currentVideo.object gotReply:video.object fromUser:[PFUser currentUser]];
            }];
        }else{
            [video saveAsReplyToNewsURL:self.newsURL title:self.title completion:^(BOOL success) {
                selectedObjectId = video.object.objectId;
            }];
        }
    }];
}

- (void)viewProfile
{
    [UGAccountViewController presentAccountViewControllerForUser:self.video.object[@"user"]];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell;
    
    if (videoReplies.count == 0) return nil;
    
    UGVideo *video = videoReplies[indexPath.row];
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"videoCell" forIndexPath:indexPath];
    
    for (UIView *view in cell.contentView.subviews)
         [view removeFromSuperview];
    
    if ([video.object.objectId isEqualToString:selectedObjectId])
    {
        if (![video.URL isEqual:videoPlayer.contentURL])
        {
            videoPlayer = nil;
            
            videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:video.URL];
            [cell.contentView addSubview:videoPlayer.view];
            videoPlayer.view.frame = CGRectMake(0, 0, 320, 320);
            
            currentVideo = video;
            
            [videoPlayer play];
            
            [video.object incrementKey:@"views"];
            [video.object saveInBackground];
        }
        
        if (!socialBar){
            socialBar = [[UGSocialBar alloc] initWithFrame:CGRectMake(0, 320, 320, 44)];
        }
        
        socialBar.video = video;
        
        [cell.contentView addSubview:videoPlayer.view];
        [cell.contentView addSubview:socialBar];
    }else{
        //Not selected
        
        //Remove all views
        for (UIView *view in cell.contentView.subviews)
             [view removeFromSuperview];
        
        //Setup cell
        PFImageView *thumb = [[PFImageView alloc] init];
        thumb.clipsToBounds = YES;
        thumb.layer.borderColor = [UIColor whiteColor].CGColor;
        thumb.layer.borderWidth = 2;
        thumb.layer.cornerRadius = 4;
        [cell.contentView addSubview:thumb];
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(320-80, 0, 80, 20)];
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.font = [UIFont systemFontOfSize:12];
        [cell.contentView addSubview:timeLabel];
        
        UILabel *usernameLabel = [[UILabel alloc] init];
        usernameLabel.textColor = [UIColor whiteColor];
        usernameLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:18];
        [cell.contentView addSubview:usernameLabel];
        
        //Indent lines
        int indentAmount = 14;
        for (int i = 0; i<video.indentLevel; i++){
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(i*indentAmount + 4, 0, 2, 60)];
            line.backgroundColor = [UIColor grayColor];
            [cell.contentView addSubview:line];
        }
        
        int indent = video.indentLevel * indentAmount;
        if (indent > 320/2) indent = 320/2;
        
        float p = 6; //padding
        
        thumb.frame = CGRectMake(indent + p, p, 60-p*2, 60-p*2);
        thumb.file = video.object[@"thumbnail"];
        [thumb loadInBackground];
        
        timeLabel.text = [formatter stringForTimeIntervalFromDate:[NSDate date] toDate:video.object.createdAt];
        
        float thumbOffset = thumb.frame.origin.x + thumb.frame.size.width + 4;
        usernameLabel.frame = CGRectMake(thumbOffset, 0, 320 - thumbOffset - timeLabel.frame.size.width, 38);
        usernameLabel.text = video.object[@"user"][@"username"];
    }
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return videoReplies.count;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UGVideo *video = videoReplies[indexPath.row];
    
    if ([video.object.objectId isEqualToString:selectedObjectId]) {
        //Selected is playing
        return CGSizeMake(320, 364);
    }else{
        return CGSizeMake(320, 60);
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UGVideo *video = videoReplies[indexPath.row];
    
    if ([video.object.objectId isEqualToString:selectedObjectId]) return;
    
    [videoPlayer pause];
    videoPlayer = nil;
    [videoPlayer.view removeFromSuperview];
    
    currentVideo = video;
    selectedObjectId = video.object.objectId;
    
    [collectionViewVideos reloadData];
}

@end
