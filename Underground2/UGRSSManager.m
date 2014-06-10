//
//  UGRSSManager.m
//  Sportsbuddyz
//
//  Created by Jon Como on 4/3/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGRSSManager.h"

#import <Parse/Parse.h>

@interface UGRSSManager () <MWFeedParserDelegate>

@end

@implementation UGRSSManager
{
    MWFeedParser *feedParser;
    
    NSMutableArray *parsedItems;
    FoundItemsHandler _feedHandler;
    ParseProgress _progress;
    
    NSMutableArray *subscribedURLs;
    
    int totalItemsCount;
    int parsedItemsCount;
}

+(UGRSSManager *)sharedManager
{
    static UGRSSManager *sharedManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

-(void)parseURLs:(NSArray *)urls completion:(void(^)(NSArray *items))block
{
    _feedHandler = block;
    if (!parsedItems) parsedItems = [NSMutableArray array];
    [parsedItems removeAllObjects];
    
    if (!subscribedURLs) subscribedURLs = [NSMutableArray array];
    [subscribedURLs removeAllObjects];
    
    subscribedURLs = [urls mutableCopy];
    
    [self parseNextFeedURL];
}

-(void)findRSSItemsProgress:(ParseProgress)progress completion:(FoundItemsHandler)block
{
    _feedHandler = block;
    _progress = progress;
    
    if (!parsedItems) parsedItems = [NSMutableArray array];
    [parsedItems removeAllObjects];
    
    if (!subscribedURLs) subscribedURLs = [NSMutableArray array];
    [subscribedURLs removeAllObjects];
    
    PFQuery *query = [[[PFUser currentUser] relationforKey:@"subscriptions"] query];
    
    parsedItemsCount = 0;
    totalItemsCount = 0;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            block(nil);
        }
        
        for (PFObject *rssItem in objects)
        {
            NSURL *url = [NSURL URLWithString:rssItem[@"xmlUrl"]];
            [subscribedURLs addObject:url];
            totalItemsCount ++;
        }
        
        [self parseNextFeedURL];
    }];
    
    //subscribedURLs = [@[[NSURL URLWithString:@"http://techcrunch.com/feed/"], [NSURL URLWithString:@"http://www.torontosun.com/sports/hockey/mapleleafs/rss.xml"]] mutableCopy];
}

-(void)parseNextFeedURL
{
    if (subscribedURLs.count <= 0) {
        //Complete
        if (_feedHandler) _feedHandler(parsedItems);
        return;
    }
    
    NSURL *feedURL = [subscribedURLs lastObject];
    [subscribedURLs removeLastObject];
    
    feedParser = [[MWFeedParser alloc] initWithFeedURL:feedURL];
	feedParser.delegate = self;
	feedParser.feedParseType = ParseTypeFull; // Parse feed info and all items
	feedParser.connectionType = ConnectionTypeAsynchronously;
	
    [feedParser parse];
}

#pragma mark -
#pragma mark MWFeedParserDelegate

- (void)feedParserDidStart:(MWFeedParser *)parser {
	//NSLog(@"Started Parsing: %@", parser.url);
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info {
    parsedItemsCount ++;
    
    if (_progress) _progress((float)parsedItemsCount/(float)totalItemsCount);
	//self.title = info.title;
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item {
	if (item) [parsedItems addObject:item];
}

- (void)feedParserDidFinish:(MWFeedParser *)parser {
	//NSLog(@"Finished Parsing%@", (parser.stopped ? @" (Stopped)" : @""));
    
    [self parseNextFeedURL];
}

- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error {
	//NSLog(@"Finished Parsing With Error: %@", error);
    
    [self parseNextFeedURL];
}

@end