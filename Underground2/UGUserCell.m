//
//  UGUserCell.m
//  Sportsbuddyz
//
//  Created by Jon Como on 3/17/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGUserCell.h"

#import "UGCurrentUser.h"

#import "UGAccountViewController.h"

#import <Parse/Parse.h>

@implementation UGUserCell
{
    __weak IBOutlet PFImageView *imageViewThumb;
    __weak IBOutlet UILabel *labelUsername;
    __weak IBOutlet UIButton *buttonFollow;
}

-(void)setUser:(PFUser *)user
{
    _user = user;
    
    //update ui
    labelUsername.text = user.username;
    if (user[@"profileImage"]){
        imageViewThumb.file = user[@"profileImage"];
        [imageViewThumb loadInBackground];
    }else{
        imageViewThumb.image = [UIImage imageNamed:@"profileImage"];
    }
    
    buttonFollow.alpha = 1;
    buttonFollow.enabled = YES;
    
    imageViewThumb.layer.borderColor = [UIColor whiteColor].CGColor;
    imageViewThumb.layer.borderWidth = 2;
    imageViewThumb.clipsToBounds = YES;
    imageViewThumb.layer.cornerRadius = 6;
}

-(void)setType:(UGUserCellType)type
{
    _type = type;
    
    if (self.type == UGUserCellTypeFollow)
    {
        if (self.gestureRecognizers.count == 0)
        {
            [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewUser)]];
            
            [buttonFollow addTarget:self action:@selector(toggleFollow) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [[UGCurrentUser user] isFollowingUser:self.user completion:^(BOOL isFollowing) {
            [self setIsSelected:isFollowing];
        }];
    }else{
        buttonFollow.userInteractionEnabled = NO;
    }
}

-(void)viewUser
{
    [UGAccountViewController presentAccountViewControllerForUser:self.user];
}

- (void)toggleFollow
{
    buttonFollow.enabled = NO;
    
    [[UGCurrentUser user] toggleFollowUser:self.user completion:^(BOOL isFollowing) {
        buttonFollow.enabled = YES;
        [self setIsSelected:isFollowing];
    }];
}

-(void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    
    [buttonFollow setImage:[UIImage imageNamed:isSelected ? @"selected" : @"follow"] forState:UIControlStateNormal];
}

@end