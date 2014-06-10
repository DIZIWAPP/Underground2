//
//  UGPush.h
//  Sportsbuddyz
//
//  Created by Jon Como on 2/28/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UGPushAction @"action"

#define UGPushActionNone @"none"
#define UGPushActionSocial @"social"

@class PFUser;

@interface UGPush : NSObject

+(UGPush *)manager;

-(void)sendPushToUser:(PFUser *)user message:(NSString *)message action:(NSString *)action;
-(void)handlePush:(NSDictionary *)push;

@end