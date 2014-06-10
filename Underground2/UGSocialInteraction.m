//
//  UGSocialInteraction.m
//  Sportsbuddyz
//
//  Created by Jon Como on 2/28/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGSocialInteraction.h"

#import <Parse/Parse.h>

#import "UGPush.h"

#import "UGCurrentUser.h"

@implementation UGSocialInteraction

+(void)saveInteractionUsers:(PFUser *)userPrimary video:(PFObject *)video gotReply:(PFObject *)reply fromUser:(PFUser *)userSecondary
{
    PFObject *interaction = [PFObject objectWithClassName:@"Interaction"];
    
    [interaction setObject:userPrimary forKey:@"userPrimary"];
    [interaction setObject:userSecondary forKey:@"userSecondary"];
    
    [interaction setObject:video forKey:@"video"];
    [interaction setObject:reply forKey:@"reply"];
    
    [interaction setObject:UGInteractionReply forKey:UGInteractionType];
    
    [interaction saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) return;
        
        [[UGPush manager] sendPushToUser:userPrimary message:[NSString stringWithFormat:@"%@ replied to your video!", userSecondary.username] action:UGPushActionSocial];
    }];
    
    /*
    //Make sure its unique
    PFQuery *query = [PFQuery queryWithClassName:@"Interaction"];
    
    [query whereKey:@"userPrimary" equalTo:userPrimary];
    [query whereKey:@"userSecondary" equalTo:userSecondary];
    [query whereKey:@"video" equalTo:video];
    [query whereKey:@"reply" equalTo:reply];
    [query whereKey:UGInteractionType equalTo:UGInteractionReply];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count == 0 && !error){
            [interaction saveInBackground];
        }
    }]; */
}

+(void)saveInteractionUsers:(PFUser *)userPrimary video:(PFObject *)video gotLikedByUser:(PFUser *)userSecondary
{
    PFObject *interaction = [PFObject objectWithClassName:@"Interaction"];
    
    [interaction setObject:userPrimary forKey:@"userPrimary"];
    [interaction setObject:userSecondary forKey:@"userSecondary"];
    
    [interaction setObject:video forKey:@"video"];
    
    [interaction setObject:UGInteractionLike forKey:UGInteractionType];
    
    //Make sure its unique
    PFQuery *query = [PFQuery queryWithClassName:@"Interaction"];
    
    [query whereKey:@"userPrimary" equalTo:userPrimary];
    [query whereKey:@"userSecondary" equalTo:userSecondary];
    [query whereKey:@"video" equalTo:video];
    [query whereKey:UGInteractionType equalTo:UGInteractionLike];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count == 0 && !error)
        {
            [interaction saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) return;
                
                [[UGPush manager] sendPushToUser:userPrimary message:[NSString stringWithFormat:@"%@ liked your video!", userSecondary.username] action:UGPushActionSocial];
            }];
        }
    }];
}

+(void)saveInteractionUser:(PFUser *)userSecondary sharedVideo:(PFObject *)video toUser:(PFUser *)userPrimary
{
    PFObject *interaction = [PFObject objectWithClassName:@"Interaction"];
    
    [interaction setObject:userPrimary forKey:@"userPrimary"];
    [interaction setObject:userSecondary forKey:@"userSecondary"];
    
    [interaction setObject:video forKey:@"video"];
    
    [interaction setObject:UGInteractionShare forKey:UGInteractionType];
    
    [interaction saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) return;
        
        [[UGPush manager] sendPushToUser:userPrimary message:[NSString stringWithFormat:@"%@ sent a video to you!", userSecondary.username] action:UGPushActionSocial];
    }];
}

+(void)findInteractionsCompletion:(void (^)(NSArray *objects))block
{
    PFQuery *query = [PFQuery queryWithClassName:@"Interaction"];
    
    [query whereKey:@"userPrimary" equalTo:[PFUser currentUser]];
    
    [query addDescendingOrder:@"createdAt"];
    
    [query includeKey:@"userPrimary"];
    [query includeKey:@"userSecondary"];
    
    [query includeKey:@"video"];
    [query includeKey:@"reply"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error){
                if (block) block(nil);
                return;
            }
            
            NSMutableArray *filtered = [NSMutableArray array]; //Remove interactions with missing keys
            for (PFObject *interaction in objects)
            {
                if ([interaction[UGInteractionType] isEqualToString:UGInteractionReply]){
                    if (!interaction[@"reply"]) continue;
                }
                
                if ([interaction[UGInteractionType] isEqualToString:UGInteractionLike]){
                    if (!interaction[@"video"]) continue;
                }
                
                [filtered addObject:interaction];
            }
            
            if (block) block(filtered);
        });
    }];
}

@end