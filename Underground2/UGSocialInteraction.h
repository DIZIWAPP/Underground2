//
//  UGSocialInteraction.h
//  Sportsbuddyz
//
//  Created by Jon Como on 2/28/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UGInteractionType @"type"

#define UGInteractionReply @"reply"
#define UGInteractionLike @"like"
#define UGInteractionShare @"share"

@class PFUser;
@class PFObject;

@interface UGSocialInteraction : NSObject

+(void)saveInteractionUsers:(PFUser *)userPrimary video:(PFObject *)video gotReply:(PFObject *)reply fromUser:(PFUser *)userSecondary;
+(void)saveInteractionUsers:(PFUser *)userPrimary video:(PFObject *)video gotLikedByUser:(PFUser *)userSecondary;

+(void)saveInteractionUser:(PFUser *)userSecondary sharedVideo:(PFObject *)video toUser:(PFUser *)userPrimary;

+(void)findInteractionsCompletion:(void(^)(NSArray *objects))block;

@end