//
//  UGVideo.m
//  undergroundNetwork
//
//  Created by Jon Como on 8/23/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "UGVideo.h"
#import <Parse/Parse.h>
#import "UGCurrentUser.h"

#import "UGVideoViewController.h"
#import "UGTabBarController.h"

#import "MWFeedItem.h"

@implementation UGVideo
{
    NSMutableArray *tags;
    
    ReplyBlock _replyBlock;
    
    __block int repliesLoading;
}

-(id)initWithObject:(PFObject *)videoObject
{
    if (self = [super init]) {
        //init
        _object = videoObject;
        
        _indentLevel = 0;
        _URL = [NSURL URLWithString:[_object[@"URL"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return self;
}

-(UGVideoViewController *)playInVideoViewController
{
    UGVideoViewController *videoVC = [[UGVideoViewController alloc] init];
    
    videoVC.video = self;
    
    [[UGTabBarController tabBarController] pushViewController:videoVC];
    
    return videoVC;
}

-(void)getTags:(void (^)(NSMutableArray *tags))block
{
    if (tags){
        if (block) block(tags);
        return;
    }
    
    //cached otherwise search
    
    PFRelation *tagRelation = [self.object relationforKey:@"tags"];
    
    PFQuery *findTags = [tagRelation query];
    
    [findTags findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            if (block) block(nil);
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            tags = [objects mutableCopy];
            if (block) block(tags);
        });
    }];
}

-(void)getReplies:(void (^)(NSMutableArray *replies))block
{
    PFRelation *repliesRelation = [self.object relationforKey:@"replies"];
    
    PFQuery *findReplies = [repliesRelation query];
    
    [findReplies includeKey:@"user"];
    [findReplies orderByAscending:@"createdAt"];
    
    [findReplies findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            if (block) block(nil);
            return;
        }
        
        if (!self.replies) self.replies = [NSMutableArray array];
        [self.replies removeAllObjects];
        
        if (objects.count == 0)
        {
            if (block) block(nil);
            return;
        }
        
        for (PFObject *object in objects){
            UGVideo *reply = [[UGVideo alloc] initWithObject:object];
            reply.indentLevel = self.indentLevel + 1;
            [self.replies addObject:reply];
        }
        
        repliesLoading = objects.count;
        
        for (UGVideo *reply in self.replies)
        {
            [reply getReplies:^(NSMutableArray *replies) {
                repliesLoading --;
                
                if (repliesLoading == 0)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (block) block(self.replies);
                    });
                }
            }];
        }
    }];
}

-(void)getRepliesCount:(void (^)(BOOL success, int count))block
{
    PFRelation *repliesRelation = [self.object relationforKey:@"replies"];
    
    PFQuery *repliesQuery = [repliesRelation query];

    [repliesQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (error){
            if (block) block(NO, 0);
            return;
        }
        
        if (block) block(YES, number);
    }];
}

-(void)saveAsReplyToVideo:(PFObject *)parent completion:(void (^)(BOOL))block
{
    [self.object setObject:@(YES) forKey:@"isReply"];
    [self.object setObject:parent forKey:@"parent"];
    
    PFRelation *replies = [parent relationforKey:@"replies"];
    [replies addObject:self.object];
    
    [self.object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded){
            if (block) block(NO);
            return;
        }
        
        [parent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (block) block(succeeded);
        }];
    }];
}

-(void)saveAsReplyToNewsURL:(NSString *)url title:(NSString *)title completion:(void (^)(BOOL))block
{
    //[self.object setObject:@(YES) forKey:@"isReply"];
    
    [self.object setObject:title forKey:@"newsTitle"];
    [self.object setObject:url forKey:@"newsURL"];
    
    [self.object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded){
            if (block) block(NO);
            return;
        }
        
        if (block) block(succeeded);
    }];
}

-(CGSize)sizeForCollection
{
    if (self.object[@"newsURL"])
    {
        return CGSizeMake(300, 130 + 60);
    }else{
        return CGSizeMake(300, 130);
    }
}

@end