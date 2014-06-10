//
//  SQVideoComposer.m
//  Sequencer
//
//  Created by Jon Como on 9/15/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "SQVideoComposer.h"

#import "SRClip.h"

@implementation SQVideoComposer
{
    AVAssetExportSession *exporter;
    NSTimer *timerProgress;
    ProgressHandler progressHandler;
}

-(void)exportClips:(NSArray *)clips toURL:(NSURL *)outputFile withPreset:(NSString *)preset progress:(ProgressHandler)progress withCompletionHandler:(void (^)(NSError *))block
{
    progressHandler = progress;
    
    NSDictionary *assets = [SQVideoComposer compositionFromClips:clips];
    
    AVComposition *composition = assets[SQVideoComposerComposition];
    AVVideoComposition *videoComposition = assets[SQVideoComposerVideoComposition];
    
    exporter = [AVAssetExportSession exportSessionWithAsset:composition presetName:preset];
    
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.videoComposition = videoComposition;
    exporter.outputURL = outputFile;
    
    timerProgress = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        switch([exporter status])
        {
            case AVAssetExportSessionStatusFailed:
            case AVAssetExportSessionStatusCancelled:
            case AVAssetExportSessionStatusCompleted:
            {
                //success
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(nil);
                });
            } break;
            default:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block([NSError errorWithDomain:@"Failed to complete, user error code 100." code:100 userInfo:nil]);
                });
            } break;
        }
    }];
}

-(void)updateProgress
{
    if (exporter.status != AVAssetExportSessionStatusExporting){
        [timerProgress invalidate];
        timerProgress = nil;
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressHandler) progressHandler(exporter.progress);
        });
    }
}

+(NSDictionary *)compositionFromClips:(NSArray *)clips
{
    if (clips.count == 0) return nil;
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVMutableVideoComposition *mutableVideoComposition;
    NSMutableArray *instructions = [NSMutableArray array];
    
    CMTime startTime = kCMTimeZero;
    CGSize exportSize = CGSizeMake(0, 0); //find largest video track
    
    for (SRClip *clip in clips)
    {
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:clip.URL options:nil];
        
        if (!mutableVideoComposition){
            mutableVideoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:asset];
            [mutableVideoComposition setRenderSize:CGSizeMake(500, 500)];
        }
        
        NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
        
        AVAssetTrack *clipVideoTrack = videoTracks.count != 0 ? videoTracks[0] : nil;
        AVAssetTrack *clipAudioTrack = audioTracks.count != 0 ? audioTracks[0] : nil;
        
        if (clipVideoTrack)
            [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:clipVideoTrack atTime:startTime error:nil];
        
        if (clipAudioTrack)
            [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:clipAudioTrack atTime:startTime error:nil];
        
        if (videoTrack.naturalSize.width > exportSize.width) exportSize.width = videoTrack.naturalSize.width;
        if (videoTrack.naturalSize.height > exportSize.height) exportSize.height = videoTrack.naturalSize.height;
        
        AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        CMTimeRange range = CMTimeRangeMake(startTime, asset.duration);
        
        //clip.positionInComposition = range;
        
        //[layerInstruction setTransform:videoTrack.preferredTransform atTime:startTime];
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
        
        transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(videoTrack.naturalSize.width * 3.7/5, -videoTrack.naturalSize.height / 6));
        
        transform = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(1.1, 1.1));
        
        [layerInstruction setTransform:transform atTime:kCMTimeZero];
        
        //if (clip.modifyLayerInstruction)
            //clip.modifyLayerInstruction(layerInstruction, range);
        
        instruction.layerInstructions = @[layerInstruction];
        instruction.timeRange = range;
        
        [instructions addObject:instruction];
        
        startTime = CMTimeAdd(startTime, asset.duration);
    }
    
    mutableVideoComposition.instructions = instructions;
    
    if (!composition || !mutableVideoComposition) return nil;
    
    return @{SQVideoComposerComposition : composition, SQVideoComposerVideoComposition : mutableVideoComposition, SQVideoComposerDuration : [NSValue valueWithCMTime:startTime]};
}

+(AVMutableComposition *)timeRange:(CMTimeRange)range ofClip:(SRClip *)clip
{
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVMutableVideoComposition *mutableVideoComposition;

        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:clip.URL options:nil];
        
        if (!mutableVideoComposition){
            mutableVideoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:asset];
        }
        
        NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
        
        AVAssetTrack *clipVideoTrack = videoTracks.count != 0 ? videoTracks[0] : nil;
        AVAssetTrack *clipAudioTrack = audioTracks.count != 0 ? audioTracks[0] : nil;
        
        if (clipVideoTrack)
            [videoTrack insertTimeRange:range ofTrack:clipVideoTrack atTime:kCMTimeZero error:nil];
        
        if (clipAudioTrack)
            [audioTrack insertTimeRange:range ofTrack:clipAudioTrack atTime:kCMTimeZero error:nil];
        
        AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        [layerInstruction setTransform:videoTrack.preferredTransform atTime:kCMTimeZero];
    
    mutableVideoComposition.instructions = @[instruction];
    
    return composition;
}

@end