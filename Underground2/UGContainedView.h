//
//  UGContainedView.h
//  Sportsbuddyz
//
//  Created by Jon Como on 4/24/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UGContainedView;

@protocol UGContainedViewDelegate <NSObject>

-(void)containedViewInteracted:(UGContainedView *)containedView;

@end

@interface UGContainedView : UIView

@property (nonatomic, weak) id<UGContainedViewDelegate> delegate;

@property (nonatomic, strong) UICollectionView *collectionViewFiles;

@property CGRect startRect;

-(void)showTitle:(NSString *)title;

-(void)refresh;

@end