//
//  UGVideoFeedView.h
//  Sportsbuddyz
//
//  Created by Jon Como on 4/24/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGContainedView.h"

@class PFUser;

@interface UGVideoFeedView : UGContainedView

@property (nonatomic, weak) PFUser *user;

@end