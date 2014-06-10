//
//  UGSocialBar.m
//  Sportsbuddyz
//
//  Created by Jon Como on 3/5/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGSocialBar.h"

#import "UGTagDisplayView.h"
#import "UGCurrentUser.h"
#import "UGVideo.h"

#import "UGRecordViewController.h"

#import "UGSocialInteraction.h"

#import <Parse/Parse.h>

//Shows tags and social interaction buttons: like etc

@interface UGSocialBar () <UIAlertViewDelegate>

@end

@implementation UGSocialBar
{
    UGTagDisplayView *tags;
    
    UILabel *labelViews;
    UILabel *labelReplies;
    
    UIImageView *iconEye;
    UIImageView *iconArrow;
    
    UIButton *buttonLike;
    UIButton *buttonShare;
    UIButton *buttonReply;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        float p = 4; //padding
        float bs = 28;
        
        self.backgroundColor = [UIColor whiteColor];
        
        labelViews = [[UILabel alloc] initWithFrame:CGRectMake(p*6, p*2, 60, 12)];
        labelViews.textColor = [UIColor blackColor];
        labelViews.font = [UIFont systemFontOfSize:13];
        [self addSubview:labelViews];
        
        labelReplies = [[UILabel alloc] initWithFrame:CGRectMake(p*6, labelViews.frame.origin.y + labelViews.frame.size.height + p, labelViews.frame.size.width, 12)];
        labelReplies.textColor = [UIColor blackColor];
        labelReplies.font = [UIFont systemFontOfSize:13];
        [self addSubview:labelReplies];
        
        iconEye = [[UIImageView alloc] initWithFrame:CGRectMake(p*2, labelViews.frame.origin.y, 12, 12)];
        iconEye.image = [UIImage imageNamed:@"iconEye"];
        [self addSubview:iconEye];
        
        iconArrow = [[UIImageView alloc] initWithFrame:CGRectMake(p*2, labelReplies.frame.origin.y, 12, 12)];
        iconArrow.image = [UIImage imageNamed:@"arrow"];
        [self addSubview:iconArrow];
        
        tags = [[UGTagDisplayView alloc] initWithFrame:CGRectMake(labelViews.frame.size.width - 10, 0, frame.size.width - bs*3 - labelViews.frame.size.width - p, frame.size.height)];
        [self addSubview:tags];
        
        float buttonX = -18;
        float buttonY = 8;
        
        buttonReply = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonReply setImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
        buttonReply.frame = CGRectMake(frame.size.width +buttonX -bs, buttonY, bs, bs);
        [buttonReply addTarget:self action:@selector(reply) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buttonReply];
        
        buttonLike = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonLike.frame = CGRectMake(frame.size.width +buttonX - bs*3, buttonY, bs, bs);
        [buttonLike setImage:[UIImage imageNamed:@"likeOutline"] forState:UIControlStateNormal];
        buttonLike.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:buttonLike];
        
        buttonShare = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonShare setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        buttonShare.frame = CGRectMake(frame.size.width +buttonX-bs*2, buttonY, bs, bs);
        [buttonShare addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buttonShare];
    }
    
    return self;
}

-(void)setVideo:(UGVideo *)video
{
    _video = video;
    
    PFUser *user = video.object[@"user"];
    
    //Update tags
    tags.video = video;
    
    labelReplies.text = @"";
    labelViews.text = @"";
    
    if (video.object[@"views"]){
        labelViews.text = [NSString stringWithFormat:@"%i", [video.object[@"views"] intValue]];
    }else{
        labelViews.text = @"0";
    }
    
    [self.video getRepliesCount:^(BOOL success, int count) {
        if (success) labelReplies.text = [NSString stringWithFormat:@"%i", count];
    }];
    
    
     if ([[PFUser currentUser].objectId isEqualToString:user.objectId]){
         //show delete
         [buttonLike setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
         [buttonLike addTarget:self action:@selector(deleteVideo) forControlEvents:UIControlEventTouchUpInside];
     }else{
         //Allow liking if its another user's video
         [buttonLike addTarget:self action:@selector(like) forControlEvents:UIControlEventTouchUpInside];
         
         [buttonLike setImage:[UIImage imageNamed:@"likeOutline"] forState:UIControlStateNormal];
         
         [[UGCurrentUser user] isObjectLiked:video.object completion:^(BOOL isLiked) {
             [buttonLike setImage:[UIImage imageNamed:isLiked ? @"like" : @"likeOutline"] forState:UIControlStateNormal];
         }];
     }
}

- (void)deleteVideo
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Post?" message:@"Are you sure you want to delete your post?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        //Clicked delete
        [self.video.object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Successful" message:@"Refresh to see updated feed" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            });
        }];
    }
}

-(void)reply
{
    [UGRecordViewController recordVideoCompletion:^(UGVideo *video) {
        [video saveAsReplyToVideo:self.video.object completion:^(BOOL success) {
            [UGSocialInteraction saveInteractionUsers:self.video.object[@"user"] video:self.video.object gotReply:video.object fromUser:[PFUser currentUser]];
        }];
    }];
}

-(void)like
{
    [[UGCurrentUser user] toggleLikeObject:self.video.object completion:^(BOOL isLiked) {
        self.video.isLiked = isLiked;
        
        //Update button
        [buttonLike setImage:[UIImage imageNamed:isLiked ? @"like" : @"likeOutline"] forState:UIControlStateNormal];
    }];
}

-(void)share
{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://videos.sportsbuddyz.com/sb/index.php?id=%@", self.video.object.objectId]];
    NSString *message = @"Check out this awesome video on SportsBuddyz!";
    
    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:@[message, URL] applicationActivities:nil];
    
    [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:activity animated:YES completion:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
