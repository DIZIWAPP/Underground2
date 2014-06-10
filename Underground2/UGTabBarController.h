//
//  UGTabBarController.h
//  Sportsbuddyz
//
//  Created by Jon Como on 3/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UGTabBarController : UITabBarController

@property NSUInteger orientationMask;

+(UGTabBarController *)tabBarController;

-(void)pushViewController:(UIViewController *)viewController;

-(void)showLoginSignUp;

@end