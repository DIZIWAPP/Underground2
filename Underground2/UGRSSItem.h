//
//  UGRSSItem.h
//  Sportsbuddyz
//
//  Created by Jon Como on 4/8/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFObject;

@interface UGRSSItem : NSObject

@property BOOL isSubscribed;

@property (nonatomic, strong) PFObject *item;

-(id)initWithItem:(PFObject *)item;

@end
