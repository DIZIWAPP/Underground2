//
//  UGVideoPlayerManager.h
//  undergroundNetwork
//
//  Created by Jon Como on 8/28/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@class UGVideoPlayerManager;

@protocol UGVideoPlayerManagerDelegate <NSObject>

@optional
-(void)videoPlayerManagerStateChanged:(UGVideoPlayerManager *)manager;
-(void)videoPlayerManagerDownloadProgress:(float)progress;
-(void)videoPlayerManagerCurrentTime:(float)currentTime;

-(void)videoPlayerManagerPlaybackBegan:(UGVideoPlayerManager *)manager;
-(void)videoPlayerManagerPlaybackFinished:(UGVideoPlayerManager *)manager;

-(void)videoPlayerManagerChangedDelegates:(UGVideoPlayerManager *)manager;

@end

@interface UGVideoPlayerManager : NSObject

+(UGVideoPlayerManager *)sharedManager;

@property (nonatomic, weak) id <UGVideoPlayerManagerDelegate> delegate;
@property (nonatomic, strong) MPMoviePlayerController *player;

-(void)playURL:(NSURL *)fileURL inView:(UIView *)view;
-(void)stopPreview;

@end
