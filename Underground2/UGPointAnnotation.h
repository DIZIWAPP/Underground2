//
//  UGPointAnnotation.h
//  UndergroundNetwork
//
//  Created by Jon Como on 5/9/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <MapKit/MapKit.h>

@class UGVideo;

@interface UGPointAnnotation : MKPointAnnotation

@property (nonatomic, strong) UGVideo *video;

@end
