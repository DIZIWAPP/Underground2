//
//  UGRSSManager.h
//  Sportsbuddyz
//
//  Created by Jon Como on 4/3/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MWFeedParser.h"

typedef void (^ParseProgress)(float progress);
typedef void (^FoundItemsHandler)(NSArray *items);

@interface UGRSSManager : NSObject

+(UGRSSManager *)sharedManager;

-(void)parseURLs:(NSArray *)urls completion:(void(^)(NSArray *items))block;
-(void)findRSSItemsProgress:(ParseProgress)progress completion:(FoundItemsHandler)block;

@end