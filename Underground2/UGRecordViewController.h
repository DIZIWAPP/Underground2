//
//  UGRecordViewController.h
//  undergroundNetwork
//
//  Created by Jon Como on 8/27/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UGVideo;

typedef void (^RecordHandler)(UGVideo *video);

@interface UGRecordViewController : UIViewController

+(UGRecordViewController *)recordVideoCompletion:(RecordHandler)block;

+(RecordHandler)handler;

@end