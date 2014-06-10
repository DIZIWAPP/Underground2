//
//  UGAccountViewController.m
//  UndergroundNetwork
//
//  Created by Jon Como on 5/14/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "UGAccountViewController.h"
#import "JCActionSheetManager.h"
#import "UGGraphics.h"

#import "UGFilterViewController.h"
#import "UGVideoCell.h"

#import "UGTabBarController.h"

#import "UGTagsViewController.h"

#import "UGCurrentUser.h"

#import "UGAdminViewController.h"

#import "UGRSSManagerViewController.h"

#define BIO_EDIT_PLACEHOLDER @"Tap to add some information about yourself"

@interface UGAccountViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
{
    __weak IBOutlet UITextView *textViewBio;
    
    __weak IBOutlet UIButton *buttonUploads;
    __weak IBOutlet UIButton *buttonFollow;
    
    __weak IBOutlet UIButton *buttonFollowers;
    __weak IBOutlet UIButton *buttonFollowing;
    
    __weak IBOutlet UIButton *buttonNews;
    
    __weak IBOutlet UIButton *buttonFollowedTags;
    
    __weak IBOutlet PFImageView *imageViewProfilePicture;
    
    UIAlertView *alertUsername;
    __weak IBOutlet UIButton *buttonusername;
    
    BOOL isCurrentUser;
    
    __weak IBOutlet NSLayoutConstraint *acctHeight;
    CGRect originalZoomRect;
    int originalAcctHeight;
}

@end

@implementation UGAccountViewController

+(UGAccountViewController *)presentAccountViewControllerForUser:(PFUser *)user
{
    UGAccountViewController *accountVC = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"accountVC"];
    
    accountVC.user = user;
    
    [[UGTabBarController tabBarController] pushViewController:accountVC];
    
    return accountVC;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.tintColor = [UIColor whiteColor];
    
    imageViewProfilePicture.clipsToBounds = YES;
    imageViewProfilePicture.layer.borderColor = [UIColor whiteColor].CGColor;
    imageViewProfilePicture.layer.borderWidth = 2;
    imageViewProfilePicture.layer.cornerRadius = 6;
    
    originalZoomRect = imageViewProfilePicture.frame;
    originalAcctHeight = acctHeight.constant;
    
    [self showAdminButton];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.user == NULL) self.isMainAccount = YES;
    
    if (self.isMainAccount){
        self.user = [PFUser currentUser];
    }
    
    [self updateUI];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)showAdminButton
{
    [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object[@"isAdmin"])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIButton *adminButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 80, 40)];
                [adminButton setTitle:@"Admin Panel" forState:UIControlStateNormal];
                adminButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:12];
                [adminButton addTarget:self action:@selector(showAdminPanel) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:adminButton];
            });
            
        }
    }];
}

-(void)showAdminPanel
{
    [UGAdminViewController present];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateUI
{
    isCurrentUser = ([self.user.objectId isEqualToString:[PFUser currentUser].objectId]);
    
    //self.title = self.user.username;
    textViewBio.text = self.user[@"bio"];
    
    if (isCurrentUser)
    {
        if (textViewBio.text.length == 0)
            textViewBio.text = BIO_EDIT_PLACEHOLDER;
        
        [buttonFollow removeFromSuperview];
        
        [imageViewProfilePicture addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editProfilePicture)]];
        [imageViewProfilePicture setUserInteractionEnabled:YES];
        
        textViewBio.delegate = self;
        textViewBio.returnKeyType = UIReturnKeyDone;
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleDone target:self action:@selector(logout)];
        
        buttonNews.alpha = 1;
        buttonNews.userInteractionEnabled = YES;
        
    }else{
        //Not current user
        [[UGCurrentUser user] isFollowingUser:self.user completion:^(BOOL isFollowing) {
            [buttonFollow setTitle:isFollowing ? @"Unfollow" : @"Follow" forState:UIControlStateNormal];
        }];
        
        [buttonusername setUserInteractionEnabled:NO];
        
        [textViewBio setUserInteractionEnabled:NO];
        
        self.navigationItem.rightBarButtonItem = nil;
        
        buttonNews.alpha = 0;
        buttonNews.userInteractionEnabled = NO;
        
        [imageViewProfilePicture addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomPicture)]];
        [imageViewProfilePicture setUserInteractionEnabled:YES];
    }
    
    
    [self.user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        //Followers/following counts
        [[[UGCurrentUser user] followersQueryForUser:self.user] countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (error) return;
            [buttonFollowers setTitle:[NSString stringWithFormat:@"Followers (%i)", number] forState:UIControlStateNormal];
        }];
        
        [[[UGCurrentUser user] followingQueryForUser:self.user] countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (error) return;
            [buttonFollowing setTitle:[NSString stringWithFormat:@"Following (%i)", number] forState:UIControlStateNormal];
        }];
        
        if (!isCurrentUser)
        {
            self.title = self.user.username;
        }
        
        [buttonusername setTitle:self.user.username forState:UIControlStateNormal];
        
        PFFile *profilePic = self.user[@"profileImage"];
        
        if (profilePic){
            [imageViewProfilePicture setFile:profilePic];
            [imageViewProfilePicture loadInBackground];
        }else{
            if (isCurrentUser){
                [imageViewProfilePicture setImage:[UIImage imageNamed:@"profileEditIcon"]];
            }else{
                [imageViewProfilePicture setImage:[UIImage imageNamed:@"profileImage"]];
            }
        }
    }];
}

-(void)zoomPicture
{
    [UIView animateWithDuration:0.3 animations:^{
        if (CGRectEqualToRect(imageViewProfilePicture.frame, originalZoomRect)){
            //zoom in
            imageViewProfilePicture.frame = CGRectMake(0, 0, 320, 320);
            imageViewProfilePicture.layer.borderWidth = 0;
            imageViewProfilePicture.layer.cornerRadius = 0;
            
            acctHeight.constant = 320;
        }else{
            imageViewProfilePicture.frame = originalZoomRect;
            imageViewProfilePicture.layer.borderWidth = 2;
            imageViewProfilePicture.layer.cornerRadius = 6;
            
            acctHeight.constant = originalAcctHeight;
        }
    
    
        [self.view layoutSubviews];
    }];
}

- (IBAction)tappedUsername:(id)sender
{
    alertUsername = [[UIAlertView alloc] initWithTitle:@"Change Username" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    
    alertUsername.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITextField *field = [alertUsername textFieldAtIndex:0];
    field.placeholder = @"New Username";
    
    [alertUsername show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == alertUsername)
    {
        if (buttonIndex == 0)
        { return;
        }
        
        NSString *new = [alertUsername textFieldAtIndex:0].text;
        
        PFQuery *unique = [PFUser query];
        [unique whereKey:@"username" equalTo:new];
        [unique countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (error) return;
            
            if (number > 0)
            {
                //no go
                alertUsername = [[UIAlertView alloc] initWithTitle:@"Username Taken" message:@"Please enter a different username" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
                alertUsername.alertViewStyle = UIAlertViewStylePlainTextInput;
                [alertUsername show];
            }else{
                [PFUser currentUser].username = [alertUsername textFieldAtIndex:0].text;
                [buttonusername setTitle:new forState:UIControlStateNormal];
                [[PFUser currentUser] saveInBackground];
            }
        }];
    }
}

- (IBAction)viewNews:(id)sender
{
    [UGRSSManagerViewController presentRSSManagerViewControllerCompletion:nil];
}

- (IBAction)viewUploads:(id)sender
{
    UGFilterViewController *filterVC = [UGFilterViewController findItemsWithQueryBlock:^PFQuery *{
        PFRelation *files = [self.user relationforKey:@"files"];
        
        PFQuery *filesQuery = [files query];
        [filesQuery orderByDescending:@"createdAt"];
        
        [filesQuery includeKey:@"user"];
        
        return filesQuery;
    } searchText:@""];
    
    filterVC.title = @"Uploads";
}

- (IBAction)viewLikes:(id)sender
{
    UGFilterViewController *filterVC = [UGFilterViewController findItemsWithQueryBlock:^PFQuery *{
        PFRelation *userLikes = [self.user relationforKey:@"likes"];
        PFQuery *query = [userLikes query];
        [query includeKey:@"user"];
        
        [query orderByDescending:@"createdAt"];
        
        return query;
    } searchText:@""];
    
    filterVC.title = @"Likes";
}

- (IBAction)viewFollowers:(id)sender {
    UGFilterViewController *filterVC = [UGFilterViewController findItemsWithQueryBlock:^PFQuery *{
        return [[UGCurrentUser user] followersQueryForUser:self.user];
    } searchText:@""];
    filterVC.title = @"Followers";
}

- (IBAction)viewFollowing:(id)sender {
    UGFilterViewController *filterVC = [UGFilterViewController findItemsWithQueryBlock:^PFQuery *{
        return [[UGCurrentUser user] followingQueryForUser:self.user];
    } searchText:@""];
    filterVC.title = @"Following";
}

- (IBAction)toggleFollowing:(id)sender {
    [[UGCurrentUser user] toggleFollowUser:self.user completion:^(BOOL isFollowing) {
        [buttonFollow setTitle:isFollowing ? @"Unfollow" : @"Follow" forState:UIControlStateNormal];
    }];
}

- (IBAction)showFollowedTags:(id)sender
{
    UGTagsViewController *tags = [UGTagsViewController presentTagsForUser:self.user];
    
    tags.title = @"Tags";
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView == textViewBio && [textView.text isEqualToString:BIO_EDIT_PLACEHOLDER]){
        textView.text = @"";
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    [[PFUser currentUser] setObject:textView.text forKey:@"bio"];
    [[PFUser currentUser] saveInBackground];
}

-(void)editProfilePicture
{
    //bring up image selector
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    
    imagePicker.allowsEditing = YES;
    
    [imagePicker setDelegate:self];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    imageViewProfilePicture.image = image;
    
    PFFile *imageFile = [PFFile fileWithData:UIImagePNGRepresentation(image)];
    [self.user setObject:imageFile forKey:@"profileImage"];
    
    [self.user saveInBackground];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)logout
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to logout?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Logout" otherButtonTitles:nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self logOutUser];
            break;
            
        default:
            break;
    }
}

-(void)logOutUser
{
    [PFUser logOut];
    [[UGTabBarController tabBarController] setSelectedIndex:0];
}

@end
