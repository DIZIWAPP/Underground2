//
//  JCConnection.h
//  MusicalMarket
//
//  Created by Jon Como on 10/14/12.
//  Copyright (c) 2012 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^block)(BOOL success, NSData *data);

@interface JCConnection : NSObject <NSURLConnectionDelegate>

-(id)initWithhRequest:(NSURLRequest *)request completion:(block)completionBlock;

@end