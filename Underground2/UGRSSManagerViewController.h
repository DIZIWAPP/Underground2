//
//  UGRSSManagerViewController.h
//  Sportsbuddyz
//
//  Created by Jon Como on 4/7/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ManageHandler)(void);

@interface UGRSSManagerViewController : UIViewController

@property (nonatomic, copy) ManageHandler manageBlock;

+(UGRSSManagerViewController *)presentRSSManagerViewControllerCompletion:(ManageHandler)block;

-(void)toggleSubscriptionToGroup:(NSDictionary *)group completion:(void(^)(BOOL subbed))block;

-(void)refresh;

@end