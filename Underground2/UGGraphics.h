//
//  UGGraphics.h
//  UndergroundNetwork
//
//  Created by Jon Como on 5/9/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UGGraphics : NSObject

+(void)initGraphics;

+(void)button:(UIButton *)button;
+(void)buttonDone:(UIButton *)button;
+(void)buttonRecord:(UIButton *)button;
+(void)barButtonWarning:(UIBarButtonItem *)buttonItem;
+(void)barButtonDone:(UIBarButtonItem *)buttonItem;
+(void)noiseImageView:(UIImageView *)imageView;

@end
