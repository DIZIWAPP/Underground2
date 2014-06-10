//
//  UGTaggingManager.m
//  Sportsbuddyz
//
//  Created by Jon Como on 2/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGTaggingManager.h"
#import <Parse/Parse.h>

@implementation UGTaggingManager
{
    UICollectionView *collectionViewTags;
    NSMutableArray *foundTags;
    
    PFQuery *queryTags;
    
    NSTimer *timerDelayedQuery;
    NSString *stringToQuery;
    
    TagSaveHandler saveHandler;
    NSMutableArray *finalTags;
}

-(void)enterTaggingMode:(BOOL)taggingMode
{
    if (taggingMode)
    {
        [self.textFieldTags becomeFirstResponder];
        self.topConstraint.constant = -320;
        
        if (!collectionViewTags)
        {
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            collectionViewTags = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 44, 320, 200) collectionViewLayout:layout];
            
            layout.itemSize = CGSizeMake(300, 44);
            
            UINib *nib = [UINib nibWithNibName:@"tagCell" bundle:[NSBundle mainBundle]];
            [collectionViewTags registerNib:nib forCellWithReuseIdentifier:@"tagCell"];
            
            collectionViewTags.delegate = self;
            collectionViewTags.dataSource = self;
            
            collectionViewTags.alwaysBounceVertical = YES;
        }
        
        UIViewController *delegate = (UIViewController *)self.delegate;
        [delegate.view addSubview:collectionViewTags];
        
    }else{
        [self.textFieldTags resignFirstResponder];
        self.topConstraint.constant = 0;
        
        [collectionViewTags removeFromSuperview];
    }
    
    UIViewController *delegate = (UIViewController *)self.delegate;
    [delegate.view layoutSubviews];
}

-(void)saveTagsCompletion:(TagSaveHandler)block
{
    //Format text
    NSArray *strings = [self.textFieldTags.text componentsSeparatedByString:@", "];
    self.textFieldTags.text = @"";
    
    NSString *formatted = strings[0];
    
    if (strings.count > 1)
    {
        for (int i = 1; i<strings.count; i++)
        {
            NSString *tag = strings[i];
            if (tag.length == 0) continue;
            formatted = [NSString stringWithFormat:@"%@, %@", formatted, tag];
        }
    }
    
    self.textFieldTags.text = formatted;
    
    //Save the tags to parse
    
    if (!finalTags) finalTags = [NSMutableArray array];
    [finalTags removeAllObjects];
    
    saveHandler = block;
    
    NSArray *tags = [self.textFieldTags.text componentsSeparatedByString:@", "];
    __block int numToSave = (int)tags.count;
    
    for (NSString *name in tags)
    {
        PFQuery *findTag = [PFQuery queryWithClassName:@"Tag"];
        [findTag whereKey:@"name" equalTo:name];
        
        [findTag findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) return;
            
            if (objects.count > 0){
                PFObject *foundTag = objects[0];
                [finalTags addObject:foundTag];
                numToSave--;
                if (numToSave <= 0) [self savedTags];
            }else{
                //Couldn't find it
                PFObject *newTag = [PFObject objectWithClassName:@"Tag"];
                [newTag setObject:name forKey:@"name"];
                [newTag saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) return;
                    
                    [finalTags addObject:newTag];
                    numToSave--;
                    if (numToSave <= 0) [self savedTags];
                }];
            }
        }];
    }
}

-(void)savedTags
{
    [self enterTaggingMode:NO];
    if (saveHandler) saveHandler(finalTags);
}

//UItextfield

-(void)setTextFieldTags:(UITextField *)textFieldTags
{
    _textFieldTags = textFieldTags;
    
    textFieldTags.placeholder = @"Tags: Politics, Riot, etc.";
    
    textFieldTags.delegate = self;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self enterTaggingMode:YES];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self enterTaggingMode:NO];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return NO;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"#"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Entering tags" message:@"Enter comma separated words: NBA, NFL, etc. No need for the #" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
        return NO;
    }
    
    //run query
    NSString *fullString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSArray *strings = [fullString componentsSeparatedByString:@", "];
    
    if (strings.count == 0) return YES;
    
    NSString *lastTag = [strings lastObject];
    
    NSLog(@"Querying for string: %@", lastTag);
    
    if (lastTag.length == 0) {
        [foundTags removeAllObjects];
        [collectionViewTags reloadData];
        return YES;
    }
    
    stringToQuery = lastTag;
    [timerDelayedQuery invalidate];
    timerDelayedQuery = nil;
    timerDelayedQuery = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(queryForTags) userInfo:nil repeats:NO];
    
    return YES;
}

-(void)queryForTags
{
    NSString *string = stringToQuery;
    
    if (!foundTags)
        foundTags = [NSMutableArray array];
    
    [foundTags removeAllObjects];
    
    [queryTags cancel];
    queryTags = nil;
    
    queryTags = [PFQuery queryWithClassName:@"Tag"];
    
    [queryTags whereKey:@"name" containsString:string];
    [queryTags findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *tag in objects)
        {
            NSString *tagName = tag[@"name"];
            
            if ([tagName rangeOfString:string].location == 0)
            {
                //contains string at beginning
                [foundTags addObject:tag];
            }
        }
        
        
        [collectionViewTags reloadData];
    }];
}

//Collectionview

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tagCell" forIndexPath:indexPath];
    
    UILabel *label = (UILabel *)[cell viewWithTag:100];
    
    PFObject *tag = foundTags[indexPath.row];
    
    label.text = tag[@"name"];
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return foundTags.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (foundTags.count == 0 || !foundTags) return;
    
    PFObject *tag = foundTags[indexPath.row];
    
    NSMutableArray *strings = [[self.textFieldTags.text componentsSeparatedByString:@", "] mutableCopy];
    [strings removeLastObject];
    
    self.textFieldTags.text = @"";
    
    for (NSString *string in strings){
        if (self.textFieldTags.text.length == 0)
        {
            self.textFieldTags.text = string;
        }else{
            self.textFieldTags.text = [NSString stringWithFormat:@"%@, %@", self.textFieldTags.text, string];
        }
    }
    
    if (strings.count == 0)
    {
        self.textFieldTags.text = [NSString stringWithFormat:@"%@, ", tag[@"name"]];
    }else{
        self.textFieldTags.text = [NSString stringWithFormat:@"%@, %@, ", self.textFieldTags.text, tag[@"name"]];
    }
    
    [foundTags removeAllObjects];
    [collectionViewTags reloadData];
}

@end
