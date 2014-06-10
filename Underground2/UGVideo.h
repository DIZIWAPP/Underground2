//
//  UGVideo.h
//  undergroundNetwork
//
//  Created by Jon Como on 8/23/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFObject;
@class UGVideoViewController;
@class MWFeedItem;

typedef void (^ReplyBlock)(NSMutableArray *replies);

@interface UGVideo : NSObject

@property (nonatomic, strong) PFObject *object;
@property (nonatomic, strong) NSURL *URL;
@property BOOL isLiked;

//While in a collection
@property int indentLevel;

@property (nonatomic, strong) NSMutableArray *replies;

-(id)initWithObject:(PFObject *)videoObject;

-(void)getTags:(void(^)(NSMutableArray *tags))block;
-(void)getReplies:(ReplyBlock)block;
-(void)getRepliesCount:(void(^)(BOOL success, int count))block;

-(void)saveAsReplyToVideo:(PFObject *)parent completion:(void(^)(BOOL success))block;
-(void)saveAsReplyToNewsURL:(NSString *)url title:(NSString *)title completion:(void (^)(BOOL))block;

-(UGVideoViewController *)playInVideoViewController;

-(CGSize)sizeForCollection;

@end