//
//  JCSegmentView.h
//  Sportsbuddyz
//
//  Created by Jon Como on 3/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^IndexChanged)(NSUInteger index);

@interface JCSegmentView : UIView

@property (nonatomic, strong) UISegmentedControl *segmentControl;
@property (nonatomic, strong) NSArray *views;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) IndexChanged indexChanged;

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items views:(NSArray *)views padding:(float)p;

@end