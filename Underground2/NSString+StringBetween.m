//
//  NSString+StringBetween.m
//  Underground
//
//  Created by Jon Como on 5/8/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "NSString+StringBetween.h"

@implementation NSString (StringBetween)

-(NSString *)stringBetweenString:(NSString *)start andString:(NSString *)end
{
    NSRange startRange = [self rangeOfString:start];
    
    if (startRange.location != NSNotFound) {
        NSRange targetRange;
        targetRange.location = startRange.location + startRange.length;
        targetRange.length = [self length] - targetRange.location;
        NSRange endRange = [self rangeOfString:end options:0 range:targetRange];
        
        if (endRange.location != NSNotFound) {
            targetRange.length = endRange.location - targetRange.location;
            return [self substringWithRange:targetRange];
        }
    }
    
    return nil;
}

@end
