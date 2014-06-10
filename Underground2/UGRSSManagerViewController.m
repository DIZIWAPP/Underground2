//
//  UGRSSManagerViewController.m
//  Sportsbuddyz
//
//  Created by Jon Como on 4/7/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGRSSManagerViewController.h"

#import <Parse/Parse.h>

#import "UGCurrentUser.h"

#import "UGTabBarController.h"

#import "MBProgressHUD.h"

#import "UGLayoutFloatHeaders.h"

#import "UGButtonFile.h"

#import "UGRSSItem.h"

#import "UGRSSManager.h"

#import "UGRSSPreviewViewController.h"

#import "MBProgressHUD.h"

#import "UGFeedCell.h"

@interface UGRSSManagerViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    __weak IBOutlet UICollectionView *collectionViewItems;
    
    UIRefreshControl *refresh;
    
    NSMutableArray *data;
    NSMutableArray *userSubs;
    
    NSString *currentHeader;
    
    NSArray *headers;
}

@end

@implementation UGRSSManagerViewController

+(UGRSSManagerViewController *)presentRSSManagerViewControllerCompletion:(ManageHandler)block
{
    UGRSSManagerViewController *rssManagerVC = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"newsVC"];
    
    rssManagerVC.manageBlock = block;
    
    [[UGTabBarController tabBarController] pushViewController:rssManagerVC];
    
    return rssManagerVC;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.title = @"Manage";
    
    refresh = [[UIRefreshControl alloc] init];
    [collectionViewItems registerNib:[UINib nibWithNibName:@"feedCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"feedCell"];
    [collectionViewItems addSubview:refresh];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    UGLayoutFloatHeaders *layout = [UGLayoutFloatHeaders new];
    
    layout.itemSize = CGSizeMake(320, 60);
    layout.headerReferenceSize = CGSizeMake(320, 50);
    
    collectionViewItems.collectionViewLayout = layout;
    
    headers = @[@"SPORTS", @"NFL", @"NBA", @"MLB", @"NHL", @"SOCCER", @"MMA", @"TENNIS"];
    currentHeader = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refresh];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.manageBlock) self.manageBlock();
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refresh
{
    if (!currentHeader) return;
    
    [refresh beginRefreshing];
    
    collectionViewItems.userInteractionEnabled = NO;
    
    if (!data) data = [NSMutableArray array];
    [data removeAllObjects];
    
    if (!userSubs) userSubs = [NSMutableArray array];
    [userSubs removeAllObjects];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
    
    //Find files
    PFRelation *subsRelation = [[PFUser currentUser] relationforKey:@"subscriptions"];
    PFQuery *query = [subsRelation query];
    
    [query orderByAscending:@"team"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error) {
                [refresh endRefreshing];
                collectionViewItems.userInteractionEnabled = YES;
                [hud hide:YES];
                return;
            }
            
            
            NSArray *rssItems = [self groupsFromObjects:objects];
            [userSubs addObjectsFromArray:rssItems];
            
            
            PFQuery *headerRSS = [PFQuery queryWithClassName:@"SportsRSS"];
            
            [headerRSS whereKey:@"sport" equalTo:currentHeader];
            [headerRSS orderByAscending:@"team"];
            
            headerRSS.limit = 1000;
            
            [headerRSS findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [refresh endRefreshing];
                    collectionViewItems.userInteractionEnabled = YES;
                    [hud hide:YES];
                    
                    if (error) {
                        return;
                    }
                    
                    NSArray *rssItems = [self groupsFromObjects:objects];
                    [data addObjectsFromArray:rssItems];
                    
                    for (NSDictionary *dataGroup in data)
                    {
                        for (UGRSSItem *dataRSSItem in dataGroup[@"items"])
                        {
                            for (NSDictionary *userGroup in userSubs)
                            {
                                for (UGRSSItem *userItem in userGroup[@"items"])
                                {
                                    if ([userItem.item.objectId isEqualToString:dataRSSItem.item.objectId])
                                    {
                                        dataRSSItem.isSubscribed = YES;
                                    }
                                }
                            }
                            
                        }
                    }
                    
                    [collectionViewItems reloadData];
                    [collectionViewItems.collectionViewLayout invalidateLayout];
                });
            }];
            
            
            
        });
    }];
}

-(NSArray *)groupsFromObjects:(NSArray *)objects
{
    NSMutableArray *dictionaries = [NSMutableArray array];
    
    for (PFObject *object in objects)
    {
        NSMutableDictionary *group = nil;
        
        for (NSMutableDictionary *dict in dictionaries){
            if ([dict[@"team"] isEqualToString:object[@"team"]]){
                group = dict;
            }
        }
        
        //Create it if it doesnt exist
        if (!group){
            group = [NSMutableDictionary dictionary];
            [group setValue:object[@"team"] forKey:@"team"];
            [group setValue:[NSMutableArray array] forKey:@"items"];
            
            if ([object[@"team"] isEqualToString:@"Headlines"])
            {
                [dictionaries insertObject:group atIndex:0];
            }else{
                [dictionaries addObject:group];
            }
        }
        
        NSMutableArray *items = group[@"items"];
        
        UGRSSItem *rssItem = [[UGRSSItem alloc] initWithItem:object];
        [items addObject:rssItem];
    }
    
    return dictionaries;
}

-(int)currentSection
{
    for (int i = 0; i<headers.count; i++) {
        if ([currentHeader isEqualToString:headers[i]])
        {
            return i;
        }
    }
    
    return 0;
}

-(void)toggleSubscriptionToGroup:(NSDictionary *)group completion:(void (^)(BOOL subbed))block
{
    PFRelation *subs = [[PFUser currentUser] relationforKey:@"subscriptions"];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    BOOL isSubscribed = [self doesGroupHaveSubscription:group];
    
    hud.labelText = isSubscribed ? @"Removing..." : @"Saving...";
    
    for (UGRSSItem *item in group[@"items"]){
        item.isSubscribed = !isSubscribed;
        
        if (isSubscribed)
        {
            [subs removeObject:item.item];
        }else{
            [subs addObject:item.item];
        }
    }
    
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (block) block(!isSubscribed);
        
        [hud hide:YES];
        [self refresh];
    }];
}

-(void)toggleSubscription:(UGButtonFile *)button
{
    NSDictionary *group = data[button.indexPath.row];
    
    [self toggleSubscriptionToGroup:group completion:nil];
}

-(BOOL)doesGroupHaveSubscription:(NSDictionary *)group
{
    for (UGRSSItem *item in group[@"items"]){
        if (item.isSubscribed) return YES;
    }
    
    return NO;
}

-(void)changeHeader:(UIButton *)sender
{
    NSString *newHeader = sender.titleLabel.text;
    if ([newHeader isEqualToString:@"ALL"]) newHeader = @"SPORTS";
    
    if ([currentHeader isEqualToString:newHeader])
    {
        currentHeader = nil;
        
        [data removeAllObjects];
        [collectionViewItems reloadData];
        
        return;
    }
    
    currentHeader = newHeader;
    
    [self refresh];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UGFeedCell *cell = (UGFeedCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"feedCell" forIndexPath:indexPath];
    
    NSDictionary *rssGroup = data[indexPath.row];
    cell.rssGroup = rssGroup;
    
    cell.manager = self;
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSString *sectionHeader = headers[section];
    
    if ([sectionHeader isEqualToString:currentHeader])
    {
        return data.count;
    }else{
        return 0;
    }
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
    
    UIButton *headerButton = (UIButton *)[header viewWithTag:100];
    
    if (headerButton.allTargets.count == 0)
        [headerButton addTarget:self action:@selector(changeHeader:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *headerName = headers[indexPath.section];
    
    UIImageView *detail = (UIImageView *)[header viewWithTag:200];
    detail.layer.transform = CATransform3DMakeRotation([headerName isEqualToString:currentHeader] ? M_PI_2 : 0, 0, 0, 1);
    
    [UIView performWithoutAnimation:^{
        if ([headerName isEqualToString:@"SPORTS"])
        {
            [headerButton setTitle:@"ALL" forState:UIControlStateNormal];
        }else{
            [headerButton setTitle:headerName forState:UIControlStateNormal];
        }
    }];
    
    return header;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return headers.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *rssGroup = data[indexPath.row];
    
    NSMutableArray *urls = [NSMutableArray array];
    for (UGRSSItem *item in rssGroup[@"items"])
    {
        [urls addObject:item.item[@"xmlUrl"]];
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading preview";
    hud.mode = MBProgressHUDModeIndeterminate;
    
    [[UGRSSManager sharedManager] parseURLs:urls completion:^(NSArray *items) {
        
        [hud hide:YES];
        
        UGRSSPreviewViewController *preview = [[UGRSSPreviewViewController alloc] init];
        
        preview.group = rssGroup;
        preview.title = rssGroup[@"team"];
        preview.items = items;
        preview.isSubbed = [self doesGroupHaveSubscription:rssGroup];
        
        [[UGTabBarController tabBarController] pushViewController:preview];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
