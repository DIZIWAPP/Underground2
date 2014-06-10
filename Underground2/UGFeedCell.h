//
//  UGFeedCell.h
//  Sportsbuddyz
//
//  Created by Jon Como on 5/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UGRSSManagerViewController.h"

@interface UGFeedCell : UICollectionViewCell

@property (nonatomic, weak) NSDictionary *rssGroup;

@property (nonatomic, weak) UGRSSManagerViewController *manager;

@end
