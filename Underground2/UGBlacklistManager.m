//
//  UGBlacklistManager.m
//  Underground
//
//  Created by Jon Como on 5/9/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "UGBlacklistManager.h"

@implementation UGBlacklistManager

+(UGBlacklistManager *)sharedManager
{
    static UGBlacklistManager *sharedManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

-(void)isBlacklisted:(void (^)(BOOL success, BOOL blacklisted))block
{
    if (![PFUser currentUser])
    {
        if (block) block(NO, NO);
        return;
    }
    
    [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error){
            if (block) block(NO, YES);
            return;
        }
        
        PFUser *updatedUser = (PFUser *)object;
        
        if ([updatedUser[@"isBlacklisted"] boolValue]) {
            //blacklisted
            if (block) block(YES, YES);
        }else{
            //not blacklisted
            if (block) block(YES, NO);
        }
        
    }];
}

@end
