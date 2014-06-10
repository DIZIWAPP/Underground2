//
//  MBProgressHUD+SimpleHUD.h
//  UndergroundNetwork
//
//  Created by Jon Como on 5/23/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (SimpleHUD)

+(void)showMessageWithText:(NSString *)text detailText:(NSString *)detailText length:(float)length inView:(UIView *)view;

@end
