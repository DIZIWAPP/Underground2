//
//  UGArticleCell.m
//  Sportsbuddyz
//
//  Created by Jon Como on 4/3/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGArticleCell.h"

#import "MWFeedItem.h"
#import "TTTTimeIntervalFormatter.h"


@implementation UGArticleCell
{
    __weak IBOutlet UILabel *labelTitle;
    __weak IBOutlet UILabel *labelTime;
    __weak IBOutlet UIImageView *imageViewThumb;
    UILabel *replyCountLabel;
    
    UIWebView *webViewInformation;
    UILabel *source;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    
    return self;
}

-(void)setItem:(MWFeedItem *)item
{
    _item = item;
    
    labelTitle.text = item.title;
    
    //labelSummary.text = item.summary;
    [webViewInformation stopLoading];
    webViewInformation = nil;
    [webViewInformation removeFromSuperview];
    
    webViewInformation = [[UIWebView alloc] initWithFrame:CGRectMake(0, 75, 320, self.frame.size.height - 75)];
    [self.contentView addSubview:webViewInformation];
    
    [webViewInformation loadData:[item.summary dataUsingEncoding:NSUTF8StringEncoding] MIMEType:nil textEncodingName:nil baseURL:nil];
    
    [webViewInformation setUserInteractionEnabled:NO];
    
    labelTime.text = [[TTTTimeIntervalFormatter shared] stringForTimeIntervalFromDate:[NSDate date] toDate:item.date];
    
    [replyCountLabel removeFromSuperview];
    
    if (!source){
        source = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 320, 26)];
        source.backgroundColor = [UIColor whiteColor];
        source.font = [UIFont fontWithName:@"AvenirNext-Bold" size:14];
        source.textColor = [UIColor redColor];
        source.minimumScaleFactor = 1;
        source.numberOfLines = 1;
        [self.contentView addSubview:source];
    }
    
    NSArray *components = [item.link componentsSeparatedByString:@"/"];
    
    NSString *firstCompoents = [NSString stringWithFormat:@"%@%@", components[1] , components[2]];
    source.text = [NSString stringWithFormat:@" %@", firstCompoents];
    
    if (item.numReplies == 0 && item.link)
    {
        PFQuery *query = [PFQuery queryWithClassName:@"File"];
        
        [query whereKey:@"newsURL" equalTo:item.link];
        
        [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (error) return;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (number > 0){
                    item.numReplies = number;
                    [self showReplyCount:item.numReplies];
                }
            });
        }];
    }else{
        [self showReplyCount:item.numReplies];
    }
}

-(void)showReplyCount:(int)count
{
    [replyCountLabel removeFromSuperview];
    replyCountLabel = nil;
    
    replyCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 44, self.frame.size.width, 44)];
    [self.contentView addSubview:replyCountLabel];
    replyCountLabel.text = [NSString stringWithFormat:@"%i Repl%@", count, count == 1 ? @"y" : @"ies"];
    [replyCountLabel setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:20]];
    replyCountLabel.textColor = [UIColor redColor];
    replyCountLabel.textAlignment = NSTextAlignmentCenter;
    replyCountLabel.backgroundColor = [UIColor whiteColor];
}

@end