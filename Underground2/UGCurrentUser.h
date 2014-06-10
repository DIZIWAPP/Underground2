//
//  UGCurrentUser.h
//  Sportsbuddyz
//
//  Created by Jon Como on 2/20/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFObject;
@class PFUser;
@class PFQuery;

typedef void (^FollowHandler)(BOOL isFollowing);
typedef void (^LikeHandler)(BOOL isLiked);

@interface UGCurrentUser : NSObject

@property (nonatomic, strong) NSMutableArray *feed; //current users feed

@property (nonatomic, strong) NSMutableArray *likes;
@property (nonatomic, strong) NSMutableArray *tagsFollowing;

+(UGCurrentUser *)user;

-(void)refreshCompletion:(void(^)(void))block;

-(void)toggleFollowUser:(PFUser *)user completion:(FollowHandler)block;
-(void)isFollowingUser:(PFUser *)user completion:(FollowHandler)block;

-(void)toggleLikeObject:(PFObject *)object completion:(LikeHandler)block;
-(void)isObjectLiked:(PFObject *)object completion:(LikeHandler)block;

-(PFQuery *)followersQueryForUser:(PFUser *)user;
-(PFQuery *)followingQueryForUser:(PFUser *)user;

@end