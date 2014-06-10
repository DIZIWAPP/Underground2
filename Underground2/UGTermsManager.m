//
//  UGTermsManager.m
//  Underground
//
//  Created by Jon Como on 5/8/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "UGTermsManager.h"
#import "NSString+StringBetween.h"
#import "JCConnection.h"
#import "UGMacros.h"

@implementation UGTermsManager

+(UGTermsManager *)sharedManager
{
    static UGTermsManager *sharedManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

-(void)termsUpdated:(void(^)(BOOL success, BOOL termsUpdated))block
{
    JCConnection *termsConnection;
    termsConnection = [[JCConnection alloc] initWithhRequest:[self termsRequest] completion:^(BOOL success, NSData *data) {
        
        if (!success)
        {
            if (block) block(NO, NO);
        }
        
        NSString *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:UGTermsDateAgreed];
        
        if (![lastDate isEqualToString:[UGTermsManager dateStringFromTermsData:data]])
        {
            if (block) block(YES, YES);
        }else{
            if (block) block(YES, NO);
        }
    }];
}

+(NSString *)dateStringFromTermsData:(NSData *)termsData
{
    NSString *body = [[NSString alloc] initWithData:termsData encoding:NSUTF8StringEncoding];
    NSString *date = [body stringBetweenString:@"Last Modified: " andString:@"<"];
    
    return date;
}

-(NSURLRequest *)termsRequest
{
    return [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://underground.net/terms"] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:15];
}

@end