//
//  UGEditTagsViewController.h
//  Sportsbuddyz
//
//  Created by Jon Como on 2/13/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFUser;

@interface UGTagsViewController : UIViewController

+(UGTagsViewController *)presentTagsForUser:(PFUser *)user;

@property (nonatomic, strong) PFUser *user;

@end
