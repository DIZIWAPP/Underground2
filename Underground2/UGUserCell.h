//
//  UGUserCell.h
//  Sportsbuddyz
//
//  Created by Jon Como on 3/17/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    UGUserCellTypeFollow,
    UGUserCellTypeShare
} UGUserCellType;

@class PFUser;

@interface UGUserCell : UICollectionViewCell

@property (nonatomic, assign) UGUserCellType type;

@property (nonatomic, weak) PFUser *user;
@property (nonatomic, assign) BOOL isSelected;

@end