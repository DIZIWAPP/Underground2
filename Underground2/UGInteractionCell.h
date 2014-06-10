//
//  UGInteractionCell.h
//  Sportsbuddyz
//
//  Created by Jon Como on 2/28/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFObject;

@interface UGInteractionCell : UICollectionViewCell

@property (nonatomic, weak) PFObject *interaction;

@end
