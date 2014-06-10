//
//  UGThumbCell.h
//  Sportsbuddyz
//
//  Created by Jon Como on 3/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UGVideo;
@class PFUser;

@interface UGThumbCell : UICollectionViewCell

@property (nonatomic, weak) UGVideo *video;
@property (nonatomic, weak) PFUser *user;

@end
