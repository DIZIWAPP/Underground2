//
//  UGFile.m
//  UndergroundNetwork
//
//  Created by Jon Como on 5/9/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "UGFile.h"
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>
#import "JCTransferManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UGMacros.h"
#import "JCTransferObject.h"
#import "JCActionSheetManager.h"
#import "UGWatermark.h"

@implementation UGFile
{
    NSDateFormatter *formatter;
}

-(id)initWithURL:(NSURL *)url photo:(UIImage *)photoImage;
{
    if (self = [super init]) {
        //init
        
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd-HH-SSSS"];
        
        _shouldTagLocation = YES;
        
        _movieURL = url;
        
        if (url){
            _fileType = kFileTypeMovie;
            _filenameUnique = [self uniqueNameWithExtension:@"mov"];
        }else if(photoImage){
            _fileType = kFileTypeImage;
            _photo = photoImage;
            _thumbnail = photoImage;
            _filenameUnique = [self uniqueNameWithExtension:@"jpg"];
        }
    }
    
    return self;
}

-(void)movieThumbnailCompletion:(void (^)(UIImage *image))block
{
    if (!self.movieURL){
        if (block) block(nil);
        return;
    }
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:self.movieURL];
        UIImage *thumbnail = [player thumbnailImageAtTime:0 timeOption:MPMovieTimeOptionNearestKeyFrame];
        
        [player stop];
        
        //dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block(thumbnail);
        //});
    //});
}

-(NSString *)uniqueNameWithExtension:(NSString *)extension
{
    return [NSString stringWithFormat:@"%@_%@.%@", [formatter stringFromDate:[NSDate date]], [self randomStringWithLength:10], extension];
}

-(NSData *)data
{
    NSData *returnData;
    
    if (self.photo)
    {
        returnData = UIImageJPEGRepresentation(self.photo, 0.8);
    }else if (self.movieURL)
    {
        NSURL *finalMovieURL = self.movieWatermarkedURL ? self.movieWatermarkedURL : self.movieURL;
        returnData = [NSData dataWithContentsOfURL:finalMovieURL];
    }
    
    return returnData;
}

-(NSString *)randomStringWithLength:(int)length
{
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    
    for (int i=0; i<length; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    return randomString;
}

-(void)renderWatermarkCompletion:(void(^)(NSURL *renderedURL))block
{
    if (!self.description){
        if (block) block(self.movieURL);
        return;
    }
    
    [[UGWatermark new] performWithText:self.description inVideoAtURL:self.movieURL completion:^(NSURL *watermarkedURL) {
        self.movieWatermarkedURL = watermarkedURL;
        if (block) block(watermarkedURL);
    }];
}

-(void)tagLocationCompletion:(void(^)(void))block
{
    if (!self.shouldTagLocation)
    {
        self.geoPoint = nil;
        if (block) block();
        return;
    }
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        
        self.geoPoint = geoPoint;
        
        if (error || (geoPoint.latitude == 0 && geoPoint.longitude == 0)){
            self.geoPoint = nil;
        }
        
        [self placemarkForGeoPoint:self.geoPoint completion:^(CLPlacemark *placemark) {
            
            if (placemark){
                self.placemarkFile = placemark;
                self.filenameUnique = [NSString stringWithFormat:@"%@_%@", placemark.locality, self.filenameUnique];
            }else{
                self.filenameUnique = [NSString stringWithFormat:@"%@_%@", @"None", self.filenameUnique];
            }
        
            if (block) block();
            
        }];
    }];
}

-(void)uploadWithProgress:(ProgressHandler)progress completion:(UploadCompletion)block
{
    [self tagLocationCompletion:^{
            
        if (!self.filenameUnique){
            if (block) block(NO, nil);
            return;
        }
            
        /*
        if (self.description)
            if (progress) progress(0, kUploadStateWatermark);
        */
        
        [self renderWatermarkCompletion:^(NSURL *renderedURL) {
            
            NSData *fileData = [self data];
            
            if (!fileData)
            {
                if (block) block(NO, nil);
                return;
            }
            
            [[JCTransferManager sharedManager] authorizeWithKey:ACCESS_KEY secretKey:SECRET_KEY bucket:@"uploads.underground.net"];
            [[JCTransferManager sharedManager] uploadData:@[[self data]] filenames:@[self.filenameUnique] progress:^(NSString *key, int bytesUploaded, int bytesTotal) {
                
                if (![key isEqualToString:self.filenameUnique])
                    return;
                
                if (progress) progress((float)bytesUploaded / (float)bytesTotal * 100.0f, kUploadStateS3);
                
            } completion:^(NSString *key, BOOL success, EndBackgroundBlock endBlock) {
                
                if (![key isEqualToString:self.filenameUnique])
                    return;
                
                if (!success){
                    if (block) block(NO, nil);
                    return;
                }
                
                if (progress) progress(0, kUploadStateParse);
                
                PFObject *file = [PFObject objectWithClassName:@"File"];
                
                if (self.geoPoint)
                {
                    //[file setObject:self.geoPoint forKey:@"location"];
                    
                    PFGeoPoint *locationOff = [PFGeoPoint geoPointWithLatitude:self.geoPoint.latitude + [self marginOfError] longitude:self.geoPoint.longitude + [self marginOfError]];
                    
                    [file setObject:locationOff forKey:@"location"];
                }
                
                if (self.placemarkFile.locality)
                    [file setObject:self.placemarkFile.locality forKey:@"locality"];
                
                [self saveParseFile:file completion:block];
            }];
        }];
    }];
}


-(float)marginOfError
{
    return (((float)(arc4random()%1000)) - 500.0f)/1000000;
}

-(void)placemarkForGeoPoint:(PFGeoPoint *)point completion:(void (^)(CLPlacemark *placemark))block
{
    CLGeocoder *geocode = [[CLGeocoder alloc] init];
    [geocode reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:point.latitude longitude:point.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (error || placemarks.count == 0){
            if (block) block(nil);
            return;
        }
        
        CLPlacemark *placemark = placemarks[0];
        if (block) block(placemark);
    }];
}

-(void)saveParseFile:(PFObject *)file completion:(UploadCompletion)block
{
    if (self.description)
        [file setObject:self.description forKey:@"description"];
    
    if (self.tags)
    {
        PFRelation *fileTags = [file relationforKey:@"tags"];
        
        for (PFObject *tag in self.tags){
            [fileTags addObject:tag];
        }
    }
    
    NSString *fileURL = [NSString stringWithFormat:@"https://s3.amazonaws.com/uploads.underground.net/%@", self.filenameUnique];
    
    [file setObject:fileURL forKey:@"URL"];
    [file setObject:[PFUser currentUser] forKey:@"user"];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (!succeeded){
            if (block) block(NO, nil);
            return;
        }
        
        //upload thumbnail
        [self saveThumbnailToFile:file completion:^(BOOL success) {
            
            PFRelation *relation = [[PFUser currentUser] relationforKey:@"files"];
            [relation addObject:file];
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (!succeeded){
                    if (block) block(NO, nil);
                    return;
                }
                
                [self sendPushWithPath:fileURL fileId:file.objectId completion:^(BOOL success) {
                    
                    if (!success){
                        if (block) block(NO, nil);
                    }
                    
                    if (block) block(YES, file);
                    
                }];
            }];
        }];
    }];
}

-(void)saveThumbnailToFile:(PFObject *)file completion:(void(^)(BOOL success))block
{
    if (!self.thumbnail){
        if (block) block(NO);
        return;
    }
    
    //upload thumbnail
    PFFile *thumb = [PFFile fileWithData:UIImageJPEGRepresentation(self.thumbnail, 0.8)];
    
    [thumb saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error || !succeeded){
            if (block) block(NO);
            return;
        }
        
        [file setObject:thumb forKey:@"thumbnail"];
        
        [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error || !succeeded){
                if (block) block(NO);
                return;
            }
            
            if (block) block(YES);
        }];
    }];
}

-(void)sendPushWithPath:(NSString *)path fileId:(NSString *)fileId completion:(void(^)(BOOL success))block
{
    PFPush *push = [PFPush push];
    
    [push setChannel:@"fileUpload"];
    
    NSString *message = [NSString stringWithFormat:@"File uploaded by user %@.", [PFUser currentUser].username ? [PFUser currentUser].username : @"Anonymous"];
    
    [push setData:@{@"alert" : message, @"sound" : @"default", UGPushAction : UGPushActionCopyURL, UGPushURL : path}];
    
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (block) block(succeeded);
    }];
}

@end
