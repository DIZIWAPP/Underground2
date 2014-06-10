//
//  UGVideoPlayerManager.m
//  undergroundNetwork
//
//  Created by Jon Como on 8/28/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "UGVideoPlayerManager.h"

@implementation UGVideoPlayerManager
{
    NSURL *lastURL;
    NSTimer *updateTimer;
}

+(UGVideoPlayerManager *)sharedManager
{
    static UGVideoPlayerManager *sharedManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

-(id)init
{
    if (self = [super init]) {
        //init
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackChanged) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStarted) name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    }
    
    return self;
}

-(void)setDelegate:(id<UGVideoPlayerManagerDelegate>)delegate
{
    if ([self.delegate respondsToSelector:@selector(videoPlayerManagerChangedDelegates:)])
        [self.delegate videoPlayerManagerChangedDelegates:self];
    
    _delegate = delegate;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

-(void)playURL:(NSURL *)fileURL inView:(UIView *)view
{
    if (self.player && [lastURL isEqual:fileURL])
    {
        [self stopPreview];
        return;
    }else{
        lastURL = fileURL;
        
        [self stopPreview];
        
        self.player = [[MPMoviePlayerController alloc] initWithContentURL:fileURL];
        [self.player setControlStyle:MPMovieControlStyleNone];
    }
    
    self.player.view.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
    [view addSubview:self.player.view];
    
    [self.player play];
    
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(update) userInfo:nil repeats:YES];
}

-(void)stopPreview
{
    [updateTimer invalidate];
    updateTimer = nil;
    
    [self.player stop];
    [self.player.view removeFromSuperview];
    self.player = nil;
}

-(void)playbackChanged
{
    if ([self.delegate respondsToSelector:@selector(videoPlayerManagerStateChanged:)])
        [self.delegate videoPlayerManagerStateChanged:self];
}

-(void)playbackStarted
{
    if ([self.delegate respondsToSelector:@selector(videoPlayerManagerPlaybackBegan:)])
        [self.delegate videoPlayerManagerPlaybackBegan:self];
}

-(void)playbackFinished
{
    if ([self.delegate respondsToSelector:@selector(videoPlayerManagerPlaybackFinished:)])
        [self.delegate videoPlayerManagerPlaybackFinished:self];
}

-(void)update
{
    float downloadProgress = self.player.playableDuration / self.player.duration;
    
    if ([self.delegate respondsToSelector:@selector(videoPlayerManagerDownloadProgress:)])
        [self.delegate videoPlayerManagerDownloadProgress:downloadProgress];
    
    float currentTime = self.player.currentPlaybackTime / self.player.duration;
    
    if ([self.delegate respondsToSelector:@selector(videoPlayerManagerCurrentTime:)])
        [self.delegate videoPlayerManagerCurrentTime:currentTime];
}

@end
