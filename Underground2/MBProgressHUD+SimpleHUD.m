//
//  MBProgressHUD+SimpleHUD.m
//  UndergroundNetwork
//
//  Created by Jon Como on 5/23/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "MBProgressHUD+SimpleHUD.h"

@implementation MBProgressHUD (SimpleHUD)

+(void)showMessageWithText:(NSString *)text detailText:(NSString *)detailText length:(float)length inView:(UIView *)view
{
    MBProgressHUD *message = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    message.labelText = text;
    message.detailsLabelText = detailText;
    [message setMode:MBProgressHUDModeText];
    
    [message hide:YES afterDelay:length];
}

@end