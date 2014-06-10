//
//  JCAlertViewManager.h
//  UndergroundNetwork
//
//  Created by Jon Como on 5/16/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AlertCompletion)(NSInteger buttonIndex);

@interface JCAlertViewManager : NSObject

+(JCAlertViewManager *)sharedManager;

-(void)alertViewWithTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)cancel buttons:(NSArray *)buttons completion:(AlertCompletion)block;

@end
