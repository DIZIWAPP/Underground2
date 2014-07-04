//
//  UGVideosView.h
//  Underground2
//
//  Created by Jon Como on 7/3/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGContainedView.h"

typedef PFQuery *(^Query)(void);

@interface UGVideosView : UGContainedView

@property (nonatomic, copy) Query query;

-(void)refreshCompletion:(void(^)(NSArray *videos))block;

@end