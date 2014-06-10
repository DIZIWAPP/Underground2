//
//  JCConnection.m
//  MusicalMarket
//
//  Created by Jon Como on 10/14/12.
//  Copyright (c) 2012 Jon Como. All rights reserved.
//

#import "JCConnection.h"

@interface JCConnection ()
{
    NSURLConnection *connection;
    NSMutableData *returnData;
    block callbackBlock;
}

@end

@implementation JCConnection

-(id)initWithhRequest:(NSURLRequest *)request completion:(block)completionBlock
{
    if (self = [super init]) {
        //Init
        callbackBlock = completionBlock;
        connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    }
    return self;
}

#pragma NSURLConnectin delegate

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response
{
    returnData = [[NSMutableData alloc] init];
}
- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    [returnData appendData:data];
}
- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    //failed
    callbackBlock(NO,nil);
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    callbackBlock(YES, returnData);
}


@end
