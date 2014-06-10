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

@implementation UGPollCell
{
    __weak IBOutlet UILabel *name;
    __weak IBOutlet UITextView *detail;
    __weak IBOutlet UIButton *buttonAgree;
    __weak IBOutlet UIButton *buttonDiscuss;
    __weak IBOutlet UIButton *buttonDisagree;
    __weak IBOutlet UILabel *labelTime;
}

-(void)setObject:(PFObject *)object
{
    _object = object;
    
    name.text = object[@"name"];
    detail.text = object[@"details"];
    
    labelTime.text = [[TTTTimeIntervalFormatter shared] stringForTimeIntervalFromDate:[NSDate date] toDate:self.object.createdAt];
    
    [self updateUI];
    
    
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
    
    PFRelation *yesRelation = [self.object relationforKey:@"votesYes"];
    PFRelation *noRelation = [self.object relationforKey:@"votesNo"];
    
    if (agree)
    {
        [yesRelation addObject:[PFUser currentUser]];
        [noRelation removeObject:[PFUser currentUser]];
    }else{
        [noRelation addObject:[PFUser currentUser]];
        [yesRelation removeObject:[PFUser currentUser]];
    }
    
    [self.object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [weakSelf enableUI:YES];
        [weakSelf updateUI];
    }];
}

-(void)updateUI
{
    PFRelation *votesYes = [self.object relationforKey:@"votesYes"];
    [[votesYes query] countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        [buttonAgree setTitle:[NSString stringWithFormat:@"Yes: %i", number] forState:UIControlStateNormal];
    }];
    PFRelation *votesNo = [self.object relationforKey:@"votesNo"];
    [[votesNo query] countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        [buttonDisagree setTitle:[NSString stringWithFormat:@"No: %i", number] forState:UIControlStateNormal];
    }];
}

- (IBAction)discuss:(id)sender {
    __weak UGPollCell *weakSelf = self;

    [UGRecordViewController recordVideoCompletion:^(UGVideo *video) {
        PFRelation *discussions = [self.object relationforKey:@"discussions"];
        [discussions addObject:video.object];
        [weakSelf.object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
        }];
    }];
}
- (IBAction)viewDiscussion:(id)sender {
    UGFilterViewController *filtered = [UGFilterViewController findItemsWithQueryBlock:^PFQuery *{
        PFRelation *discussions = [self.object relationforKey:@"discussions"];
        
        PFQuery *videos = [discussions query];
        [videos includeKey:@"user"];
        [videos orderByAscending:@"createdAt"];
        
        return videos;
    } searchText:@""];
    filtered.title = @"Discussions";
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
