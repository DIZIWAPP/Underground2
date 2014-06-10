//
//  UGAdminViewController.m
//  Sportsbuddyz
//
//  Created by Jon Como on 6/2/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UGAdminViewController.h"

#import "UGTabBarController.h"


#import "MBProgressHUD+SimpleHUD.h"

@interface UGAdminViewController ()
{
    
    __weak IBOutlet UITextField *textFieldUsername;
}

@end

@implementation UGAdminViewController

+(UGAdminViewController *)present
{
    UGAdminViewController *adminVC = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"adminVC"];
    [[UGTabBarController tabBarController] pushViewController:adminVC];
    
    return adminVC;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Admin";
        self.view.backgroundColor = [UIColor whiteColor];
        
        
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)massSub:(id)sender
{
    if (textFieldUsername.text.length == 0) return;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading";
    hud.detailsLabelText = [NSString stringWithFormat:@"Subbing all users to: %@", textFieldUsername.text];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    [PFCloud callFunctionInBackground:@"massSubscribe" withParameters:@{@"username": textFieldUsername.text} block:^(id object, NSError *error) {
        if (error){
            NSLog(@"Error: %@", error);
        }
        
        [hud hide:YES];
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
