//
//  UGTaggingManager.h
//  Sportsbuddyz
//
//  Created by Jon Como on 2/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TagSaveHandler)(NSArray *tags);

@class UGTaggingManager;

@protocol UGTaggingManagerDelegate <NSObject>

-(void)taggingManager:(UGTaggingManager *)manager addedTags:(NSString *)tags;

@end

@interface UGTaggingManager : NSObject <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate>

@property (nonatomic, weak) id delegate;

@property (nonatomic, weak) UITextField *textFieldTags;
@property (nonatomic, weak) NSLayoutConstraint *topConstraint;

-(void)saveTagsCompletion:(TagSaveHandler)block;

@end