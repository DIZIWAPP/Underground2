//
//  UGThumbView.h
//  Sportsbuddyz
//
//  Created by Jon Como on 3/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFQuery;

typedef PFQuery *(^QueryBlock)(void);
typedef void (^SelectedData)(id data);

@interface UGThumbView : UIView

@property (nonatomic, strong) QueryBlock queryBlock;
@property (nonatomic, strong) SelectedData selectedData;

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

-(void)refresh;

@end