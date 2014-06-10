//
//  UGNavigationController.m
//  undergroundNetwork
//
//  Created by Jon Como on 7/18/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "UGNavigationController.h"

@interface UGNavigationController ()

@end

@implementation UGNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.orientationMask = UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSUInteger)supportedInterfaceOrientations
{
    return self.orientationMask;
}

@end
