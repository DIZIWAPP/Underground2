//
//  UGRSSItem.m
//  Sportsbuddyz
//
//  Created by Jon Como on 4/8/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGRSSItem.h"

@implementation UGRSSItem

-(id)initWithItem:(PFObject *)item
{
    if (self = [super init]) {
        //init
        _item = item;
        
        
    }
    
    return self;
}

@end
