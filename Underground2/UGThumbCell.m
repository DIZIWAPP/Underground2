//
//  UGThumbCell.m
//  Sportsbuddyz
//
//  Created by Jon Como on 3/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGThumbCell.h"

#import "UGVideo.h"
#import <Parse/Parse.h>

@implementation UGThumbCell
{
    __weak IBOutlet PFImageView *imageViewThumb;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        //init
        self.clipsToBounds = YES;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 2;
        self.layer.cornerRadius = 6;
    }
    
    return self;
}

-(void)setVideo:(UGVideo *)video
{
    _video = video;
    
    [imageViewThumb setFile:video.object[@"thumbnail"]];
    [imageViewThumb loadInBackground];
}

-(void)setUser:(PFUser *)user
{
    _user = user;
    
    [imageViewThumb setImage:[UIImage imageNamed:@"profileImage"]];
    
    PFFile *thumb = user[@"profileImage"];
    
    if (thumb){
        [imageViewThumb setFile:thumb];
        [imageViewThumb loadInBackground];
    }
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
