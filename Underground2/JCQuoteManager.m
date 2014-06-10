//
//  JCQuoteManager.m
//  UndergroundNetwork
//
//  Created by Jon Como on 5/16/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "JCQuoteManager.h"
#import "JCConnection.h"

@implementation JCQuoteManager
{
    CompletionQuote completionQuote;
    NSArray *quoteArray;
    NSDictionary *lastQuote;
    NSTimeInterval startedTimeInterval;
    NSTimer *showQuote;
}

+(JCQuoteManager *)sharedManager
{
    static JCQuoteManager *sharedManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

-(void)startReceivingQuotesWithTimeInterval:(NSTimeInterval)timeInterval block:(CompletionQuote)block
{
    completionQuote = block;
    startedTimeInterval = timeInterval;
    
    JCConnection *connection;
    connection = [[JCConnection alloc] initWithhRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://s3.amazonaws.com/media.underground.net/app/quotes.txt"]] completion:^(BOOL success, NSData *data) {
        
        if (success)
        {
            NSDictionary *quoteDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            quoteArray = quoteDict[@"quotes"];
            [self startQuotes];
            [self showQuote:nil];
        }
    }];
}

-(void)showQuote:(NSTimer *)timer
{
    NSDictionary *quote;
    
    do {
        quote = quoteArray[arc4random()%quoteArray.count];
    } while (quote == lastQuote);
    
    lastQuote = quote;
    
    if (completionQuote) completionQuote(quote[@"text"], quote[@"author"]);
}

-(void)startQuotes
{
    if (showQuote) return;
    showQuote = [NSTimer scheduledTimerWithTimeInterval:startedTimeInterval target:self selector:@selector(showQuote:) userInfo:nil repeats:YES];
}

-(void)stopQuotes
{
    [showQuote invalidate];
    showQuote = nil;
}

@end
