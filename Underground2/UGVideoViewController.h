//
//  UGVideoViewController.h
//  undergroundNetwork
//
//  Created by Jon Como on 8/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UGVideo;
@class PFUser;

@interface UGVideoViewController : UIViewController

@property (nonatomic, strong) NSString *newsURL;

@property (nonatomic, weak) UGVideo *video;
@property (nonatomic, weak) PFUser *user;

@end