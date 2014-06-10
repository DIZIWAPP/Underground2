//
//  UGRSSPreviewViewController.h
//  Sportsbuddyz
//
//  Created by Jon Como on 5/2/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UGRSSPreviewViewController : UIViewController

@property BOOL isSubbed;
@property (nonatomic, weak) NSDictionary *group;
@property (nonatomic, strong) NSArray *items;

@end
