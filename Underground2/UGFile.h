//
//  UGFile.h
//  UndergroundNetwork
//
//  Created by Jon Como on 5/9/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFGeoPoint;
@class CLPlacemark;
@class PFObject;

typedef enum
{
    kFileTypeImage,
    kFileTypeMovie
} kFileType;

typedef enum
{
    kUploadStateS3,
    kUploadStateParse,
    kUploadStateWatermark
} kUploadState;

typedef void (^UploadCompletion)(BOOL success, PFObject *object);
typedef void (^ProgressHandler)(float percentage, kUploadState state);

@interface UGFile : NSObject

@property kFileType fileType;

@property (nonatomic, strong) NSURL *movieURL;
@property (nonatomic, strong) NSURL *movieWatermarkedURL;
@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) NSString *filenameUnique;
@property (nonatomic, strong) PFGeoPoint *geoPoint;
@property (nonatomic, strong) CLPlacemark *placemarkFile;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSArray *tags;

@property BOOL shouldTagLocation;

-(id)initWithURL:(NSURL *)url photo:(UIImage *)photoImage;

-(void)movieThumbnailCompletion:(void (^)(UIImage *image))block;

-(void)uploadWithProgress:(ProgressHandler)progress completion:(UploadCompletion)block;
-(void)renderWatermarkCompletion:(void(^)(NSURL *renderedURL))block;

@end