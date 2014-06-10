//
//  UGVideoCell.m
//  undergroundNetwork
//
//  Created by Jon Como on 8/28/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "UGVideoCell.h"

#import "UGButtonFile.h"

#import "UGGraphics.h"

#import "JCParseManager.h"

#import "UGVideo.h"
#import <Parse/Parse.h>

#import "UGCurrentUser.h"
#import "UGAccountViewController.h"
#import "UGSocialInteraction.h"

#import "TTTTimeIntervalFormatter.h"

#import "UGNewsReaderViewController.h"

#import "UGSocialBar.h"

@interface UGVideoCell ()

@end

@implementation UGVideoCell
{
    BOOL runOnce;
    
    __weak IBOutlet UILabel *labelTitle;
    __weak IBOutlet UILabel *labelInformation;
    __weak IBOutlet UILabel *labelTime;
    
    __weak IBOutlet PFImageView *thumbnail;
    __weak IBOutlet PFImageView *imageViewUser;
    
    __weak IBOutlet UGButtonFile *buttonPlay;
    
    UILabel *newsReplyLabel;
    UIImageView *imageViewNewsIcon;
    
    UGSocialBar *socialBar;
}

-(void)setVideo:(UGVideo *)video
{
    _video = video;
    
    self.layer.cornerRadius = 8;
    
    PFObject *file = video.object;
    
    PFUser *user = file[@"user"];
    
    if (imageViewUser.gestureRecognizers.count == 0){
        imageViewUser.userInteractionEnabled = YES;
        [imageViewUser addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapped)]];
        [labelTitle addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapped)]];
    }
    
    if (socialBar){
        [socialBar removeFromSuperview];
        socialBar = nil;
    }
    
    socialBar = [[UGSocialBar alloc] initWithFrame:CGRectMake(0, 88, self.contentView.frame.size.width + 8, 44)];
    [self addSubview:socialBar];
    socialBar.video = video;
    
    if (user[@"profileImage"]){
        [imageViewUser setFile:user[@"profileImage"]];
        [imageViewUser loadInBackground];
    }else{
        [imageViewUser setImage:[UIImage imageNamed:@"profileImage"]];
    }
    
    if (imageViewUser.layer.borderWidth == 0){
        imageViewUser.layer.cornerRadius = 6;
    }
    
    [newsReplyLabel removeFromSuperview];
    [imageViewNewsIcon removeFromSuperview];
    imageViewNewsIcon = nil;
    
    if (video.object[@"newsURL"])
    {
        newsReplyLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 130, 300 - 60, 60)];
        newsReplyLabel.text = video.object[@"newsTitle"];
        newsReplyLabel.textColor = [UIColor blackColor];
        newsReplyLabel.backgroundColor = [UIColor whiteColor];
        [newsReplyLabel setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:14]];
        [newsReplyLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewArticle)]];
        newsReplyLabel.userInteractionEnabled = YES;
        newsReplyLabel.numberOfLines = 2;
        [self.contentView addSubview:newsReplyLabel];
        
        imageViewNewsIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 130, 60, 60)];
        imageViewNewsIcon.image = [UIImage imageNamed:@"newsIcon"];
        imageViewNewsIcon.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:imageViewNewsIcon];
    }
    
    thumbnail.image = nil;
    
    PFFile *thumb = file[@"thumbnail"];
    
    if (thumb){
        [thumbnail setFile:thumb];
        [thumbnail loadInBackground];
    }
    
    labelTitle.text = @"File";
    
    NSString *title = [[JCParseManager sharedManager] nameForObject:file];
    
    if (title)
        labelTitle.text = title;
    
    NSString *locality = file[@"locality"] ? file[@"locality"] : @"No location";
    labelInformation.text = locality;
    
    labelTime.text = [[TTTTimeIntervalFormatter shared] stringForTimeIntervalFromDate:[NSDate date] toDate:file.createdAt];
}

-(void)viewArticle
{
    [UGNewsReaderViewController presentNewsReaderViewControllerWithURL:[NSURL URLWithString:self.video.object[@"newsURL"]]];
}

-(void)userTapped
{
    if ([[JCParseManager sharedManager] userIsAnonymous:self.video.object[@"user"]]) return;
    [UGAccountViewController presentAccountViewControllerForUser:self.video.object[@"user"]];
}

- (IBAction)play:(id)sender
{
    [self.video playInVideoViewController];
}

@end
