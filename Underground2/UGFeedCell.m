//
//  UGFeedCell.m
//  Sportsbuddyz
//
//  Created by Jon Como on 5/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGFeedCell.h"

#import "UGRSSItem.h"

#import "UGRSSManagerViewController.h"

#import "SDWebImage/UIImageView+WebCache.h"

#import "MBProgressHUD.h"
#import <Parse/Parse.h>

@implementation UGFeedCell
{
    __weak IBOutlet UIImageView *imageViewIcon;
    __weak IBOutlet UILabel *labelName;
    __weak IBOutlet UIButton *buttonSub;
}

-(void)setRssGroup:(NSDictionary *)rssGroup
{
    _rssGroup = rssGroup;
    
    NSString *teamName = rssGroup[@"team"];
    
    labelName.text = teamName;
    
    if ([teamName isEqualToString:@"Headlines"])
    {
        imageViewIcon.backgroundColor = [UIColor clearColor];
        imageViewIcon.image = [UIImage imageNamed:@"newsIconPaper"];
        
        imageViewIcon.layer.borderWidth = 0;
    }else{
        teamName = [teamName stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        
        imageViewIcon.backgroundColor = [UIColor whiteColor];
        
        imageViewIcon.layer.borderColor = [UIColor whiteColor].CGColor;
        imageViewIcon.layer.borderWidth = 2;
        imageViewIcon.clipsToBounds = YES;
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www2.underground.net/sportsbuddyzLogos/%@.png", teamName]];
        [imageViewIcon setImageWithURL:url completed:nil];
    }
    
    imageViewIcon.layer.cornerRadius = 6;
    
    if (buttonSub.allTargets.count == 0){
        [buttonSub addTarget:self action:@selector(toggleSubscription) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [buttonSub setImage:[UIImage imageNamed:[self doesGroupHaveSubscription:rssGroup] ? @"selected" : @"follow"] forState:UIControlStateNormal];
}

-(BOOL)doesGroupHaveSubscription:(NSDictionary *)group
{
    for (UGRSSItem *item in group[@"items"]){
        if (item.isSubscribed) return YES;
    }
    
    return NO;
}

-(void)toggleSubscription
{
    NSDictionary *group = self.rssGroup;
    
    [self.manager toggleSubscriptionToGroup:group completion:nil];
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
