//
//  JCTransferObject.h
//  UndergroundNetwork
//
//  Created by Jon Como on 6/5/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCTransferObject : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSData *data;

-(id)initWithFilename:(NSString *)fileName data:(NSData *)fileData;

@end
