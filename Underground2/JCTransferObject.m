//
//  JCTransferObject.m
//  UndergroundNetwork
//
//  Created by Jon Como on 6/5/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "JCTransferObject.h"

@implementation JCTransferObject

-(id)initWithFilename:(NSString *)fileName data:(NSData *)fileData
{
    if (self = [super init]) {
        //init
        _name = fileName;
        _data = fileData;
    }
    
    return self;
}

@end
