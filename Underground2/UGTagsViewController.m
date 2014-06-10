//
//  UGEditTagsViewController.m
//  Sportsbuddyz
//
//  Created by Jon Como on 2/13/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGTagsViewController.h"

#import "UGTabBarController.h"

#import "UGIndexSwitch.h"
#import <Parse/Parse.h>

@interface UGTagsViewController () <UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    __weak IBOutlet UICollectionView *collectionViewTags;
    
    NSMutableArray *tags;
    NSMutableArray *userFollowing;
    
    BOOL isCurrentUser;
    
    UIRefreshControl *refresh;
    
    __weak IBOutlet UISearchBar *searchBarTags;
}

@end

@implementation UGTagsViewController

+(UGTagsViewController *)presentTagsForUser:(PFUser *)user
{
    UGTagsViewController *tagsVC = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"tagsVC"];
    
    tagsVC.user = user;
    
    [[UGTabBarController tabBarController] pushViewController:tagsVC];
    
    return tagsVC;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [collectionViewTags addSubview:refresh];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:searchBarTags action:@selector(resignFirstResponder)];
    [self.view addGestureRecognizer:tap];
    
    isCurrentUser = [self.user.objectId isEqualToString:[PFUser currentUser].objectId];
    
    [self findUsersTagsCompletion:^{
        [self refresh];
    }];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (isCurrentUser)
        [self.user saveInBackground];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refresh
{
    if (!isCurrentUser){
        tags = userFollowing;
        [collectionViewTags reloadData];
        [refresh endRefreshing];
        return;
    }
    
    if (searchBarTags.text.length > 0){
        [self findTagsWithString:searchBarTags.text];
    }else{
        [self findTagsWithString:nil];
    }
}

-(void)findUsersTagsCompletion:(void(^)(void))block
{
    PFRelation *userTags = [self.user relationforKey:@"tagsFollowing"];
    
    [[userTags query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!userFollowing) userFollowing = [NSMutableArray array];
        [userFollowing removeAllObjects];
        
        userFollowing = [objects mutableCopy];
        
        if (block) block();
    }];
}

-(void)findTagsWithString:(NSString *)string
{
    PFQuery *query = [PFQuery queryWithClassName:@"Tag"];
    
    if (string)
        [query whereKey:@"name" containsString:string];
    
    [query orderByAscending:@"name"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) return;
        
        tags = [objects mutableCopy];
        
        [tags sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            PFObject *tag1 = (PFObject *)obj1;
            
            if ([self userFollowsTag:tag1]){
                return NSOrderedAscending;
            }
            
            return NSOrderedDescending;
        }];
        
        [collectionViewTags reloadData];
        [refresh endRefreshing];
    }];
}

-(BOOL)userFollowsTag:(PFObject *)tag
{
    BOOL isFollowing = NO;
    
    for (PFObject *userTag in userFollowing){
        if ([userTag.objectId isEqualToString:tag.objectId])
        {
            isFollowing = YES;
        }
    }
    
    return isFollowing;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Search");
    [searchBar resignFirstResponder];
    
    [self findTagsWithString:searchBar.text];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self findTagsWithString:searchText];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

-(void)switchToggled:(UGIndexSwitch *)indexSwitch
{
    PFObject *tag = tags[indexSwitch.indexPath.row];
    
    PFRelation *userTags = [self.user relationforKey:@"tagsFollowing"];
    
    if (indexSwitch.isOn){
        [userTags addObject:tag];
        [userFollowing addObject:tag];
    }else{
        [userTags removeObject:tag];
        [self removeObject:tag fromArray:userFollowing];
    }
}

-(void)removeObject:(PFObject *)object fromArray:(NSMutableArray *)array
{
    for (int i = array.count-1; i>=0; i--)
    {
        PFObject *testObject = array[i];
        if ([testObject.objectId isEqualToString:object.objectId]) [array removeObject:testObject];
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tagCell" forIndexPath:indexPath];
    
    PFObject *tag = tags[indexPath.row];
    
    UILabel *label = (UILabel *)[cell viewWithTag:200];
    label.text = tag[@"name"];
    
    UGIndexSwitch *switchFollow = (UGIndexSwitch *)[cell viewWithTag:100];
    
    if (isCurrentUser)
    {
        if (switchFollow.allTargets.count == 0)
            [switchFollow addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
        
        switchFollow.indexPath = indexPath;
        [switchFollow setOn:[self userFollowsTag:tag]];
    }else{
        switchFollow.enabled = NO;
    }
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return tags.count;
}

@end
