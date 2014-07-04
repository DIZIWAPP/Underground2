//
//  UGPollCell.m
//  Underground2
//
//  Created by Jon Como on 6/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGPollCell.h"

#import "UGRecordViewController.h"
#import "UGVideo.h"

#import "UGVideoFeedView.h"

#import "UGFilterViewController.h"

#import "TTTTimeIntervalFormatter.h"

#import <QuartzCore/QuartzCore.h>

#import "MWFeedItem.h"

#import "TTTTimeIntervalFormatter.h"

#import "UGLiveViewController.h"

#import "UGPollResultsViewController.h"

@implementation UGPollCell
{
    __weak IBOutlet UILabel *name;
    __weak IBOutlet UIWebView *webViewSummary;
    __weak IBOutlet UIButton *buttonAgree;
    __weak IBOutlet UIButton *buttonDiscuss;
    __weak IBOutlet UIButton *buttonDisagree;
    __weak IBOutlet UILabel *labelTime;
}

-(void)setItem:(MWFeedItem *)item
{
    _item = item;
    
    name.text = item.title;
    //detail.text = item.summary;
    labelTime.text = [[TTTTimeIntervalFormatter shared] stringForTimeIntervalFromDate:[NSDate date] toDate:item.date];
    
    if (name.gestureRecognizers.count == 0){
        [name addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewArticle)]];
        [name setUserInteractionEnabled:YES];
    }
    
    NSString *content = @"";
    
    if (item.video)
        content = [NSString stringWithFormat:@"<iframe width='300' height='160' src='%@' frameborder='0' allowfullscreen></iframe>", item.video];
    if (item.summary)
        content = [NSString stringWithFormat:@"%@%@", content, item.summary];
    
    [webViewSummary loadHTMLString:content baseURL:[NSURL URLWithString:@"http://wwww.underground.net"]];
    
    [UIView performWithoutAnimation:^{
        [buttonAgree setEnabled:NO];
        [buttonDisagree setEnabled:NO];
        [buttonDiscuss setEnabled:NO];
    }];
    
    [item getObjectCompletion:^(PFObject *object) {
        [self updateUI];
    }];
    
    buttonAgree.clipsToBounds = YES;
    buttonDisagree.clipsToBounds = YES;
    
    buttonDisagree.layer.cornerRadius = 6;
    buttonAgree.layer.cornerRadius = 6;
}

- (IBAction)agree:(id)sender {
    [self vote:YES];
}

- (IBAction)disagree:(id)sender {
    [self vote:NO];
}

-(void)vote:(BOOL)agree
{
    [self enableUI:NO];
    
    __weak UGPollCell *weakSelf = self;
    
    
    PFRelation *yesRelation = [self.item.petitionObject relationforKey:@"votesYes"];
    PFRelation *noRelation = [self.item.petitionObject relationforKey:@"votesNo"];
    
    if (agree){
        [yesRelation addObject:[PFUser currentUser]];
        [noRelation removeObject:[PFUser currentUser]];
    }else{
        [noRelation addObject:[PFUser currentUser]];
        [yesRelation removeObject:[PFUser currentUser]];
    }
    
    [self.item.petitionObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [weakSelf enableUI:YES];
        [weakSelf updateUI];
    }];
}

-(void)updateUI
{
    PFRelation *votesYes = [self.item.petitionObject relationforKey:@"votesYes"];
    [[votesYes query] countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        [buttonAgree setTitle:[NSString stringWithFormat:@"Yes: %i", number] forState:UIControlStateNormal];
    }];
    PFRelation *votesNo = [self.item.petitionObject relationforKey:@"votesNo"];
    [[votesNo query] countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        [buttonDisagree setTitle:[NSString stringWithFormat:@"No: %i", number] forState:UIControlStateNormal];
    }];
    
    [UIView performWithoutAnimation:^{
        [buttonAgree setEnabled:YES];
        [buttonDisagree setEnabled:YES];
        [buttonDiscuss setEnabled:YES];
    }];
    
}

- (IBAction)discuss:(id)sender {
    __weak UGPollCell *weakSelf = self;

    [UGRecordViewController recordVideoCompletion:^(UGVideo *video) {
        PFRelation *discussions = [weakSelf.item.petitionObject relationforKey:@"discussions"];
        [discussions addObject:video.object];
        [weakSelf.item.petitionObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
        }];
    }];
}
- (IBAction)viewDiscussion:(id)sender {
    
    UGPollResultsViewController *results = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"pollResultsVC"];
    results.item = self.item;
    [[UGTabBarController tabBarController] pushViewController:results];
    
    /*
    UGFilterViewController *filtered = [UGFilterViewController findItemsWithQueryBlock:^PFQuery *{
        PFRelation *discussions = [self.item.petitionObject relationforKey:@"discussions"];
        
        PFQuery *videos = [discussions query];
        [videos includeKey:@"user"];
        [videos orderByAscending:@"createdAt"];
        
        return videos;
    } searchText:@""];
    filtered.title = @"Discussions"; */
}

-(void)viewArticle
{
    UGLiveViewController *liveVC = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"liveVC"];
    liveVC.url = [NSURL URLWithString:self.item.link];
    liveVC.title = self.item.title;
    [[UGTabBarController tabBarController] pushViewController:liveVC];
}

-(void)enableUI:(BOOL)enable
{
    [buttonAgree setEnabled:enable];
    [buttonDisagree setEnabled:enable];
    [buttonDiscuss setEnabled:enable];
    
    UICollectionView *cv = (UICollectionView *)self.superview;
    [cv setUserInteractionEnabled:enable];
}

@end
