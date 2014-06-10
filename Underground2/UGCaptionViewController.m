//
//  UGCaptionViewController.m
//  UndergroundNetwork
//
//  Created by Jon Como on 5/23/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "UGCaptionViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "JCTransferManager.h"
#import "JCAlertViewManager.h"
#import <Parse/Parse.h>
#import "UGGraphics.h"
#import "UGMacros.h"
#import <QuartzCore/QuartzCore.h>
#import "UGTermsViewController.h"
#import "UGBlacklistManager.h"
#import "UGTermsManager.h"
#import "MBProgressHUD+SimpleHUD.h"
#import "UGFile.h"

#import "UGSocialInteraction.h"

#import "UGVideo.h"

#import "UGCurrentUser.h"

#import "UGRecordViewController.h"

#import "UGFilterViewController.h"

#import "UGTaggingManager.h"

@interface UGCaptionViewController () <UGTermsViewControllerDelegate>
{
    __weak IBOutlet UIImageView *imageViewPreview;
    __weak IBOutlet UIButton *buttonUpload;
    __weak IBOutlet UIImageView *imageViewPlay;
    __weak IBOutlet UISwitch *locationSwitch;
    
    //Tags
    UGTaggingManager *taggingManager;
    
    __weak IBOutlet UITextField *textFieldTags;
    
    UIActivityIndicatorView *activity;
    __weak IBOutlet UIButton *buttonAddTags;
    
    MBProgressHUD *progressHUD;
    
    __weak IBOutlet NSLayoutConstraint *topConstraint;
    
    UGVideo *uploadedVideo;
    UGFilterViewController *filterVC;
}

@end

@implementation UGCaptionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    taggingManager = [[UGTaggingManager alloc] init];
    taggingManager.delegate = self;
    taggingManager.topConstraint = topConstraint;
    taggingManager.textFieldTags = textFieldTags;
    
    [UGGraphics buttonRecord:buttonUpload];
    
    if (self.file.movieURL)
        [imageViewPreview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(preview)]];
    
    buttonUpload.enabled = NO;
    
    imageViewPlay.alpha = 0;
    
    if (self.file.photo){
        buttonUpload.enabled = YES;
        imageViewPreview.image = self.file.photo;
    }else{
        imageViewPreview.alpha = 0;
        
        [self.file movieThumbnailCompletion:^(UIImage *image) {
            imageViewPreview.image = image;
            self.file.thumbnail = image;
            
            [activity removeFromSuperview];
            
            [UIView animateWithDuration:0.3 animations:^{
                imageViewPreview.alpha = 1;
                imageViewPlay.alpha = 1;
            } completion:^(BOOL finished) {
                buttonUpload.enabled = YES;
            }];
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)preview
{
    if (!self.file.movieURL) return;
    
    imageViewPlay.alpha = 0;
    
    //self.file.description = textFieldDescription.text;
    
    [self.file renderWatermarkCompletion:^(NSURL *renderedURL) {
        
        imageViewPlay.alpha = 1;
        
        UIGraphicsBeginImageContext(CGSizeMake(1,1));
        
        MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:renderedURL];
        [self presentViewController:player animated:YES completion:nil];
        
        UIGraphicsEndImageContext();
    }];
    
    return;
    
    //always render
    /*
    
     UIGraphicsBeginImageContext(CGSizeMake(1,1));
     
     MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:self.file.movieWatermarkedURL];
     [self presentViewController:player animated:YES completion:nil];
     
     UIGraphicsEndImageContext();
     
     */
}

- (IBAction)upload:(id)sender
{
    for (UIGestureRecognizer *rec in imageViewPreview.gestureRecognizers)
         [imageViewPreview removeGestureRecognizer:rec];
    
    imageViewPlay.alpha = 0;
    
    /*
    MBProgressHUD *progressCanUpload = [MBProgressHUD showHUDAddedTo:imageViewPreview animated:YES];
    
    [progressCanUpload setMode:MBProgressHUDModeIndeterminate];
    
    progressCanUpload.labelText = @"Contacting Underground";
    progressCanUpload.detailsLabelText = @"Just a second";
     */
    
    //Can upload
    
    [MBProgressHUD hideAllHUDsForView:imageViewPreview animated:YES];
    
    progressHUD = [MBProgressHUD showHUDAddedTo:imageViewPreview animated:YES];
    
    [progressHUD setMode:MBProgressHUDModeDeterminate];
    [progressHUD setLabelText:@"Uploading"];
    
    buttonUpload.enabled = NO;
    
    [self.file uploadWithProgress:^(float percentage, kUploadState state) {
        
        if (state == kUploadStateS3){
            [progressHUD setMode:MBProgressHUDModeDeterminate];
            [progressHUD setLabelText:[NSString stringWithFormat:@"Uploading %.0f", percentage]];
            progressHUD.detailsLabelText = nil;
            [progressHUD setProgress:percentage/100];
        }else if (state == kUploadStateParse) {
            progressHUD.labelText = @"Uploading";
            progressHUD.detailsLabelText = @"Informing Underground";
            [progressHUD setMode:MBProgressHUDModeIndeterminate];
        }else if (state == kUploadStateWatermark){
            progressHUD.labelText = @"Rendering video";
            progressHUD.detailsLabelText = [NSString stringWithFormat:@"Adding your description"];
            [progressHUD setMode:MBProgressHUDModeIndeterminate];
        }
        
    } completion:^(BOOL success, PFObject *object) {
        
        //textFieldDescription.enabled = YES;
        
        [progressHUD hide:YES];
        
        if (!success){
            buttonUpload.enabled = YES;
            
            progressHUD.labelText = @"Upload Failed";
            progressHUD.detailsLabelText = @"Tap upload to retry.";
            
            return;
        }
        
        for (id gesture in progressHUD.gestureRecognizers)
            [progressHUD removeGestureRecognizer:gesture];
        
        uploadedVideo = [[UGVideo alloc] initWithObject:object];
        //Present the share view with the newly uploaded video
        
        dispatch_async(dispatch_get_main_queue(), ^{
            filterVC = [UGFilterViewController filterViewControllerWithBlock:^PFQuery *{
                return [[UGCurrentUser user] followersQueryForUser:[PFUser currentUser]];
            } searchText:@""];
            
            filterVC.title = @"Share";
            filterVC.mode = UGModeTypeSelect;
            
            [self.navigationController pushViewController:filterVC animated:YES];
            
            filterVC.navigationItem.hidesBackButton = YES;
            filterVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(shareVideo)];
        });
    }];
}

-(void)shareVideo
{
    //Share video to all selected in filterVC
    NSLog(@"Users: %@", filterVC.selectedUsers);
    
    for (PFUser *user in filterVC.selectedUsers){
        [UGSocialInteraction saveInteractionUser:[PFUser currentUser] sharedVideo:uploadedVideo.object toUser:user];
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    if ([UGRecordViewController handler]){
        RecordHandler handler = [UGRecordViewController handler];
        handler(uploadedVideo);
    }
}

- (IBAction)locationChange:(UISwitch *)sender
{
    self.file.shouldTagLocation = sender.isOn;
}

-(void)showServerError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Error contacting Underground's server. Please try again later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

-(void)userCanUploadCompletion:(void(^)(BOOL canUpload))block
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:UGTermsAgreed]){
        
        [self viewTermsAndChoose:YES];
        
        if (block) block(NO);
        return;
    }
    
    [[UGTermsManager sharedManager] termsUpdated:^(BOOL success, BOOL termsUpdated) {
        
        if (!success){
            if (block) block(NO);
            return;
        }
        
        if (termsUpdated)
        {
            [[JCAlertViewManager sharedManager] alertViewWithTitle:@"Attention" message:@"We've modified our terms of service, please agree to the updated terms of service before uploading." cancelButton:@"Cancel" buttons:@[@"View Terms"] completion:^(NSInteger buttonIndex) {
                if (buttonIndex == 1){
                    [self viewTermsAndChoose:NO];
                }
            }];
            
            return;
        }
        
        [[UGBlacklistManager sharedManager] isBlacklisted:^(BOOL success, BOOL blacklisted) {
            if (!success || blacklisted){
                if (block) block(NO);
                return;
            }
            
            if (block) block(YES);
        }];
    }];
}

-(void)viewTermsDontChoose
{
    [self viewTermsAndChoose:NO];
}

-(void)viewTermsAndChoose:(BOOL)choose
{
    UGTermsViewController *terms = [self.storyboard instantiateViewControllerWithIdentifier:@"termsVC"];
    terms.delegate = self;
    terms.shouldChooseImageOnComplete = choose;
    [self presentViewController:terms animated:YES completion:nil];
}

-(void)termsViewController:(UGTermsViewController *)viewController dismissedWithAction:(kTermsAction)action
{
    if (action == kTermsActionAgreed)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:UGTermsAgreed];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:UGTermsDateAgreed];
        
        if (viewController.shouldChooseImageOnComplete)
            [self upload:nil];
    }
    
    if (action == kTermsActionDisagreed)
    {
        [MBProgressHUD showMessageWithText:@"Terms Agreement" detailText:@"You must agree to our terms of service before uploading." length:4 inView:self.view];
    }
}

//collection view + tags

- (IBAction)addTags:(id)sender
{
    UIActivityIndicatorView *saveActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    saveActivity.frame = CGRectMake(buttonAddTags.frame.origin.x, buttonAddTags.frame.origin.y, 40, 40);
    [self.view addSubview:saveActivity];
    [saveActivity startAnimating];
    
    [buttonAddTags setEnabled:NO];
    buttonAddTags.alpha = 0.2;
    
    [taggingManager saveTagsCompletion:^(NSArray *tags) {

        self.file.tags = tags;
        
        [saveActivity stopAnimating];
        [saveActivity removeFromSuperview];
        
        [buttonAddTags setEnabled:YES];
        buttonAddTags.alpha = 1;
        
        NSLog(@"Done saving tags");
    }];
}

@end
