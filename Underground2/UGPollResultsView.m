//
//  UGPollResultsView.m
//  Underground2
//
//  Created by Jon Como on 7/1/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGPollResultsView.h"

#import <MapKit/MapKit.h>

#import "UGRSSManager.h"
#import "MWFeedItem.h"

#import "UGVideoFeedView.h"

@implementation UGPollResultsView
{
    __weak IBOutlet MKMapView *mapVotes;
    __weak IBOutlet UIButton *buttonNo;
    __weak IBOutlet UIButton *buttonYes;
    
    __weak IBOutlet UILabel *title;
    
    UGVideoFeedView *videoDiscussions;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        //init
        [self loadLatest];
        
        videoDiscussions = [[UGVideoFeedView alloc] initWithFrame:CGRectMake(0, 200, 320, 200)];
        videoDiscussions.message = @"No Discussions";
        [self addSubview:videoDiscussions];
        
        [videoDiscussions removeRefresh];
    }
    
    return self;
}

-(void)loadLatest
{
    [[UGRSSManager sharedManager] parseURLs:@[[NSURL URLWithString:@"http://feeds.feedburner.com/undergroundnetwork"]] completion:^(NSArray *items) {
        
        NSLog(@"Loaded item");
        
        self.item = items[0];
        [self.item getObjectCompletion:^(PFObject *object) {
            [self updateUI];
            
            [videoDiscussions refreshWithQuery:^{
                PFRelation *discussions = [self.item.petitionObject relationforKey:@"discussions"];
                
                PFQuery *videos = [discussions query];
                [videos includeKey:@"user"];
                [videos orderByAscending:@"createdAt"];
                
                return videos;
            }];
        }];
    }];
}

-(void)updateUI
{
    title.text = self.item.title;
    
    PFRelation *votesYes = [self.item.petitionObject relationforKey:@"votesYes"];
    [[votesYes query] countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        [buttonYes setTitle:[NSString stringWithFormat:@"Yes: %i", number] forState:UIControlStateNormal];
    }];
    PFRelation *votesNo = [self.item.petitionObject relationforKey:@"votesNo"];
    [[votesNo query] countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        [buttonNo setTitle:[NSString stringWithFormat:@"No: %i", number] forState:UIControlStateNormal];
    }];
    
    [UIView performWithoutAnimation:^{
        [buttonYes setEnabled:YES];
        [buttonNo setEnabled:YES];
    }];
}

- (IBAction)agree:(id)sender {
    [self vote:YES];
}

- (IBAction)disagree:(id)sender {
    [self vote:NO];
}

-(void)vote:(BOOL)agree
{
    PFRelation *yesRelation = [self.item.petitionObject relationforKey:@"votesYes"];
    PFRelation *noRelation = [self.item.petitionObject relationforKey:@"votesNo"];
    
    if (agree)
    {
        [yesRelation addObject:[PFUser currentUser]];
        [noRelation removeObject:[PFUser currentUser]];
    }else{
        [noRelation addObject:[PFUser currentUser]];
        [yesRelation removeObject:[PFUser currentUser]];
    }
    
    [self.item.petitionObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self updateUI];
    }];
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
