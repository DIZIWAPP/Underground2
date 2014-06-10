//
//  UGArticleCell.h
//  Sportsbuddyz
//
//  Created by Jon Como on 4/3/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MWFeedItem;

@interface UGArticleCell : UICollectionViewCell

@property (nonatomic, weak) MWFeedItem *item;

@end