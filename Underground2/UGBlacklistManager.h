//
//  UGBlacklistManager.h
//  Underground
//
//  Created by Jon Como on 5/9/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UGBlacklistManager : NSObject

+(UGBlacklistManager *)sharedManager;
-(void)isBlacklisted:(void (^)(BOOL success, BOOL blacklisted))block;

@end