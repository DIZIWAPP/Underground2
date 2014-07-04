//
//  UGMapView.h
//  Sportsbuddyz
//
//  Created by Jon Como on 3/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef PFQuery *(^Query)(void);

@interface UGMapView : UIView

@property (nonatomic, copy) Query query;

-(void)showAnnotationsForVideos:(NSArray *)videos;
-(void)refresh;

@end