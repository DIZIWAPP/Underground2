//
//  UGAccountViewController.h
//  UndergroundNetwork
//
//  Created by Jon Como on 5/14/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFUser;

@interface UGAccountViewController : UIViewController

@property (nonatomic, strong) PFUser *user;
@property BOOL isMainAccount;

+(UGAccountViewController *)presentAccountViewControllerForUser:(PFUser *)user;

@end