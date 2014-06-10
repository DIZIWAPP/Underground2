//
//  JCQuoteManager.h
//  UndergroundNetwork
//
//  Created by Jon Como on 5/16/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompletionQuote)(NSString *quoteText, NSString *quoteAuthor);

@interface JCQuoteManager : NSObject

+(JCQuoteManager *)sharedManager;

-(void)startReceivingQuotesWithTimeInterval:(NSTimeInterval)timeInterval block:(CompletionQuote)block;

-(void)startQuotes;
-(void)stopQuotes;

@end
