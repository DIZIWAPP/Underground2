//
//  UGCurrentUser.m
//  Sportsbuddyz
//
//  Created by Jon Como on 2/20/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGCurrentUser.h"

#import <Parse/Parse.h>
#import "UGVideo.h"

#import "UGRSSManager.h"

#import "UGSocialInteraction.h"

@implementation UGCurrentUser

+(UGCurrentUser *)user
{
    static UGCurrentUser *user;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        user = [[self alloc] init];
    });
    
    return user;
}

-(id)init
{
    if (self = [super init]) {
        //init
        {
            
        }
    }
    
    return self;
}

-(void)refreshCompletion:(void (^)(void))block
{
    if (!self.feed)
        self.feed = [NSMutableArray array];
    [self.feed removeAllObjects];
    
    [self.feed removeAllObjects];
    [self findFeedCompletion:block];
}

-(void)findFeedCompletion:(void(^)(void))block
{
    if (![PFUser currentUser]){
        if (block) block();
        return;
    }
    
    [self findFollowedTags:^{
        [self findFollowedUsersVideos:^{
            //sort and display
            
            self.feed = [[self.feed sortedArrayWithOptions:0 usingComparator:^NSComparisonResult(id obj1, id obj2) {
                UGVideo *vid1 = obj1;
                UGVideo *vid2 = obj2;
                
                return [vid2.object.createdAt compare:vid1.object.createdAt];
                
            }] mutableCopy];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) block();
            });
        }];
    }];
}

-(void)findFollowedTags:(void(^)(void))block
{
    PFRelation *userTags = [[PFUser currentUser] relationforKey:@"tagsFollowing"];
    
    PFQuery *videosWithTags = [PFQuery queryWithClassName:@"File"];
    
    [videosWithTags whereKey:@"tags" matchesQuery:[userTags query]];
    
    [videosWithTags addDescendingOrder:@"createdAt"];
    
    [videosWithTags includeKey:@"user"];
    
    [videosWithTags setLimit:100];
    
    [videosWithTags findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error){
                if (block) block();
                
                return;
            }
            
            for (PFObject *file in objects){
                UGVideo *video = [[UGVideo alloc] initWithObject:file];
                [self.feed addObject:video];
            }
            
            if (block) block();
        });
    }];
}

-(void)findFollowedUsersVideos:(void(^)(void))block
{
    PFRelation *relation = [[PFUser currentUser] relationforKey:@"usersFollowing"];
    PFQuery *following = [relation query];
    
    PFQuery *vidQuery = [PFQuery queryWithClassName:@"File"];
    
    [vidQuery whereKey:@"user" matchesQuery:following];
    
    [vidQuery addDescendingOrder:@"createdAt"];
    [vidQuery includeKey:@"user"];
    [vidQuery whereKey:@"isReply" notEqualTo:@(YES)];
    
    [vidQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            if (block) block();
            
            return;
        }
        
        for (PFObject *file in objects){
            UGVideo *video = [[UGVideo alloc] initWithObject:file];
            [self.feed addObject:video];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block();
        });
    }];
}

-(void)isObjectLiked:(PFObject *)object completion:(void (^)(BOOL isFollowing))block
{
    PFRelation *likes = [[PFUser currentUser] relationforKey:@"likes"];
    PFQuery *query = [likes query];
    
    [query whereKey:@"objectId" equalTo:object.objectId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count > 0 && !error){
            if (block) block(YES);
        }else{
            if (block) block(NO);
        }
    }];
}

-(void)toggleLikeObject:(PFObject *)object completion:(LikeHandler)block
{
    PFRelation *likes = [[PFUser currentUser] relationforKey:@"likes"];
    
    [self isObjectLiked:object completion:^(BOOL isLiked) {
        if (isLiked)
        {
            [likes removeObject:object];
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (block) block(NO);
                });
            }];
            
            [object incrementKey:@"likes" byAmount:@(-1)];
            [object saveInBackground];
        }else{
            [likes addObject:object];
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (block) block(YES);
                });
            }];
            
            [UGSocialInteraction saveInteractionUsers:object[@"user"] video:object gotLikedByUser:[PFUser currentUser]];
            
            [object incrementKey:@"likes" byAmount:@(1)];
            [object saveInBackground];
        }
    }];
}

-(void)toggleFollowUser:(PFUser *)user completion:(FollowHandler)block
{
    PFRelation *followedUsers = [[PFUser currentUser] relationforKey:@"usersFollowing"];
    
    [self isFollowingUser:user completion:^(BOOL isFollowing) {
        if (isFollowing)
        {
            [followedUsers removeObject:user];
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (block) block(NO);
                });
            }];
        }else{
            [followedUsers addObject:user];
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (block) block(YES);
                });
            }];
        }
    }];
}

-(void)isFollowingUser:(PFUser *)user completion:(FollowHandler)block
{
    PFRelation *followedUsers = [[PFUser currentUser] relationforKey:@"usersFollowing"];
    
    PFQuery *followedQuery = [followedUsers query];
    [followedQuery whereKey:@"objectId" equalTo:user.objectId];
    
    [followedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (objects.count > 0 && !error)
            {
                if (block) block(YES);
            }else{
                if (block) block(NO);
            }
        });
    }];
}

-(PFQuery *)followersQueryForUser:(PFUser *)user
{
    PFQuery *query = [PFUser query];
    
    [query whereKey:@"usersFollowing" equalTo:user];
    
    [query includeKey:@"user"];
    [query orderByDescending:@"username"];
    
    return query;
}

-(PFQuery *)followingQueryForUser:(PFUser *)user
{
    PFRelation *followingRelation = [user relationforKey:@"usersFollowing"];
    PFQuery *followingQuery = [followingRelation query];
    [followingQuery includeKey:@"user"];
    [followingQuery orderByDescending:@"username"];
    return followingQuery;
}

@end