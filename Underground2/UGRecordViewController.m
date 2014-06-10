//
//  UGRecordViewController.m
//  undergroundNetwork
//
//  Created by Jon Como on 8/27/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "UGRecordViewController.h"

#import "UGGraphics.h"

#import "UGCaptionViewController.h"
#import "UGMacros.h"
#import "Macros.h"
#import "SRSequencer.h"
#import "LXReorderableCollectionViewFlowLayout.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MBProgressHUD+SimpleHUD.h"
#import "JCActionSheetManager.h"
#import "UGFile.h"

#import "UGTabBarController.h"

static RecordHandler recordHandler;

@interface UGRecordViewController () <SRSequencerDelegate>
{
    __weak IBOutlet UIView *viewPreview;
    __weak IBOutlet UICollectionView *collectionViewClips;
    __weak IBOutlet UIButton *buttonRecord;
    __weak IBOutlet UIButton *buttonFlip;
    __weak IBOutlet UIButton *buttonDone;
    __weak IBOutlet UIButton *buttonCancel;
    __weak IBOutlet UILabel *labelToolTip;
    //__weak IBOutlet UIButton *buttonPreview;
    
    //Sequencer
    SRSequencer *sequencer;
}

@end

@implementation UGRecordViewController

+(UGRecordViewController *)recordVideoCompletion:(RecordHandler)block
{
    recordHandler = [block copy];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    
    UINavigationController *nav = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"recordVC"];
    UGRecordViewController *recordVC = nav.viewControllers[0];
    
    [[UGTabBarController tabBarController] presentViewController:nav animated:YES completion:nil];
    
    return recordVC;
}

+(RecordHandler)handler
{
    return recordHandler;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    sequencer = [[SRSequencer alloc] initWithDelegate:self];
    sequencer.collectionViewClips = collectionViewClips;
    sequencer.viewPreview = viewPreview;
    
    [UGGraphics buttonRecord:buttonDone];
    [UGGraphics button:buttonCancel];
    
    buttonDone.enabled = NO;
    //buttonPreview.enabled = NO;
    buttonRecord.enabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackChanged) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!sequencer.captureSession){
        [sequencer setupSessionWithDefaults];
    }else if (!sequencer.captureSession.isRunning || sequencer.captureSession.isInterrupted){
        [sequencer.captureSession startRunning];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    
    if (!sequencer.isPaused){
        [self recordTouchUp:nil];
    }
    
    [sequencer.moviePlayerController stop];
    [sequencer.captureSession stopRunning];
    
    //    [viewPreview removeFromSuperview];
    //    [videoCamera stopCameraCapture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    NSLog(@"Bye record");
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)delayRecord
{
    
}

-(void)playbackChanged
{
    /*
    if (sequencer.moviePlayerController.playbackState != MPMoviePlaybackStatePlaying)
    {
        [buttonPreview setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }else{
        [buttonPreview setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    } */
}

- (IBAction)done:(id)sender
{
    [self prepareClipCompletion:^(NSURL *outputURL) {
        UGFile *file = [[UGFile alloc] initWithURL:outputURL photo:nil];
        [self presentCaptionWithFile:file];
    }];
}

- (IBAction)cancel:(id)sender
{
    [sequencer.captureSession stopRunning];
    sequencer = nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)recordTouchDown:(id)sender
{
    //[self record];
}

- (IBAction)recordTouchUp:(id)sender
{
    if (sequencer.isRecording)
    {
        [sequencer pauseRecording];
    }else{
        [sequencer record];
    }
}

- (IBAction)recordCancel:(id)sender
{
    //[self stopRecording];
}

- (IBAction)flipCamera:(id)sender
{
    [sequencer flipCamera];
}

- (IBAction)preview:(id)sender
{
    [sequencer previewOverView:viewPreview];
    
    [self.view bringSubviewToFront:buttonCancel];
}

-(void)prepareClipCompletion:(void(^)(NSURL *outputURL))block
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:viewPreview animated:YES];
    [hud setMode:MBProgressHUDModeIndeterminate];
    [hud setLabelText:@"Rendering"];
    
    buttonDone.enabled = NO;
    
    NSURL *finalOutputFileURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@-%ld.mp4", NSTemporaryDirectory(), @"final", (long)[[NSDate date] timeIntervalSince1970]]];
    
    [sequencer finalizeClips:sequencer.clips toFile:finalOutputFileURL
                         withVideoSize:CGSizeMake(500, 500)
                            withPreset:AVAssetExportPresetMediumQuality
                 withCompletionHandler:^(NSError *error)
     {
         [MBProgressHUD hideAllHUDsForView:viewPreview animated:YES];
         
         if(error)
         {
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.domain delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alertView show];
         }
         else
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 buttonDone.enabled = YES;
                 
                 if (block)
                     block(finalOutputFileURL);
             });
         }
     }];
}

-(void)library
{
    [JCActionSheetManager sharedManager].delegate = self;
    [[JCActionSheetManager sharedManager] imagePickerInView:self.view onlyLibrary:YES completion:^(UIImage *image, NSURL *movieURL) {
        [self presentCaptionWithFile:[[UGFile alloc] initWithURL:movieURL photo:image]];
    }];
}

#pragma SequencerDelegate

-(void)sequencer:(SRSequencer *)sequencer clipCountChanged:(int)count
{
    if (count == 0){
        buttonDone.enabled = NO;
        //buttonPreview.enabled = NO;
    }else{
        buttonDone.enabled = YES;
        //buttonPreview.enabled = YES;
    }
}

-(void)sequencer:(SRSequencer *)sequencer isRecording:(BOOL)recording
{
    if (recording)
    {
        viewPreview.layer.borderColor = [UIColor redColor].CGColor;
        viewPreview.layer.borderWidth = 4;
    }else{
        viewPreview.layer.borderColor = [UIColor redColor].CGColor;
        viewPreview.layer.borderWidth = 0;
    }
}

-(void)presentCaptionWithFile:(UGFile *)file
{
    UGCaptionViewController *captionVC = [self.storyboard instantiateViewControllerWithIdentifier:@"captionVC"];
    
    captionVC.file = file;
    captionVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:captionVC animated:YES];
    });
}

@end
