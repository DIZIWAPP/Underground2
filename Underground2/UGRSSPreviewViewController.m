//
//  UGRSSPreviewViewController.m
//  Sportsbuddyz
//
//  Created by Jon Como on 5/2/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGRSSPreviewViewController.h"
#import "UGArticleFeedView.h"

#import "MBProgressHUD.h"
#import <Parse/Parse.h>

#import "UGRSSItem.h"

@interface UGRSSPreviewViewController ()
{
    UGArticleFeedView *articleView;
}

@end

@implementation UGRSSPreviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    articleView = [[UGArticleFeedView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:articleView];
    
    [articleView refreshWithItems:self.items];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.isSubbed ? @"Unsubscribe" : @"Subscribe" style:UIBarButtonItemStylePlain target:self action:@selector(subscribe)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)subscribe
{
    [self toggleSubscriptionToGroup:self.group completion:nil];
}

-(void)toggleSubscriptionToGroup:(NSDictionary *)group completion:(void (^)(BOOL subbed))block
{
    PFRelation *subs = [[PFUser currentUser] relationforKey:@"subscriptions"];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    hud.labelText = self.isSubbed ? @"Removing..." : @"Saving...";
    
    for (UGRSSItem *item in group[@"items"]){
        item.isSubscribed = !self.isSubbed;
        
        if (self.isSubbed)
        {
            [subs removeObject:item.item];
        }else{
            [subs addObject:item.item];
        }
    }
    
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (block) block(!self.isSubbed);
        
        [hud hide:YES];
        self.isSubbed = !self.isSubbed;
        self.navigationItem.rightBarButtonItem.title = self.isSubbed ? @"Unsubscribe" : @"Subscribe";
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
