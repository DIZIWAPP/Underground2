//
//  UGWatermark.m
//  undergroundNetwork
//
//  Created by Jon Como on 7/11/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "UGWatermark.h"
#import "Macros.h"
#import <QuartzCore/QuartzCore.h>
//#import <GPUImage.h>

@implementation UGWatermark
{
//    GPUImageMovie *movieFile;
//    GPUImageMovieWriter *movieWriter;
//    GPUImageGammaFilter *filter;
}

-(void)performWithText:(NSString *)text inVideoAtURL:(NSURL *)videoURL completion:(void (^)(NSURL *))block
{
    /*
    movieFile = [[GPUImageMovie alloc] initWithAsset:[AVAsset assetWithURL:videoURL]];
    //movieFile.runBenchmark = YES;
    movieFile.playAtActualSpeed = NO;
    
    CGSize movieSize = [self sizeOfMovie:movieFile];
    
    filter = [[GPUImageGammaFilter alloc] init];
    GPUImageAlphaBlendFilter *blend = [[GPUImageAlphaBlendFilter alloc] init];
    blend.mix = 1.0;
    
    [movieFile addTarget:filter];
    
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:[self imageOverlayWithText:text size:movieSize]];
    
    [filter addTarget:blend atTextureLocation:0];
    [picture addTarget:blend atTextureLocation:1];
    
    NSURL *exportURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/rendered_watermark.mov", DOCUMENTS]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[exportURL path]])
        [[NSFileManager defaultManager] removeItemAtPath:[exportURL path] error:nil];
    
    
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:exportURL size:movieSize];
    
    [blend addTarget:movieWriter];
    
    // Configure this for video from the movie file, where we want to preserve all video frames and audio samples
    movieWriter.shouldPassthroughAudio = YES;
    movieFile.audioEncodingTarget = movieWriter;
    [movieFile enableSynchronizedEncodingUsingMovieWriter:movieWriter];
    
    [movieWriter startRecording];
    [movieFile startProcessing];
    
    [filter setFrameProcessingCompletionBlock:^(GPUImageOutput *filter, CMTime frameTime) {
        [picture processImage];
    }];
    
    __weak GPUImageMovieWriter *weakWriter = movieWriter;
    
    [movieWriter setCompletionBlock:^{
        [weakWriter finishRecording];
        [blend removeTarget:weakWriter];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block(exportURL);
        });
    }];
     */
}
/*
-(CGSize)sizeOfMovie:(GPUImageMovie *)movie
{
    AVAsset *asset = movie.asset;
    
    if ([asset.tracks count] == 0) return CGSizeMake(480, 480);
    
    CGSize returnSize = CGSizeMake(0, 0);
    
    for (AVAssetTrack *track in asset.tracks){
        if ([track.mediaType isEqualToString:AVMediaTypeVideo]){
            returnSize = [track naturalSize];
        }
    }
    
    return returnSize;
}

-(UIImage *)imageOverlayWithText:(NSString *)text size:(CGSize)movieSize
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, movieSize.width, movieSize.height)];
    
    UIFont *font = [UIFont boldSystemFontOfSize:30];
    
    CGSize textSize = [text sizeWithFont:font];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, movieSize.height - 80, textSize.width + 28, 60)];
    label.text = text;
    [label setFont:font];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setBackgroundColor:[UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.7]];
    [label setTextColor:[UIColor whiteColor]];
    label.layer.cornerRadius = 6;
    label.clipsToBounds = YES;
    
    [view addSubview:label];
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}
  */
     

@end