//
//  UGPollCell.h
//  Underground2
//
//  Created by Jon Como on 6/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MWFeedItem;

@interface UGPollCell : UICollectionViewCell

@property (nonatomic, weak) MWFeedItem *item;

@end