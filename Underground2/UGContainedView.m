//
//  UGContainedView.m
//  Sportsbuddyz
//
//  Created by Jon Como on 4/24/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGContainedView.h"

@interface UGContainedView () <UIScrollViewDelegate>
{
    UIView *fadeOut;
}

@end

@implementation UGContainedView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code
        
        _startRect = frame;
        
        self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    }
    
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.collectionViewFiles.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self interacted];
}

-(void)interacted
{
    [fadeOut removeFromSuperview];
    
    [self.delegate containedViewInteracted:self];
}

-(void)showTitle:(NSString *)title
{
    [fadeOut removeFromSuperview];
    fadeOut = nil;
    
    fadeOut = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:fadeOut];
    fadeOut.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
    
    [fadeOut addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(interacted)]];
    
    UILabel *label = [[UILabel alloc] initWithFrame:fadeOut.frame];
    label.text = title;
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:20]];
    label.textColor = [UIColor blackColor];
    [fadeOut addSubview:label];
    [label setUserInteractionEnabled: NO];
}

-(void)refresh
{
    
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
