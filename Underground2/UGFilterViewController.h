//
//  UGFilterViewController.h
//  Sportsbuddyz
//
//  Created by Jon Como on 3/17/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    UGModeTypeFollow,
    UGModeTypeSelect
} UGModeType;

@class PFQuery;

typedef PFQuery *(^QueryBlock)(void);

@interface UGFilterViewController : UIViewController

+(UGFilterViewController *)filterViewControllerWithBlock:(QueryBlock)queryBlock searchText:(NSString *)searchText;
+(UGFilterViewController *)findItemsWithQueryBlock:(QueryBlock)queryBlock searchText:(NSString *)searchText;

@property (nonatomic, copy) QueryBlock queryBlock;

@property UGModeType mode;

@property (nonatomic, strong) NSMutableArray *selectedUsers;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, copy) NSString *searchText;

-(void)toggleVideosUsers;

@end