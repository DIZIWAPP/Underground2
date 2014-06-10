//
//  JCParseManager.h
//  Underground
//
//  Created by Jon Como on 5/9/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompletionBlock)(BOOL success);

@class PFObject;
@class PFUser;

@interface JCParseManager : NSObject

@property (nonatomic, strong) NSDateFormatter *formatter;

+(JCParseManager *)sharedManager;

-(void)registerAnonymousUserCompletion:(CompletionBlock)block;
-(void)setDeviceOwnerWithToken:(NSData *)token;
-(NSString *)nameForObject:(PFObject *)object;
-(BOOL)userIsAnonymous:(PFUser *)user;

@end