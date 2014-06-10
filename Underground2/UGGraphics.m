//
//  UGGraphics.m
//  UndergroundNetwork
//
//  Created by Jon Como on 5/9/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "UGGraphics.h"

static NSMutableArray *noiseImages;

@implementation UGGraphics

+(void)initGraphics
{
    //[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    //[[UIBarButtonItem appearance] setBackgroundImage:[UGGraphics resizableImageWithName:@"buttonDark"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    //[[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"toolBar"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    //[[UIBarButtonItem appearance] setTitleTextAttributes:@{UITextAttributeFont : [UIFont fontWithName:@"AvenirNext-Bold" size:12]} forState:UIControlStateNormal];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Heavy" size:20]}];
    
//    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[UGGraphics resizableLargeImageWithName:@"buttonDark"]
//                                                      forState:UIControlStateNormal
//                                                    barMetrics:UIBarMetricsDefault];
}

+(void)button:(UIButton *)button
{
    [button setBackgroundImage:[UGGraphics resizableImageWithName:@"button"] forState:UIControlStateNormal];
}

+(void)buttonDone:(UIButton *)button
{
    UIImage *image = [UGGraphics resizableImageWithName:@"buttonDone"];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:image forState:UIControlStateHighlighted];
}

+(void)buttonRecord:(UIButton *)button
{
    UIImage *image = [UGGraphics resizableImageWithName:@"buttonRecording"];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:image forState:UIControlStateHighlighted];
}

+(void)barButtonWarning:(UIBarButtonItem *)buttonItem
{
    [buttonItem setBackgroundImage:[UGGraphics resizableImageWithName:@"buttonWarning"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

+(void)barButtonDone:(UIBarButtonItem *)buttonItem
{
    [buttonItem setBackgroundImage:[UGGraphics resizableImageWithName:@"buttonDone"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

+(UIImage *)resizableImageWithName:(NSString *)name
{
    return [[UIImage imageNamed:name] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
}

+(UIImage *)resizableLargeImageWithName:(NSString *)name
{
    return [[UIImage imageNamed:name] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
}

+(void)noiseImageView:(UIImageView *)imageView
{
    imageView.animationDuration = 1;
    imageView.animationImages = [UGGraphics noiseImageFrames];
    [imageView startAnimating];
}

+(NSMutableArray *)noiseImageFrames
{
    if (noiseImages) return noiseImages;
    
    noiseImages = [NSMutableArray array];
    
    for (int i = 0; i<22; i++)
    {
        NSString *imageName = [NSString stringWithFormat:@"noise_%05i.jpg", i];
        
        UIImage *frame = [[UIImage imageNamed:imageName] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile];
        
        if (frame)
            [noiseImages addObject:frame];
    }
    
    return noiseImages;
}

@end