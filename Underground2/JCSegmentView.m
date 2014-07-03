//
//  JCSegmentView.m
//  Sportsbuddyz
//
//  Created by Jon Como on 3/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "JCSegmentView.h"

@implementation JCSegmentView
{
    NSInteger currentIndex;
    CGSize contentSize;
}

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items views:(NSArray *)views padding:(float)p
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        
        _views = views;
        
        float sHeight = 50;
        
        float p2 = 10;
        
        _segmentControl = [[UISegmentedControl alloc] initWithItems:items];
        _segmentControl.frame = CGRectMake(p2, p2, frame.size.width - p2*2, sHeight - p2*2);
        [self addSubview:_segmentControl];
        
        [_segmentControl addTarget:self action:@selector(updateIndex) forControlEvents:UIControlEventValueChanged];
        
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(p, sHeight, frame.size.width-p*2, frame.size.height-sHeight - p)];
        [self addSubview:_contentView];
        
        contentSize = _contentView.frame.size;
        
        _segmentControl.selectedSegmentIndex = 0;
        [self updateIndex];
    }
    
    return self;
}

-(void)updateIndex
{
    float offset = self.segmentControl.selectedSegmentIndex < currentIndex ? -self.frame.size.width : self.frame.size.width;
    
    currentIndex = self.segmentControl.selectedSegmentIndex;
    
    if (self.indexChanged)
        self.indexChanged(currentIndex);
    
    if (self.contentView.subviews.count == 0){
        //Just add it, this is the first view
        UIView *newView = self.views[currentIndex];
        newView.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
        [self.contentView addSubview:newView];
        return;
    }
    
    NSLog(@"Subviews: %i offset: %f", self.contentView.subviews.count, offset);
    
    UIView *lastView = self.contentView.subviews[0];
    lastView.layer.transform = CATransform3DMakeTranslation(-offset, 0, 0);
    
    UIView *newView = self.views[currentIndex];
    newView.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
    [self.contentView addSubview:newView];
    
    self.contentView.layer.transform = CATransform3DMakeTranslation(offset, 0, 0);
    
    [UIView animateWithDuration:.2 animations:^{
        self.contentView.layer.transform = CATransform3DIdentity;
    } completion:^(BOOL finished) {
        //Remove other views
        lastView.layer.transform = CATransform3DIdentity;
        [lastView removeFromSuperview];
    }];
}

@end