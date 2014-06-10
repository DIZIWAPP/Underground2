//
//  UGArticleFeedView.h
//  Sportsbuddyz
//
//  Created by Jon Como on 4/24/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGContainedView.h"

@interface UGArticleFeedView : UGContainedView

@property (nonatomic, strong) NSMutableArray *feed;

-(void)beginRefresh;
-(void)refreshWithItems:(NSArray *)items;

@end