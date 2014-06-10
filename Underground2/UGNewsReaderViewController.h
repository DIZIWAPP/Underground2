//
//  UGNewsReaderViewController.h
//  Sportsbuddyz
//
//  Created by Jon Como on 4/7/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MWFeedItem;

@interface UGNewsReaderViewController : UIViewController

+(UGNewsReaderViewController *)presentNewsReaderViewControllerWithURL:(NSURL *)url;

@property (nonatomic, strong) NSURL *webURL;

@end