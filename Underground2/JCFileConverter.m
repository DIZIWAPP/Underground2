//
//  JCFileConverter.m
//  UndergroundNetwork
//
//  Created by Jon Como on 5/17/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "JCFileConverter.h"
#import <AVFoundation/AVFoundation.h>
#import "Macros.h"

@interface JCFileConverter ()

@end

@implementation JCFileConverter

+(JCFileConverter *)sharedManager
{
    static JCFileConverter *sharedManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

-(void)convertFileAtURL:(NSURL *)uncompressedURL completion:(CompressionComplete)block
{
    AVURLAsset *movieAsset = [[AVURLAsset alloc] initWithURL:uncompressedURL options:nil];
    NSError *error;
    
    // *** ASSET READER ***
    AVAssetReader *assetReader = [[AVAssetReader alloc] initWithAsset:movieAsset error:&error];
    NSArray* videoTracks = [movieAsset tracksWithMediaType:AVMediaTypeVideo];
    // asset track
    AVAssetTrack *videoTrack = [videoTracks objectAtIndex:0];
    
    CGSize size = videoTrack.naturalSize;
    
    NSDictionary *outputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};
    
    // asset reader track output
    AVAssetReaderTrackOutput *assetReaderOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack
                                                                                   outputSettings:outputSettings];
    if(![assetReader canAddOutput:assetReaderOutput])
        NSLog(@"unable to add reader output");
    else
        [assetReader addOutput:assetReaderOutput];
    
    // *** ASSET WRITER ***
    NSURL *writeURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/compressed.mov", DOCUMENTS]];
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:writeURL fileType:AVFileTypeQuickTimeMovie error:&error];
    NSParameterAssert(videoWriter);
    NSLog(@"asset writer %d %d", [videoWriter status], [error code]);

    NSDictionary *videoSettings = @{AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : @(size.width), AVVideoHeightKey : @(size.height), AVVideoCompressionPropertiesKey : @{AVVideoAverageBitRateKey : @(64.0*1024.0)}};
    
    AVAssetWriterInput *writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    // set preffered transform for output video
    writerInput.transform = [videoTrack preferredTransform];
    
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    [videoWriter addInput:writerInput];
    
    writerInput.expectsMediaDataInRealTime = NO;
    
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    
    [assetReader startReading];
    dispatch_queue_t mediaInputQueue = dispatch_queue_create("mediaInputQueue", NULL);
    [writerInput requestMediaDataWhenReadyOnQueue:mediaInputQueue usingBlock:^{
        NSLog(@"Asset Writer ready : %d", writerInput.readyForMoreMediaData);
        while (writerInput.readyForMoreMediaData) {
            CMSampleBufferRef nextBuffer;
            if ([assetReader status] == AVAssetReaderStatusReading && (nextBuffer = [assetReaderOutput copyNextSampleBuffer])) {
                if (nextBuffer) {
                    NSLog(@"Adding buffer");
                    [writerInput appendSampleBuffer:nextBuffer];
                }
            } else {
                [writerInput markAsFinished];
                
                switch ([assetReader status]) {
                    case AVAssetReaderStatusReading:
                        break;
                    case AVAssetReaderStatusFailed:
                    {
                        [videoWriter cancelWriting];
                        
                        //failed
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (block) block(nil);
                        });
                    }
                    break;
                        
                    case AVAssetReaderStatusCompleted:
                    {
                        NSLog(@"Writer completed");
                        [videoWriter endSessionAtSourceTime:movieAsset.duration];
                        [videoWriter finishWritingWithCompletionHandler:^{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (block) block(writeURL);
                            });
                        }];
                    }
                    break;
                }
                break;
            }
        }
    }];
}



@end
