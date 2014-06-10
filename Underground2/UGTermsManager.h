//
//  UGTermsManager.h
//  Underground
//
//  Created by Jon Como on 5/8/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UGTermsManager : NSObject

+(UGTermsManager *)sharedManager;

-(void)termsUpdated:(void(^)(BOOL success, BOOL termsUpdated))block;
-(NSURLRequest *)termsRequest;
+(NSString *)dateStringFromTermsData:(NSData *)termsData;

@end