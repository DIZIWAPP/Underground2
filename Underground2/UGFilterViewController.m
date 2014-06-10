//
//  UGFilterViewController.m
//  Sportsbuddyz
//
//  Created by Jon Como on 3/17/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGFilterViewController.h"

#import "UGTabBarController.h"

#import "UGVideoCell.h"
#import "UGVideo.h"

#import "UGUserCell.h"

#import <Parse/Parse.h>

#import "MBProgressHUD.h"

typedef enum
{
    UGDataTypeUser,
    UGDataTypeVideo
} UGDataType;

@interface UGFilterViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate>
{
    UIRefreshControl *refresh;
    NSMutableArray *results;
    
    UIButton *buttonCancelSearch;
    
    UGDataType dataType;
    NSString *cellName;
    
    PFQuery *currentQuery;
    
    NSTimer *delaySearch;
    
    __weak IBOutlet UICollectionView *collectionViewResults;
}

@end

@implementation UGFilterViewController

+(UGFilterViewController *)filterViewControllerWithBlock:(QueryBlock)queryBlock searchText:(NSString *)searchText
{
    UGFilterViewController *filterVC = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"filterVC"];
    
    filterVC.queryBlock = queryBlock;
    filterVC.searchText = searchText;
    
    return filterVC;
}

+(UGFilterViewController *)findItemsWithQueryBlock:(QueryBlock)queryBlock searchText:(NSString *)searchText
{
    UGFilterViewController *filterVC = [UGFilterViewController filterViewControllerWithBlock:queryBlock searchText:searchText];
    
    [[UGTabBarController tabBarController] pushViewController:filterVC];
    
    return filterVC;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    collectionViewResults.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    
    self.searchBar.delegate = self;
    self.searchBar.text = self.searchText;
    
    refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    collectionViewResults.dataSource = self;
    collectionViewResults.delegate = self;
    
    collectionViewResults.contentInset = UIEdgeInsetsMake(20, 0, 20, 0);
    
    collectionViewResults.alwaysBounceVertical = YES;
    
    [self.view addSubview:collectionViewResults];
    
    [collectionViewResults addSubview:refresh];
    
    [self refresh];
}

-(void)toggleVideosUsers
{
    [results removeAllObjects];
    [collectionViewResults reloadData];
    
    if (dataType == UGDataTypeUser)
    {
        //go to searching videos
        dataType = UGDataTypeVideo;
        self.navigationItem.rightBarButtonItem.title = @"Videos";
        
        self.queryBlock = ^{
            PFQuery *query = [PFQuery queryWithClassName:@"File"];
            
            [query includeKey:@"user"];
            [query orderByDescending:@"createdAt"];
            [query setLimit:30];
            
            return query;
        };
        
    }else{
        //search users
        dataType = UGDataTypeUser;
        self.navigationItem.rightBarButtonItem.title = @"Users";
        
        self.queryBlock = ^{
            PFQuery *query = [PFUser query];
            
            [query orderByDescending:@"createdAt"];
            [query setLimit:30];
            
            return query;
        };
    }
    
    [self delayRefresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if (!buttonCancelSearch)
    {
        buttonCancelSearch = [[UIButton alloc] initWithFrame:CGRectMake(0, self.searchBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
        [buttonCancelSearch addTarget:self action:@selector(cancelSearch) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.view addSubview:buttonCancelSearch];
    
    return YES;
}

-(void)cancelSearch
{
    [self.searchBar resignFirstResponder];
    [buttonCancelSearch removeFromSuperview];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //search
    [self refresh];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //search
    [self refresh];
}

-(void)setDataTypeForObject:(PFObject *)object
{
    if ([object.parseClassName isEqualToString:@"File"]){
        NSLog(@"Set data type to video");
        dataType = UGDataTypeVideo;
    }else if([object.parseClassName isEqualToString:@"User"]){
        NSLog(@"Set data type to user");
        dataType = UGDataTypeUser;
    }
    
    cellName = dataType == UGDataTypeUser ? @"userCell" : @"videoCell";
    [collectionViewResults registerNib:[UINib nibWithNibName:cellName bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:cellName];
    
    self.searchBar.placeholder = dataType == UGDataTypeVideo ? @"Search Tags" : @"Search Names";
}

-(void)refresh
{
    NSLog(@"Searching with text: %@", self.searchBar.text);
    
    [delaySearch invalidate];
    delaySearch = nil;
    
    delaySearch = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(delayRefresh) userInfo:nil repeats:NO];
}

-(void)delayRefresh
{
    if (!results) results = [NSMutableArray array];
    
    [currentQuery cancel];
    currentQuery = self.queryBlock();
    
    [refresh beginRefreshing];
    
    if (self.searchBar.text.length > 0)
    {
        if (dataType == UGDataTypeVideo){
            //Search tags
            PFQuery *tagQuery = [PFQuery queryWithClassName:@"Tag"];
            [tagQuery whereKey:@"name" containsString:self.searchBar.text];
            [currentQuery whereKey:@"tags" matchesQuery:tagQuery];
        }else if (dataType == UGDataTypeUser){
            //Search names
            [currentQuery whereKey:@"username" containsString:self.searchBar.text];
        }
    }
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    hud.labelText = @"Searching...";
    hud.mode = MBProgressHUDModeIndeterminate;
    
    [currentQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [refresh endRefreshing];
            
            
            if (error || objects.count == 0){
                hud.labelText = @"No Results";
                hud.mode = MBProgressHUDModeText;
                [hud hide:YES afterDelay:1];
                return;
            }
            
            [hud hide:YES];
            
            [results removeAllObjects];
            
            PFObject *object = objects[0];
            [self setDataTypeForObject:object];
            
            if (dataType == UGDataTypeVideo){
                for (PFObject *object in objects){
                    UGVideo *video = [[UGVideo alloc] initWithObject:object];
                    [results addObject:video];
                }
            } else if (dataType == UGDataTypeUser){
                results = [objects mutableCopy];
            }
            
            [collectionViewResults reloadData];
        });
    }];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellName forIndexPath:indexPath];
    
    if (dataType == UGDataTypeVideo)
    {
        UGVideoCell *videoCell = (UGVideoCell *)cell;
        UGVideo *video = results[indexPath.row];
        videoCell.video = video;
        
    }else if (dataType == UGDataTypeUser)
    {
        UGUserCell *userCell = (UGUserCell *)cell;
        PFUser *user = results[indexPath.row];
        userCell.user = user;
        
        if (self.mode == UGModeTypeSelect){
            userCell.type = UGUserCellTypeShare;
            //set whether the cell is selected or not
            userCell.isSelected = [self.selectedUsers containsObject:user];
        }else{
            userCell.type = UGUserCellTypeFollow;
        }
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (dataType == UGDataTypeUser && self.mode == UGModeTypeSelect)
    {
        if (!self.selectedUsers) self.selectedUsers = [NSMutableArray array];
        
        //Add to array
        PFUser *user = results[indexPath.row];
        
        if ([self.selectedUsers containsObject:user])
        {
            [self.selectedUsers removeObject:user];
        }else{
            [self.selectedUsers addObject:user];
        }
        
        [collectionViewResults reloadData];
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return results.count;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (dataType == UGDataTypeVideo)
    {
        UGVideo *video = results[indexPath.row];
        return [video sizeForCollection];
    }else if (dataType == UGDataTypeUser)
    {
        return CGSizeMake(320, 60);
    }
    
    return CGSizeMake(320, 320);
}

@end