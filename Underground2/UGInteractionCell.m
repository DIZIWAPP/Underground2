//
//  UGInteractionCell.m
//  Sportsbuddyz
//
//  Created by Jon Como on 2/28/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGInteractionCell.h"
#import "GLTapLabel.h"
#import "UGAccountViewController.h"
#import "UGVideo.h"

#import "JCParseManager.h"

#import "TTTTimeIntervalFormatter.h"

#import "UGVideoViewController.h"

#import "UGSocialInteraction.h"

#import <Parse/Parse.h>

static TTTTimeIntervalFormatter *formatter;

@interface UGInteractionCell () <GLTapLabelDelegate>

@end

@implementation UGInteractionCell
{
    __weak IBOutlet PFImageView *imageViewThumb;
    __weak IBOutlet GLTapLabel *labelMessage;
    __weak IBOutlet UIButton *buttonPlay;
    __weak IBOutlet UILabel *labelTime;
}

-(void)setInteraction:(PFObject *)interaction
{
    _interaction = interaction;
    
    //setup message
    labelMessage.delegate = self;
    labelMessage.linkColor = [UIColor redColor];
    imageViewThumb.image = nil;
    
    imageViewThumb.layer.cornerRadius = 8;
    imageViewThumb.clipsToBounds = YES;
    imageViewThumb.layer.borderColor = [UIColor redColor].CGColor;
    imageViewThumb.layer.borderWidth = 2;
    
    [imageViewThumb setImage:[UIImage imageNamed:@"profileImage"]];
    
    if (!formatter){
        formatter = [TTTTimeIntervalFormatter new];
        formatter.usesAbbreviatedCalendarUnits = YES;
        formatter.pastDeicticExpression = @"ago";
    }
    
    labelTime.text = [formatter stringForTimeIntervalFromDate:[NSDate date] toDate:interaction.createdAt];
    
    //Common objects
    PFUser *userSecondary = interaction[@"userSecondary"];
    PFObject *reply = interaction[@"reply"];
    PFObject *video = interaction[@"video"];
    
    BOOL isAnonymous = [[JCParseManager sharedManager] userIsAnonymous:userSecondary];
    
    if ([interaction[UGInteractionType] isEqualToString:UGInteractionReply])
    {
        //Its a video reply!
        labelMessage.text = [NSString stringWithFormat:@"@%@ replied to your @video", isAnonymous ? @"Anonymous" : userSecondary.username];
        
        if (isAnonymous){
            [imageViewThumb setImage:[UIImage imageNamed:@"profileImage"]];
        }else{
            [imageViewThumb setFile:reply[@"thumbnail"]];
            [imageViewThumb loadInBackground];
        }
        
        buttonPlay.alpha = 1;
        [buttonPlay setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }else if ([interaction[UGInteractionType] isEqualToString:UGInteractionLike])
    {
        //Its a like!
        labelMessage.text = [NSString stringWithFormat:@"@%@ liked your @video", isAnonymous ? @"Anonymous" : userSecondary.username];
        
        if (isAnonymous){
            [imageViewThumb setImage:[UIImage imageNamed:@"profileImage"]];
        }else{
            [imageViewThumb setFile:userSecondary[@"profileImage"]];
            [imageViewThumb loadInBackground];
        }
        
        [buttonPlay setImage:nil forState:UIControlStateNormal];
    }else if ([interaction[UGInteractionType] isEqualToString:UGInteractionShare])
    {
        //It's a share!
        
        labelMessage.text = [NSString stringWithFormat:@"@%@ sent you a video", isAnonymous ? @"Anonymous" : userSecondary.username];
        
        [imageViewThumb setFile:video[@"thumbnail"]];
        [imageViewThumb loadInBackground];
        
        buttonPlay.alpha = 1;
        [buttonPlay setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
}

-(void)label:(GLTapLabel *)label didSelectedHotWord:(NSString *)word
{
    word = [word substringFromIndex:1];
    
    PFUser *userSecondary = self.interaction[@"userSecondary"];
    
    if ([word isEqualToString:userSecondary.username]){
        //Show the user
        [UGAccountViewController presentAccountViewControllerForUser:userSecondary];
        return;
    }
    
    if ([self.interaction[UGInteractionType] isEqualToString:UGInteractionReply])
    {
        if ([word isEqualToString:@"video"]){
            UGVideo *video = [[UGVideo alloc] initWithObject:self.interaction[@"video"]];
            [video playInVideoViewController];
        }
    }else if ([self.interaction[UGInteractionType] isEqualToString:UGInteractionLike])
    {
        if ([word isEqualToString:@"video"])
        {
            //Show video
            UGVideo *video = [[UGVideo alloc] initWithObject:self.interaction[@"video"]];
            [video playInVideoViewController];
        }
    }else if ([self.interaction[UGInteractionType] isEqualToString:UGInteractionShare])
    {
        if ([word isEqualToString:@"video"])
        {
            //Show video
            UGVideo *video = [[UGVideo alloc] initWithObject:self.interaction[@"video"]];
            [video playInVideoViewController];
        }
    }
}

- (IBAction)playVideo:(id)sender {
    if ([self.interaction[UGInteractionType] isEqualToString:UGInteractionReply])
    {
        UGVideo *reply = [[UGVideo alloc] initWithObject:self.interaction[@"reply"]];
        [reply playInVideoViewController];
        
    }else if ([self.interaction[UGInteractionType] isEqualToString:UGInteractionLike])
    {
        //Show user
        if ([[JCParseManager sharedManager] userIsAnonymous:self.interaction[@"userSecondary"]]) return;
        
        PFUser *userSecondary = self.interaction[@"userSecondary"];
        [UGAccountViewController presentAccountViewControllerForUser:userSecondary];
    }else if ([self.interaction[UGInteractionType] isEqualToString:UGInteractionShare])
    {
        UGVideo *video = [[UGVideo alloc] initWithObject:self.interaction[@"video"]];
        [video playInVideoViewController];
    }
}


@end
