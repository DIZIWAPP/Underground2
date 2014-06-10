//
//  JCFileConverter.h
//  UndergroundNetwork
//
//  Created by Jon Como on 5/17/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompressionComplete)(NSURL *videoURL);

@interface JCFileConverter : NSObject

+(JCFileConverter *)sharedManager;
-(void)convertFileAtURL:(NSURL *)uncompressedURL completion:(CompressionComplete)block;

@end