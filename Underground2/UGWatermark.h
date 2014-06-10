//
//  UGWatermark.h
//  undergroundNetwork
//
//  Created by Jon Como on 7/11/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RenderComplete)(NSURL *watermarkedURL);

@interface UGWatermark : NSObject

-(void)performWithText:(NSString *)text inVideoAtURL:(NSURL *)videoURL completion:(RenderComplete)block;

@end
