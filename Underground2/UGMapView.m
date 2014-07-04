//
//  UGMapView.m
//  Sportsbuddyz
//
//  Created by Jon Como on 3/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGMapView.h"

#import "UGPointAnnotation.h"

#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

#import "JCParseManager.h"

#import "UGVideo.h"

@interface UGMapView () <MKMapViewDelegate>

@end

@implementation UGMapView
{
    MKMapView *map;
    BOOL didCenter;
    
    NSMutableArray *annotations;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        map = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:map];
        
        map.showsUserLocation = YES;
        map.delegate = self;
        
        //[self refresh];
    }
    
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    map.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

-(void)showAnnotationsForVideos:(NSArray *)videos
{
    for (UGVideo *video in videos)
    {
        UGPointAnnotation *fileAnnotation = [[UGPointAnnotation alloc] init];
        
        fileAnnotation.video = video;
        
        fileAnnotation.title = [[JCParseManager sharedManager] nameForObject:video.object];
        
        NSString *subTitle = [NSString stringWithFormat:@"%@", [[JCParseManager sharedManager].formatter stringFromDate:video.object.createdAt]];
        fileAnnotation.subtitle = subTitle;
        
        PFGeoPoint *fileLocation = video.object[@"location"];
        
        if (video.object[@"locationOffset"])
            fileLocation = video.object[@"locationOffset"];
        
        CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(fileLocation.latitude, fileLocation.longitude);
        
        [fileAnnotation setCoordinate:coords];
        
        [annotations addObject:fileAnnotation];
        [map addAnnotation:fileAnnotation];
    }
}

-(void)refresh
{
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (error) return;
        
        [map setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude), MKCoordinateSpanMake(1, 1))];
        
        PFQuery *query = [PFQuery queryWithClassName:@"File"];
        
        [query whereKey:@"location" nearGeoPoint:geoPoint];
        [query includeKey:@"user"];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) return;
            
            [map removeAnnotations:annotations];
            [annotations removeAllObjects];
            
            for (PFObject *object in objects)
            {
                UGVideo *video = [[UGVideo alloc] initWithObject:object];
                
                UGPointAnnotation *fileAnnotation = [[UGPointAnnotation alloc] init];
                
                fileAnnotation.video = video;
                
                fileAnnotation.title = [[JCParseManager sharedManager] nameForObject:video.object];
                
                NSString *subTitle = [NSString stringWithFormat:@"%@", [[JCParseManager sharedManager].formatter stringFromDate:video.object.createdAt]];
                fileAnnotation.subtitle = subTitle;
                
                PFGeoPoint *fileLocation = video.object[@"location"];
                
                if (video.object[@"locationOffset"])
                    fileLocation = video.object[@"locationOffset"];
                
                CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(fileLocation.latitude, fileLocation.longitude);
                
                [fileAnnotation setCoordinate:coords];
                
                [annotations addObject:fileAnnotation];
                [map addAnnotation:fileAnnotation];
            }
        }];
        
    }];
}

#pragma MKMapView delegate

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isEqual:mapView.userLocation]) {
        return nil;
    }
    
    MKAnnotationView *newAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotation1"];
    
    //newAnnotation.pinColor = MKPinAnnotationColorRed;
    //newAnnotation.animatesDrop = YES;
    newAnnotation.canShowCallout = YES;
    newAnnotation.image = [UIImage imageNamed:@"activity"];
    [newAnnotation setSelected:YES animated:YES];
    newAnnotation.calloutOffset = CGPointMake(0, 0);
    
    
    UIButton *calloutButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    newAnnotation.rightCalloutAccessoryView = calloutButton;
    
    newAnnotation.alpha = 0;
    
    [UIView animateWithDuration:0.8 animations:^{
        newAnnotation.alpha = 1;
    }];
    
    return newAnnotation;
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!didCenter)
    {
        didCenter = YES;
        [mapView setCenterCoordinate:userLocation.coordinate animated:YES];
    }
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    UGPointAnnotation *annotation = view.annotation;
    
    [annotation.video playInVideoViewController];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
